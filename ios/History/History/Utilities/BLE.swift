import Foundation
import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    // Main Friend Service UUID
    private let serviceUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    
    // Characteristic UUIDs
    private let audioDataUUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    private let audioCodecUUID = CBUUID(string: "19B10002-E8F2-537E-4F6C-D104768A1214")
    private let photoDataUUID = CBUUID(string: "19B10005-E8F2-537E-4F6C-D104768A1214")
    private let photoControlUUID = CBUUID(string: "19B10006-E8F2-537E-4F6C-D104768A1214")
    
    // Data handling properties
    private var audioBuffer: Data = Data()
    private var imageBuffer: Data = Data()
    private var currentImageFrameCount: UInt16 = 0
    
    // Callback closures
//    var onAudioDataReceived: ((Data) -> Void)?
//    var onImageDataReceived: ((Data) -> Void)?
    
    func onAudioDataReceived(_ d:Data) {
        print("Handle Audio data")
    }
    func onImageDataReceived(_ d:Data) {
        print("Handle Image data")
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
        
        if peripheral.name == "OpenGlass" {
            self.peripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            print("Connecting to OpenGlass")
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
            
            if characteristic.uuid == audioDataUUID || characteristic.uuid == photoDataUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        if characteristic.uuid == audioDataUUID {
            handleAudioData(data)
        } else if characteristic.uuid == photoDataUUID {
            handlePhotoData(data)
        }
    }
    
    private func handleAudioData(_ data: Data) {
        // Process audio data as needed
        // For simplicity, we're just passing the raw data to the callback
        onAudioDataReceived(data)
    }
    
    private func handlePhotoData(_ data: Data) {
        if data.count >= 2 {
            let frameCount = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            
            if frameCount == 0xFFFF {
                // End of image
                onImageDataReceived(imageBuffer)
                imageBuffer = Data()
                currentImageFrameCount = 0
            } else if frameCount == currentImageFrameCount {
                imageBuffer.append(data.dropFirst(2))
                currentImageFrameCount += 1
            } else {
                print("Received out-of-order image frame")
                // Handle error or reset image buffer
            }
        }
    }
    
    func takePhoto() {
        guard let peripheral = peripheral,
              let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }),
              let characteristic = service.characteristics?.first(where: { $0.uuid == photoControlUUID }) else {
            print("Photo control characteristic not found")
            return
        }
        
        let controlValue: UInt8 = 0xFF  // -1 in two's complement
        let data = Data([controlValue])
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}
