//
//  imgCapture.swift
//  device-tester
//
//  Created by Nathik Azad on 12/12/24.
//

import Foundation
import SwiftUI

class ImgCapture: NSObject, ObservableObject {
    private var frameWidth: UInt16?
    private var frameHeight: UInt16?
    private var totalBytes: UInt32?
    private var numPackets: UInt16?
    private let packetDataSize = 242
    
    private var frameBuffer: [UInt8]?
    private var packetsReceived: Set<UInt16> = []
    @Published var currentImage: UIImage?
    

    
    // MARK: - Frame Processing
    func handleHandshake(_ data: Data) {
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
    
     func handleDataPacket(_ data: Data) {
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
