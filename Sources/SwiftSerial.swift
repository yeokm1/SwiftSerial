//
//  ARTemperatureMonitor.swift
//  hexapod
//
//  Created by Yuri on 01.07.17.
//
//

import Foundation
import Dispatch
import SwiftSerial


//port temp_monitor

class ARTemperatureMonitor {
    private var serialPort: SerialPort!
    private var portName = ""
    private var thread:Thread?
    var isRuningLoop = false
    var maxBufferSize = 1024 //1K input UART buffer for parcing incomming data
    var packetSize = 32 //29 bytes gyro packet size
    
    var serialQueue: DispatchQueue!
    
    func isRuning() -> Bool {
        if (thread != nil) {
            return (thread?.isExecuting)!
        } else {
            return false
        }
    }
    
    init(portName:String = "temp_monitor") {
        self.portName = portName
        serialPort = SerialPort(path: portName)
    }
    
    
    
    func start() {
        
        if thread != nil {
            return
        }
        
        isRuningLoop = true
        
        do {
            
            //            print("Attempting to open port: \(portName)")
            try serialPort.openPort()
            print("Serial port \(portName) opened successfully.")
            
            serialPort.setSettings(receiveRate: .baud115200,
                                   transmitRate: .baud115200,
                                   minimumBytesToRead: 1)
            
            serialQueue = DispatchQueue(label: self.portName)
            serialQueue.async {
                self.backgroundRead()
            }
            
        } catch PortError.failedToOpen {
            print("Serial port \(portName) failed to open. You might need root permissions.")
        } catch {
            print("Error: \(error)")
        }
    }
    
    func backgroundRead() {
        do{
            let readData = try serialPort.readUntilBytes(stopBytes: [58,58,58,13,10], maxBytes: 64)
            if readData.count >= 23 {
                //decoding recieved data
                var CRC: UInt32 = 0;
                for  i in 0...16 {
                    CRC = CRC + UInt32(readData[i])
                }
                
                CRC = CRC & 0xFF
                
                //                print("\(readData)")
                
                let sensorNumber:UInt8 = readData[0]
                let sensorAddress:String = "\(String(format:"%2X", readData[1])) \(String(format:"%2X", readData[2])) \(String(format:"%2X", readData[3])) \(String(format:"%2X", readData[4])) \(String(format:"%2X", readData[5])) \(String(format:"%2X", readData[6])) \(String(format:"%2X", readData[7])) \(String(format:"%2X", readData[8]))"
                let temperature: Int32 = Int32(readData[9]) | Int32(readData[10]) << 8 | Int32(readData[11]) << 16 | Int32(readData[12]) << 24
                
                let timer: UInt32 = UInt32(readData[13]) | UInt32(readData[14]) << 8 | UInt32(readData[15]) << 16 | UInt32(readData[16]) << 24
                
                let crc_pack = UInt32(readData[17])
                
                if CRC == crc_pack {
                    print("\(portName) packet end found CRC=\(CRC)==\(crc_pack)) OK \(sensorNumber) \(sensorAddress) \(temperature) \(timer)")
                } else {
                    print("\(portName) packet end found CRC=\(CRC)==\(crc_pack)) FAIL \(sensorNumber) \(sensorAddress) \(temperature) \(timer)")
                    //                    print("\(portName) packet end found CRC=\(CRC)!=\(crc_pack)) FAIL")
                }
            }
            
            
        } catch {
            print("Error: \(error)")
        }
        
        serialQueue.async {
            self.backgroundRead()
        }
    }
    
    func stop() {
        isRuningLoop = false
        print("Stoping thread \(self.portName)...")
    }
    
    
}
