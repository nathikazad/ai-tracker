import Foundation
import CoreBluetooth
import AVFoundation
import UIKit

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    // Main Friend Service UUID
    private let serviceUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    private let fileDataUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    
    // Data handling properties
    private var audioBuffer: Data = Data()
    private var imageBuffer: Data = Data()
    private var currentImageFrameCount: UInt16 = 0
    
    // Add a new property to store the received file data
    private var fileData: Data = Data()
    private var currentFilePacketIndex: UInt16 = 0
    private var totalFilePackets: UInt16 = 0
    
    // Callback closures
//    var onAudioDataReceived: ((Data) -> Void)?
//    var onImageDataReceived: ((Data) -> Void)?
    
    // Audio properties
    private let sampleRate: Double = 16000
    private let channels: AVAudioChannelCount = 1
    private let bitDepth: UInt32 = 16
    private var audioFile: AVAudioFile?
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    
    
    func onImageDataReceived(_ d:Data) {
        print("Handle Image data")
        if let image = UIImage(data: imageBuffer) {
            // Use the complete image here
            // For example, save it or display it
        }
    }
    
    override init() {
        super.init()
        print("Bluetooth init")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on. Starting scan...")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown Device")")
        
        if peripheral.name == "OpenSurveyor" {
            self.peripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            print("Connecting to OpenSurveyor")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
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
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        if characteristic.uuid == fileDataUUID {
            handleFileData(data)
        }
    }

//    private func handlePhotoData(_ data: Data) {
//        if data.count >= 2 {
//            let frameCount = data.withUnsafeBytes { $0.load(as: UInt16.self) }
//            print(frameCount)
//            if frameCount == 0xFFFF {
//                // End of image
//                onImageDataReceived(imageBuffer)
//                imageBuffer = Data()
//                currentImageFrameCount = 0
//            } else if frameCount == currentImageFrameCount {
//                imageBuffer.append(data.dropFirst(2))
//                currentImageFrameCount += 1
//            } else {
//                print("Received out-of-order image frame")
//                // Handle error or reset image buffer
//            }
//        }
//    }
    
    private func handleFileData(_ data: Data) {
        if data.count >= 2 {
            let packetIndex = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            print(packetIndex, " ", currentFilePacketIndex)
            if packetIndex == 0 {
                // First packet, initialize file data and packet count
                let numPackets = data.withUnsafeBytes { $0.load(fromByteOffset: 2, as: UInt16.self) }
                let timestamp = data.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self) }
                fileData = Data()
                totalFilePackets = numPackets
                currentFilePacketIndex = 1
                
                // Extract filename from packet data
                let filenameLength = Int(data[8])
                let filenameBytes = [UInt8](data.dropFirst(9).prefix(filenameLength))
                let filename = String(bytes: filenameBytes, encoding: .utf8)
                print("Receiving file: \(filename ?? "Unknown")")
            } else if packetIndex == currentFilePacketIndex {
                // Append packet data to file data
                let packetData = data.dropFirst(10)
                fileData.append(packetData)
                currentFilePacketIndex += 1
                
                if packetIndex == totalFilePackets {
                    // Last packet received, handle complete file data
                    handleCompleteFileData(fileData)
                }
            } else {
                print("Received out-of-order file packet")
                // Handle error or reset file data
            }
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
