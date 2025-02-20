import CoreBluetooth

enum ESPState: UInt8 {
    case idle = 0
    case listening = 1
    case recording = 2
}

class BLEManager: NSObject, ObservableObject {
    static let DEVICE_NAME = "XIAOESP32S3_BLE"
    static let TRANSFER_CHARACTERISTIC_UUID = CBUUID(string: "00002a59-0000-1000-8000-00805f9b34fb")
    static let ACK_CHARACTERISTIC_UUID = CBUUID(string: "00002a58-0000-1000-8000-00805f9b34fb")
    static let TIME_CHARACTERISTIC_UUID = CBUUID(string: "00002a57-0000-1000-8000-00805f9b34fb")
    static let CMD_CHARACTERISTIC_UUID = CBUUID(string: "00002a56-0000-1000-8000-00805f9b34fb")
    static let NO_OF_FILES_REMAINING_CHARACTERISTIC_UUID = CBUUID(string: "00002a60-0000-1000-8000-00805f9b34fb")
    
    @Published var isConnected = false
    @Published var isReceiving = false
    @Published var receivedPackets = 0
    @Published var totalPackets = 0
    @Published var filesRemaining = 0
    @Published var progressPercentage: Double = 0
    @Published var espState: ESPState = .idle
    
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var transferCharacteristic: CBCharacteristic?
    private var fileData = Data()
    private var fileName: String?
    private var fileSize: Int?
    
    private var lastPacketTime: Date?
    private var timeoutTimer: Timer?
    private var receivedPacketsSet = Set<Int>()
    private let PACKET_TIMEOUT: TimeInterval = 1.0 // 1 second timeout
    
    private var reconnectTimer: Timer?
    private let maxReconnectAttempts = 5
    private var reconnectAttempts = 0
    
    private var transcriber:AudioTranscriber = AudioTranscriber();
    private var wsManager = WebSocketManager.shared

    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        wsManager.connect()
        transcriber.setTranscriptionCallback() {
            transcript in
            if(transcript.contains("record") && (transcript.contains("start") || transcript.contains("stop")) && self.espState == .listening) {
                print("Start Recording!!!!")
                self.startRecording()
            }
        }
    }
    
    private func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on")
//            lastError = "Bluetooth is not powered on"
            return
        }
        
//        connectionState = .scanning
        print("Starting scan for devices... State: \(centralManager.state.rawValue)")
        
        // Use specific service UUID if possible
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false,
            CBCentralManagerOptionShowPowerAlertKey: true
        ]
        
        centralManager.scanForPeripherals(withServices: nil, options: options)
    }
    
    private func reset() {
        fileData = Data()
        fileName = nil
        fileSize = nil
        receivedPackets = 0
        totalPackets = 0
        progressPercentage = 0
        isReceiving = false
        receivedPacketsSet.removeAll()
        lastPacketTime = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
//            lastError = "Notification error: \(error.localizedDescription)"
            return
        }
        
        print("Notification state updated for characteristic: \(characteristic.uuid)")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name == BLEManager.DEVICE_NAME else { return }
        
        self.peripheral = peripheral
        central.connect(peripheral, options: nil)
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral)")
        if let error = error {
            print("Disconnection error: \(error.localizedDescription)")
//            lastError = "Disconnection error: \(error.localizedDescription)"
        }
        
        // Handle MTU related disconnections
        if let error = error as? CBError {
            switch error.code {
            case .connectionTimeout:
                print("Connection timed out")
            case .peripheralDisconnected:
                print("Peripheral disconnected")
            default:
                print("Other error: \(error.code)")
            }
        }
        
        isConnected = false
//        connectionState = .disconnected
        reset()
        
        reconnectAttempts = 1  // Start counting from 1 since this is first attempt
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            if self.reconnectAttempts <= self.maxReconnectAttempts {
                central.connect(peripheral, options: nil)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral)")
        if let error = error {
            print("Connection error: \(error.localizedDescription)")
//            lastError = "Connection error: \(error.localizedDescription)"
        }
        
        reconnectAttempts += 1
        
        // If we failed to connect and still have attempts remaining, try again
        if reconnectAttempts < maxReconnectAttempts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                central.connect(peripheral, options: nil)
            }
        } else {
            print("Direct reconnection failed after \(maxReconnectAttempts) attempts, starting scan...")
            startScanning()
        }
    }
    
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error)")
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        
        //        print("Discovered services: \(services.map { $0.uuid })")
        for service in services {
            peripheral.discoverCharacteristics([
                BLEManager.TRANSFER_CHARACTERISTIC_UUID,
                BLEManager.ACK_CHARACTERISTIC_UUID,
                BLEManager.TIME_CHARACTERISTIC_UUID,
                BLEManager.CMD_CHARACTERISTIC_UUID,
                BLEManager.NO_OF_FILES_REMAINING_CHARACTERISTIC_UUID
            ], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service: \(service.uuid)")
            return
        }
        
        //        print("Discovered characteristics for service \(service.uuid):")
        for characteristic in characteristics {
            //            print("- \(characteristic.uuid)")
            if characteristic.uuid == BLEManager.TRANSFER_CHARACTERISTIC_UUID {
                //                print("Found transfer characteristic")
                transferCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == BLEManager.TIME_CHARACTERISTIC_UUID {
                print("Found time characteristic")
                // After discovering time characteristic, sync time
                syncTime()
            } else if characteristic.uuid == BLEManager.CMD_CHARACTERISTIC_UUID {
                print("Found CMD characteristic")
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == BLEManager.NO_OF_FILES_REMAINING_CHARACTERISTIC_UUID {
                print("Found num of files characteristic")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if let error = error {
            print("Error receiving data: \(error)")
            return
        }
        
        guard let data = characteristic.value else {
            print("Received empty data packet")
            return
        }
        
        if (characteristic.uuid == BLEManager.TRANSFER_CHARACTERISTIC_UUID) {
            receiveData(data: data)
        }
        if (characteristic.uuid == BLEManager.CMD_CHARACTERISTIC_UUID) {
            print("ESP data \(data) \(data.count)")
            if(!data.isEmpty) {
                espState = ESPState(rawValue: data[0]) ?? .idle
            }
        }
        if (characteristic.uuid == BLEManager.NO_OF_FILES_REMAINING_CHARACTERISTIC_UUID) {
            // print("ESP data \(data) \(data.count)")
            if(!data.isEmpty) {
                filesRemaining = Int(data[0])
                print("Num of files remaining: \(filesRemaining)")
            }
        }
    }
}

// MARK: - Data Exchange
extension BLEManager {
    private func sendAck() {
        guard let peripheral = peripheral,
              let ackCharacteristic = peripheral.services?
            .flatMap({ $0.characteristics ?? [] })
            .first(where: { $0.uuid == BLEManager.ACK_CHARACTERISTIC_UUID }) else {
            print("Cannot send ACK: ACK characteristic not found")
            return
        }
        
        // For final ACK, send "ACK" string
        let ackData = "ACK".data(using: .utf8)!
        peripheral.writeValue(ackData, for: ackCharacteristic, type: .withResponse)
        //        print("Final ACK sent")
    }
    
    func startListening() {
        print("Start Listening")
        sendCommand(command: ESPState.listening.rawValue)
    }
    
    func stopListening() {
        sendCommand(command: ESPState.idle.rawValue)
    }
    
    func startRecording() {
        FileManager.createTimeBasedDirectory()
        print("Start Recording")
        sendCommand(command: ESPState.recording.rawValue)
    }
    
    func stopRecording() {
        print("Stop Recording")
        sendCommand(command: ESPState.idle.rawValue)
    }
    
    private func sendCommand(command:UInt8) {
        guard let peripheral = peripheral,
              let ackCharacteristic = peripheral.services?
            .flatMap({ $0.characteristics ?? [] })
            .first(where: { $0.uuid == BLEManager.CMD_CHARACTERISTIC_UUID }) else {
            print("Cannot send CMD: CMD characteristic not found")
            return
        }
        peripheral.writeValue(Data([UInt8(command)]), for: ackCharacteristic, type: .withResponse)
        espState = ESPState(rawValue: command) ?? .idle
        print("Final CMD sent \(command)")
    }
    
    private func sendBitmapAck(receivedPackets: Set<Int>) {
        guard let peripheral = peripheral,
              let ackCharacteristic = peripheral.services?
            .flatMap({ $0.characteristics ?? [] })
            .first(where: { $0.uuid == BLEManager.ACK_CHARACTERISTIC_UUID }) else {
            print("Cannot send bitmap ACK: ACK characteristic not found")
            return
        }
        
        // Calculate bitmap size in bytes (rounded up)
        let bitmapSize = (totalPackets + 7) / 8
        var bitmap = [UInt8](repeating: 0, count: bitmapSize)
        
        // Fill the bitmap - MSB first
        for packetNum in receivedPackets {
            if packetNum < totalPackets {
                let byteIndex = packetNum / 8
                let bitIndex = packetNum % 8
                bitmap[byteIndex] |= UInt8(1 << (7 - bitIndex))
            }
        }
        
        // Calculate missing packets for debug output
        let missingPackets = Set(0..<totalPackets).subtracting(receivedPackets)
        
        peripheral.writeValue(Data(bitmap), for: ackCharacteristic, type: .withResponse)
        print("\nSent bitmap ACK: \(receivedPackets.count)/\(totalPackets) packets received")
        print("Missing packets: \(missingPackets.sorted())")
    }
    
    private func checkTimeout() {
        guard (lastPacketTime != nil),
              isReceiving,
              !receivedPacketsSet.isEmpty else {
            return
        }
        
        
        print("\nTimeout detected - sending bitmap ACK")
        sendBitmapAck(receivedPackets: receivedPacketsSet)
    }
    
    func syncTime() {
        guard let peripheral = peripheral,
              let timeCharacteristic = peripheral.services?
            .flatMap({ $0.characteristics ?? [] })
            .first(where: { $0.uuid == BLEManager.TIME_CHARACTERISTIC_UUID })
              
        else {
            print("Time characteristic not found")
            return
        }
        
        // Get current timestamp as UInt64
        let currentTime = UInt64(Date().timeIntervalSince1970)
        var timeBytes = currentTime.littleEndian // Convert to little-endian
        let data = Data(bytes: &timeBytes, count: MemoryLayout<UInt64>.size)
        
        peripheral.writeValue(data, for: timeCharacteristic, type: .withResponse)
        print("Time sync sent: \(currentTime)")
        
    }

    func receiveData(data: Data) {
        let MAX_FILE_SIZE = 1 * 1024 * 1024
        // Check for reset packet (8-byte identifier)
        let identifier: [UInt8] = [0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0]
        if data.count >= 8 && data.prefix(8).elementsEqual(identifier) {
            //            print()
            //            print("Received reset packet, starting new file reception")
            reset()
            
            // Parse header information
            fileSize = Int(data[8]) << 24 | Int(data[9]) << 16 | Int(data[10]) << 8 | Int(data[11])
            totalPackets = Int(data[12]) << 24 | Int(data[13]) << 16 | Int(data[14]) << 8 | Int(data[15])
            let filenameLength = Int(data[16])
            
            if filenameLength == 0 {
                fileName = nil
            } else if data.count >= 17 + filenameLength {
                fileName = String(data: data.subdata(in: 17..<17+filenameLength), encoding: .utf8)
            }
            
            isReceiving = true
            //            print("Starting to receive file: \(fileName ?? "Temp")")
            //            print("File size: \(fileSize ?? 0) bytes")
            //            print("Expected number of packets: \(totalPackets)")
            return
        }
        
        guard isReceiving else {
            print("Received data but not in receiving mode")
            return
        }
        
        // Parse packet number from header (3 bytes)
        lastPacketTime = Date()
        let packetNumber = (Int(data[0]) << 16) | (Int(data[1]) << 8) | Int(data[2])
        
        
        
        // Only increment if we haven't received this packet before
        if !receivedPacketsSet.contains(packetNumber) {
            receivedPacketsSet.insert(packetNumber)
            receivedPackets += 1
            
            // Get the data portion (excluding header)
            let dataPortion = data.subdata(in: 3..<data.count)
            
            // Calculate write position
            let writePosition = packetNumber * (512 - 3) // 512 is packet size, 3 is header size
            
            // Validate write position and required size
            let requiredSize = writePosition + dataPortion.count
            guard requiredSize > 0 && requiredSize <= MAX_FILE_SIZE else {
                print("Required size \(requiredSize) exceeds maximum allowed size, packet number: \(packetNumber)")
//                reset()
                return
            }
            
            // Safely extend fileData if needed
            if writePosition + dataPortion.count > fileData.count {
                let extensionSize = writePosition + dataPortion.count - fileData.count
                guard extensionSize > 0 && extensionSize <= MAX_FILE_SIZE else {
                    print("Invalid extension size required: \(extensionSize)")
                    reset()
                    return
                }
                
                do {
                    fileData.append(contentsOf: [UInt8](repeating: 0, count: extensionSize))
                } catch {
                    print("Failed to extend fileData: \(error)")
                    reset()
                    return
                }
            }
            
            // Validate final write operation
            guard writePosition + dataPortion.count <= fileData.count else {
                print("Write position \(writePosition) + data length \(dataPortion.count) exceeds file size")
                reset()
                return
            }
            
            // Write data at correct position
            fileData.replaceSubrange(writePosition..<writePosition + dataPortion.count, with: dataPortion)
            
            // Calculate and update progress
            progressPercentage = Double(receivedPackets) / Double(totalPackets) * 100
        }
        
        // If transfer complete
        if receivedPackets >= totalPackets {
            //            print("\nTransfer complete!")
            //            print("Total packets received: \(receivedPackets)")
            isReceiving = false
            timeoutTimer?.invalidate()
            timeoutTimer = nil
            sendAck() // Send final ACK
            if fileName?.hasSuffix("adpcm") ?? false {
                transcriber.processAudio(fileData)
            }
            if fileName != nil {
                
                saveFile()
//            } else {
                //                print("Saving audio buffer")
                
            }
            
        } else {
            timeoutTimer?.invalidate()
            
            // Create new timer that fires every 0.5 seconds
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: PACKET_TIMEOUT, repeats: false) { [weak self] _ in
                self?.checkTimeout()
            }
        }
    }
    
    private func saveFile() {
        guard let fileName = fileName else {
            print("Error: No filename provided")
            return
        }
        
        // Parse date from filename or use current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmss"
        
        let dateFromFilename: Date
        if let baseFileName = fileName.split(separator: ".").first,
           let timestamp = TimeInterval(baseFileName) {
            dateFromFilename = Date(timeIntervalSince1970: timestamp)
        } else {
            dateFromFilename = Date()
            print("Failed to parse timestamp from filename: \(fileName)")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
//        let folderName = formatter.string(from: dateFromFilename)
        
        let name = fileName.components(separatedBy: ".")[0]
        let folderName = FileManager.getLatestDirectoryBefore(epochTime: name) ?? "temp"
//        print("Folder name: \(folderName)")
        
        // Get the appropriate directory for this date
        guard let directory = FileManager.getDirectory(for: folderName) else {
            print("Error: Unable to access or create date-based directory")
            return
        }
        
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            // Save the file
            try fileData.write(to: fileURL)
            
            // Create and save ReceivedFile metadata
            let newFile = ReceivedFile(
                id: UUID(),
                filepath: "ReceivedFiles/\(folderName)/\(fileName)", // Update filepath to include date folder
                dateReceived: dateFromFilename,
                fileType: ReceivedFile.getFileType(from: fileName)
            )
            
            // Save metadata to UserDefaults
            saveFileMetadata(newFile, date: dateFromFilename)
            
            print("File saved successfully at: \(fileURL.path)")
//            if fileName.hasSuffix(".adpcm") {
                wsManager.sendFile(filepath: "\(folderName)/\(fileName)")
//            }
            
            NotificationCenter.default.post(name: .newFileReceived, object: nil)
            
            //            if newFile.fileType == .wav {
            //                transcriber.transcribeWav(url: fileURL) { transcription in
            //                    if let transcription = transcription {
            //                        print("Transcription completed: \(transcription)")
            //                    } else {
            //                        print("Transcription failed")
            //                    }
            //                }
            //            }
            
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    private func saveFileMetadata(_ file: ReceivedFile, date: Date) {
        var savedFiles = BLEManager.loadFileMetadata(for: date)
        savedFiles.append(file)
        
        if let encoded = try? JSONEncoder().encode(savedFiles) {
            UserDefaults.standard.set(encoded, forKey: "SavedFiles")
        }
    }
    
    static func loadFileMetadata(for date: Date) -> [ReceivedFile] {
        guard let data = UserDefaults.standard.data(forKey: "SavedFiles"),
              let files = try? JSONDecoder().decode([ReceivedFile].self, from: data) else {
            return []
        }
        
        
        let calendar = Calendar.current
        return files.filter { file in
            calendar.isDate(file.dateReceived, inSameDayAs: date)
        }
        return files
    }
}


extension FileManager {
    static var receivedFilesDirectory: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let receivedFilesPath = documentsDirectory.appendingPathComponent("ReceivedFiles", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: receivedFilesPath.path) {
            try? FileManager.default.createDirectory(at: receivedFilesPath, withIntermediateDirectories: true)
        }
        
        return receivedFilesPath
    }
    
    // New helper function to get/create date-based directory
    static func getDirectory(for name: String) -> URL? {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let dateDirectory = documentDirectory
            .appendingPathComponent("ReceivedFiles")
            .appendingPathComponent(name)
        
        do {
            try FileManager.default.createDirectory(
                at: dateDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            return dateDirectory
        } catch {
            print("Error creating directory: \(error)")
            return nil
        }
    }
    
    static func createTimeBasedDirectory() -> URL? {
        // Get current epoch time
        let currentEpochTime = String(Int(Date().timeIntervalSince1970)-60) // add minus 60 just in case of time sync error
        
        // Use existing getDirectory function to create the directory
        print("Creating directory \(currentEpochTime)")
        let directory = getDirectory(for: currentEpochTime)
        NotificationCenter.default.post(name: .newFileReceived, object: nil)
        return directory
    }
    
    static func getLatestDirectoryBefore(epochTime: String) -> String? {
        guard let receivedFilesURL = receivedFilesDirectory else {
            return nil
        }
        
        do {
            // Get all directory contents
            let contents = try FileManager.default.contentsOfDirectory(
                at: receivedFilesURL,
                includingPropertiesForKeys: nil
            )
            
            // Filter only directories and map to their names
            let directoryNames = contents
                .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
                .compactMap { Int($0.lastPathComponent) }
                .sorted()
            
            // Convert input epochTime to Int for comparison
            guard let targetTime = Int(epochTime) else {
                return nil
            }
            
            // Find the latest directory before the given time
            let previousTime = directoryNames
                .filter { $0 <= targetTime }
                .last
            
            return previousTime.map { String($0) }
            
        } catch {
            print("Error reading directory contents: \(error)")
            return nil
        }
    }
}

extension Notification.Name {
    static let newFileReceived = Notification.Name("newFileReceived")
}
