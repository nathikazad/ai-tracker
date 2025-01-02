import CoreBluetooth

class BLEManager: NSObject, ObservableObject {
    static let DEVICE_NAME = "XIAOESP32S3_BLE"
    static let TRANSFER_CHARACTERISTIC_UUID = CBUUID(string: "00002a59-0000-1000-8000-00805f9b34fb")
    static let ACK_CHARACTERISTIC_UUID = CBUUID(string: "00002a58-0000-1000-8000-00805f9b34fb")
    static let TIME_CHARACTERISTIC_UUID = CBUUID(string: "00002a57-0000-1000-8000-00805f9b34fb")
    
    @Published var isConnected = false
    @Published var isReceiving = false
    @Published var receivedPackets = 0
    @Published var totalPackets = 0
    @Published var progressPercentage: Double = 0
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var transferCharacteristic: CBCharacteristic?
    private var imageData = Data()
    private var fileName: String?
    private var fileSize: Int?
    
    private var lastPacketTime: Date?
    private var timeoutTimer: Timer?
    private var receivedPacketsSet = Set<Int>()
    private let PACKET_TIMEOUT: TimeInterval = 1.0 // 1 second timeout
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        
        print("Starting scan for devices...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    private func reset() {
        imageData = Data()
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
        print("Final ACK sent")
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
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
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
        isConnected = false
        self.peripheral = nil
        print("Disconnected from peripheral: \(peripheral)")
        
        // Start scanning again
        startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    private func syncTime() {
        guard let peripheral = peripheral,
              let timeCharacteristic = peripheral.services?
                .flatMap({ $0.characteristics ?? [] })
                .first(where: { $0.uuid == BLEManager.TIME_CHARACTERISTIC_UUID }) else {
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
                BLEManager.TIME_CHARACTERISTIC_UUID
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
            } else if characteristic.uuid == BLEManager.ACK_CHARACTERISTIC_UUID {
//                print("Found ACK characteristic")
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
        
        // Check for reset packet (8-byte identifier)
        let identifier: [UInt8] = [0xFF, 0xA5, 0x5A, 0xC3, 0x3C, 0x69, 0x96, 0xF0]
        if data.count >= 8 && data.prefix(8).elementsEqual(identifier) {
            print("\nReceived reset packet, starting new file reception")
            reset()
            
            // Parse header information
            fileSize = Int(data[8]) << 24 | Int(data[9]) << 16 | Int(data[10]) << 8 | Int(data[11])
            totalPackets = Int(data[12]) << 24 | Int(data[13]) << 16 | Int(data[14]) << 8 | Int(data[15])
            let filenameLength = Int(data[16])
            
            if data.count >= 17 + filenameLength {
                fileName = String(data: data.subdata(in: 17..<17+filenameLength), encoding: .utf8)
            }
            
            isReceiving = true
            print("Starting to receive file: \(fileName ?? "unknown")")
            print("File size: \(fileSize ?? 0) bytes")
            print("Expected number of packets: \(totalPackets)")
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
            
            // Extend imageData if needed
            if writePosition + dataPortion.count > imageData.count {
                imageData.append(contentsOf: [UInt8](repeating: 0, count: writePosition + dataPortion.count - imageData.count))
            }
            
            // Write data at correct position
            imageData.replaceSubrange(writePosition..<writePosition + dataPortion.count, with: dataPortion)
            
            // Calculate and update progress
            progressPercentage = Double(receivedPackets) / Double(totalPackets) * 100
        }
        
        // If transfer complete
        if receivedPackets >= totalPackets {
            print("\nTransfer complete!")
            print("Total packets received: \(receivedPackets)")
            isReceiving = false
            timeoutTimer?.invalidate()
            timeoutTimer = nil
            sendAck() // Send final ACK
            saveFile()
            
        } else {
            timeoutTimer?.invalidate()
            
            // Create new timer that fires every 0.5 seconds
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: PACKET_TIMEOUT, repeats: false) { [weak self] _ in
                self?.checkTimeout()
            }
        }
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
    static func getDateBasedDirectory(for date: Date) -> URL? {
        guard let baseDirectory = receivedFilesDirectory else {
            return nil
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Format folder name as YYMMDD
        let folderName = String(format: "%02d%02d%02d",
                              dateComponents.year! % 100,
                              dateComponents.month!,
                              dateComponents.day!)
        
        let dateDirectory = baseDirectory.appendingPathComponent(folderName, isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: dateDirectory.path) {
            try? FileManager.default.createDirectory(at: dateDirectory, withIntermediateDirectories: true)
        }
        
        return dateDirectory
    }
}

extension Notification.Name {
    static let newFileReceived = Notification.Name("newFileReceived")
}

extension BLEManager {
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
        
        // Get the appropriate directory for this date
        guard let directory = FileManager.getDateBasedDirectory(for: dateFromFilename) else {
            print("Error: Unable to access or create date-based directory")
            return
        }
        
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            // Save the file
            try imageData.write(to: fileURL)
            
            // Create and save ReceivedFile metadata
            let newFile = ReceivedFile(
                id: UUID(),
                filepath: "\(directory.lastPathComponent)/\(fileName)", // Update filepath to include date folder
                dateReceived: dateFromFilename,
                fileType: ReceivedFile.getFileType(from: fileName)
            )
            
            // Save metadata to UserDefaults
            saveFileMetadata(newFile, date: dateFromFilename)
            
            print("File saved successfully at: \(fileURL.path)")
            NotificationCenter.default.post(name: .newFileReceived, object: nil)
            
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
