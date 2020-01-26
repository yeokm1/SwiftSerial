import Foundation
import SwiftSerial

print("You should do a loopback i.e short the TX and RX pins of the target serial port before testing.")

let testBinaryArray : [UInt8] = [0x11, 0x22, 0x33, 0x0D, 0x44]

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    print("Need serial port name, e.g. /dev/ttyUSB0 or /dev/cu.usbserial as the first argument.")
    exit(1)
}

let portName = arguments[1]
let serialPort: SerialPort = SerialPort(path: portName)

do {

    print("Attempting to open port: \(portName)")
    try serialPort.openPort()
    print("Serial port \(portName) opened successfully.")
    defer {
        serialPort.closePort()
        print("Port Closed")
    }

    serialPort.setSettings(receiveRate: .baud9600,
                           transmitRate: .baud9600,
                           minimumBytesToRead: 1)

    print("Sending: ", terminator:"")
    print(testBinaryArray.map { String($0, radix: 16, uppercase: false) })

    let dataToSend: Data = Data(_: testBinaryArray)

    let bytesWritten = try serialPort.writeData(dataToSend)

    print("Successfully wrote \(bytesWritten) bytes")
    print("Waiting to receive what was written...")

    let dataReceived = try serialPort.readData(ofLength: bytesWritten)

    print("Received: ", terminator:"")
    print(dataReceived.map { String($0, radix: 16, uppercase: false) })

    if(dataToSend.elementsEqual(dataReceived)){
        print("Received data is the same as transmitted data. Test successful!")
    } else {
        print("Uh oh! Received data is not the same as what was transmitted. This was what we received,")
        print(dataReceived.map { String($0, radix: 16, uppercase: false) })
    }
    
    print("End of example");


} catch PortError.failedToOpen {
    print("Serial port \(portName) failed to open. You might need root permissions.")
} catch {
    print("Error: \(error)")
}
