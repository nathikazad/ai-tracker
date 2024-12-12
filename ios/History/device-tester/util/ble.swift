//
//  ble.swift
//  ble-test-2
//
//  Created by Nathik Azad on 12/11/24.
//

import Foundation
import SwiftUI
import CoreBluetooth

// MARK: - BLE Service and Characteristic UUIDs
struct BLEConstants {
    static let serialServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let serialTxUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
}

// MARK: - Frame Receiver Class
class BLEFrameReceiver: NSObject, ObservableObject {
    private var frameWidth: UInt16?
    private var frameHeight: UInt16?
    private var totalBytes: UInt32?
    private var numPackets: UInt16?
    private let packetDataSize = 242
    
    private var frameBuffer: [UInt8]?
    private var packetsReceived: Set<UInt16> = []
    @Published var currentImage: UIImage?
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    @Published var isConnected = false
    @Published var isScanning = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        centralManager.scanForPeripherals(withServices: [BLEConstants.serialServiceUUID],
                                        options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    // MARK: - Frame Processing
    private func handleHandshake(_ data: Data) {
        print("Handshake data length: \(data.count)")
        guard data.count >= 14,
              data[0] == 0xFF, data[1] == 0xAA,
              data[12] == 0xFF, data[13] == 0xBB else {
            print("Invalid handshake format")
            return
        }
        
        // Extract bytes safely using Array(data)
        let bytes = Array(data)
        
        // Extract totalBytes (4 bytes, little-endian)
        totalBytes = UInt32(bytes[2]) | (UInt32(bytes[3]) << 8) | (UInt32(bytes[4]) << 16) | (UInt32(bytes[5]) << 24)
        
        // Extract numPackets (2 bytes, little-endian)
        numPackets = UInt16(bytes[6]) | (UInt16(bytes[7]) << 8)
        
        // Extract frameWidth (2 bytes, little-endian)
        frameWidth = UInt16(bytes[8]) | (UInt16(bytes[9]) << 8)
        
        // Extract frameHeight (2 bytes, little-endian)
        frameHeight = UInt16(bytes[10]) | (UInt16(bytes[11]) << 8)
        
        print("Handshake received: \(frameWidth!)x\(frameHeight!), \(totalBytes!) bytes in \(numPackets!) packets")
        
        frameBuffer = Array(repeating: 0, count: Int(totalBytes!))
        packetsReceived.removeAll()
    }
    
    private func handleDataPacket(_ data: Data) {
        guard data.count >= 2,
              let frameBuffer = frameBuffer,
              let totalBytes = totalBytes,
              let numPackets = numPackets else { return }
        
        let packetNum = data[0...1].withUnsafeBytes { $0.load(as: UInt16.self) }
        let payload = data.dropFirst(2)
        
        let offset = Int(packetNum) * packetDataSize
        let remainingBytes = Int(totalBytes) - offset
        let expectedSize = min(remainingBytes, packetDataSize)
        
        guard expectedSize > 0, offset + expectedSize <= frameBuffer.count else { return }
        
        payload.prefix(expectedSize).enumerated().forEach { i, byte in
            self.frameBuffer?[offset + i] = byte
        }
        packetsReceived.insert(packetNum)
        
        if packetsReceived.count == numPackets {
            processCompleteFrame()
        }
    }
    
    private func processCompleteFrame() {
        guard let frameBuffer = frameBuffer,
              let width = frameWidth,
              let height = frameHeight else { return }
        
        let grayImage = frameBuffer.withUnsafeBufferPointer { pointer -> CGImage? in
            guard let baseAddress = pointer.baseAddress else { return nil }
            let context = CGContext(data: UnsafeMutableRawPointer(mutating: baseAddress),
                                  width: Int(width),
                                  height: Int(height),
                                  bitsPerComponent: 8,
                                  bytesPerRow: Int(width),
                                  space: CGColorSpaceCreateDeviceGray(),
                                  bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue)
            return context?.makeImage()
        }
        
        if let cgImage = grayImage {
            DispatchQueue.main.async {
                self.currentImage = UIImage(cgImage: cgImage)
            }
        }
    }
}

// MARK: - CBCentralManager Delegate
extension BLEFrameReceiver: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name.contains("CameraRelay") else { return }
        
        stopScanning()
        self.peripheral = peripheral
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "unknown device")")
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices([BLEConstants.serialServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        startScanning()
    }
}

// MARK: - CBPeripheral Delegate
extension BLEFrameReceiver: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([BLEConstants.serialTxUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == BLEConstants.serialTxUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                   error: Error?) {
        guard let data = characteristic.value else { return }
        
        if data.count >= 2 && data[0] == 0xFF && data[1] == 0xAA {
            handleHandshake(data)
        } else {
            handleDataPacket(data)
        }
    }
}
