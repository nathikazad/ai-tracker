import Foundation
import CoreBluetooth
import AVFoundation
import UIKit

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var ackCharacteristic: CBCharacteristic?
    private var isConnected = false
    
    // Main Friend Service UUID
    private let serviceUUID = CBUUID(string: "19B00000-E8F2-537E-4F6C-D104768A1214")
    private let fileDataUUID = CBUUID(string: "19B00001-E8F2-537E-4F6C-D104768A1214")
    private let ackUUID = CBUUID(string: "19B00002-E8F2-537E-4F6C-D104768A1214")
    
    // Data handling properties
    private var audioBuffer: Data = Data()
    private var imageBuffer: Data = Data()
    private var currentImageFrameCount: UInt16 = 0
    
    // Add a new property to store the received file data
    private var fileData: Data = Data()
    private var currentFilePacketIndex: UInt16 = 0
    private var totalFilePackets: UInt16 = 0
    private var packetsReceived: [UInt16] = []
    private var ackTimer: Timer?
    
    
    // Audio properties
    private let sampleRate: Double = 16000
    private let channels: AVAudioChannelCount = 1
    private let bitDepth: UInt32 = 16
    private var audioFile: AVAudioFile?
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?

    private let deviceIdentifierKey = "RememberedDeviceIdentifier"
    private var rememberedDeviceIdentifier: UUID? {
        get {
            if let uuidString = UserDefaults.standard.string(forKey: deviceIdentifierKey) {
                return UUID(uuidString: uuidString)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue?.uuidString, forKey: deviceIdentifierKey)
        }
    }
    

    private var i: UInt16 = 0
    override init() {
        super.init()
        print("Bluetooth init")
        centralManager = CBCentralManager(delegate: self, queue: nil)
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            if (self?.isConnected == true) {
//                self?.sendAck(for: self?.i ?? 0)
//                self?.i = (self?.i ?? 0) + 1
//            }
//        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on. Starting scan...")
            if let rememberedIdentifier = rememberedDeviceIdentifier {
                print("Attempting to reconnect to remembered device...")
                if let peripherals = centralManager.retrievePeripherals(withIdentifiers: [rememberedIdentifier]) as? [CBPeripheral], let peripheral = peripherals.first {
                    connect(to: peripheral)
                } else {
                    startScan()
                }
            } else {
                startScan()
            }
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    private func startScan() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown Device")")
        
        if peripheral.name == "OpenSurveyor" {
            connect(to: peripheral)
        }
    }
    
    private func connect(to peripheral: CBPeripheral) {
        
        self.peripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        print("Connecting to \(peripheral.name ?? "Unknown Device")")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected  = true
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        rememberedDeviceIdentifier = peripheral.identifier
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown Device")")
        // Attempt to reconnect
        isConnected = false
        connect(to: peripheral)
    }
    
    func forgetDevice() {
        rememberedDeviceIdentifier = nil
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        peripheral = nil
        ackCharacteristic = nil
        // Reset other relevant properties
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")
            
            if characteristic.uuid == fileDataUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == ackUUID {
                print("Discovered ack characteristic")
                ackCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        print("Received data")
        if characteristic.uuid == fileDataUUID {
            handleFileData(data)
        }
    }
    
    private func sendAck(for packetIndex: UInt16) {
        print("Sent ACK for packet \(packetIndex)")
        guard let peripheral = peripheral,
              let ackCharacteristic = ackCharacteristic else {
            print("Cannot send ACK: peripheral or ackCharacteristic is nil")
            return
        }
        
        var ackData = Data(capacity: 2)
        ackData.append(UInt8((packetIndex >> 8) & 0xFF))
        ackData.append(UInt8(packetIndex & 0xFF))
        
        peripheral.writeValue(ackData, for: ackCharacteristic, type: .withResponse)
        print("Sent ACK for packet \(packetIndex)")
    }
    
    private func sendAcks() {
        // send acks for all packets that have not been acknowledged
        for packetIndex in packetsReceived {
            sendAck(for: packetIndex)
        }
        packetsReceived = []
//        if !packetsReceived.isEmpty {
//            sendAck(for: packetsReceived[0])
//        }
    }

    
    private func handleFileData(_ data: Data) {
        if data.count >= 2 {
            var packetIndex = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            packetsReceived.append(packetIndex)
            print(packetIndex, " ", currentFilePacketIndex)
            ackTimer?.invalidate()

            ackTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                self?.sendAcks()
                self?.ackTimer = nil
            }


//            Task {
//                sendAck(for: packetIndexCopy)
//            }


        //    if packetIndex == 0 {
//                // First packet, initialize file data and packet count
//                let numPackets = data.withUnsafeBytes { $0.load(fromByteOffset: 2, as: UInt16.self) }
//                let timestamp = data.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self) }
//                fileData = Data()
//                totalFilePackets = numPackets
//                currentFilePacketIndex = 1
//                
//                // Extract filename from packet data
//                let filenameLength = Int(data[8])
//                let filenameBytes = [UInt8](data.dropFirst(9).prefix(filenameLength))
//                let filename = String(bytes: filenameBytes, encoding: .utf8)
//                print("Receiving file: \(filename ?? "Unknown")")
//            } else if packetIndex == currentFilePacketIndex {
//                // Append packet data to file data
//                let packetData = data.dropFirst(10)
//                fileData.append(packetData)
//                currentFilePacketIndex += 1
//                
//                if packetIndex == totalFilePackets {
//                    // Last packet received, handle complete file data
//                    handleCompleteFileData(fileData)
//                }
//            } else {
//                print("Received out-of-order file packet")
//                // Handle error or reset file data
//            }
        }
    }
    
    private func handleCompleteFileData(_ data: Data) {
        // Handle the complete file data here
        // For example, you can save it to disk or process it further
        print("Received complete file data: \(data.count) bytes")
        
        // Reset properties for next file
        currentFilePacketIndex = 0
        totalFilePackets = 0
        fileData = Data()
    }
    
//    func takePhoto() {
//        guard let peripheral = peripheral,
//              let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }),
//              let characteristic = service.characteristics?.first(where: { $0.uuid == photoControlUUID }) else {
//            print("Photo control characteristic not found")
//            return
//        }
//        
//        let controlValue: UInt8 = 0xFF  // -1 in two's complement
//        let data = Data([controlValue])
//        peripheral.writeValue(data, for: characteristic, type: .withResponse)
//    }
}
