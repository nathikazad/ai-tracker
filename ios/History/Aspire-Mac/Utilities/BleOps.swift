import Foundation
import CoreBluetooth
import AVFoundation
import Speech

class BLEAudioTranscriber: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, SFSpeechRecognizerDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var notifyCharacteristic: CBCharacteristic?
    
    private let deviceName = "XIAO_ESP32S3_Audio"
    private let notifyCharacteristicUUID = CBUUID(string: "00002a59-0000-1000-8000-00805f9b34fb")
    
    private var audioData = Data()
    private var expectedPackets = 0
    private var receivedPackets = 0
    private var fileCounter = 0
    private var startTime: Date?
    private var transcriber: AudioTranscriber?
    

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        transcriber = AudioTranscriber()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name == deviceName else { return }
        
        self.peripheral = peripheral
        central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown device")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == notifyCharacteristicUUID {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("Waiting for audio data...")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        if data.prefix(5) == "START".data(using: .ascii) {
            audioData = Data()
            startTime = Date()
            expectedPackets = Int(data[7])
            receivedPackets = 0
        } else if data.prefix(2) == Data([0xFF, 0xFF]) {
            let chunkIndex = data.subdata(in: 2..<4).withUnsafeBytes { $0.load(as: UInt16.self) }
            audioData.append(data.subdata(in: 4..<data.count))
            receivedPackets += 1
//            print("Received packet \(receivedPackets)/\(expectedPackets)", terminator: "\r")
        } else if data.prefix(3) == "END".data(using: .ascii) {
            if let startTime = startTime {
                let duration = Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds
                print("\nAudio data received successfully. Total time: \(String(format: "%.2f", duration)) ms")
            }
             transcriber?.processAudioData(audioData)
        } else {
            print("Received unexpected data: \(data)")
        }
    }
}
