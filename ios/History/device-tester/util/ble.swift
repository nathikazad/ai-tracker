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
    static let camUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let micUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
}

// MARK: - Frame Receiver Class
class BLEHandler: NSObject, ObservableObject, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var currentImage: UIImage?
    
    private let audioTranscriber = AudioTranscriber()
    let imgCapture = ImgCapture()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        imgCapture.$currentImage
                    .receive(on: DispatchQueue.main)
                    .assign(to: &$currentImage)
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
}

// MARK: - CBCentralManager Delegate
extension BLEHandler: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name.contains("Aspire") else { return }
        
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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([BLEConstants.camUUID, BLEConstants.micUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == BLEConstants.camUUID || characteristic.uuid == BLEConstants.micUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                   error: Error?) {
        guard let data = characteristic.value else { return }
        switch characteristic.uuid {
            case BLEConstants.micUUID:
                DispatchQueue.main.async { [weak self] in
                    self?.audioTranscriber.handleAudioData(data)
                }
                break;
            case BLEConstants.camUUID:
                if data.count >= 2 && data[0] == 0xFF && data[1] == 0xAA {
                    imgCapture.handleHandshake(data)
                } else {
                    imgCapture.handleDataPacket(data)
                }
                break;
            default:
            print("Unknown characteristic \(characteristic.uuid)");
            }
    }
}
