import Foundation
import SwiftLinuxSerial

print("You should do a loopback i.e short the TX and RX pins of the target serial port before testing.")

let testString: String = "The quick brown fox jumps over the lazy dog 01234567890."

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    print("Need serial port name, e.g. /dev/ttyUSB0 as the first argument.")
    exit(1)
}

let portName = arguments[1]
let serialPort: SerialPort = SerialPort(name: portName)

do {
    try serialPort.openPort()
    print("Serial port \(portName) opened successfully.")
    defer {
        serialPort.closePort()
    }

    serialPort.setSettings(receiveRate: .baud9600,
                           transmitRate: .baud9600,
                           minimumBytesToRead: 1)

    print("Writing test string <\(testString)> of \(testString.characters.count) characters to serial port")

    var bytesWritten = try serialPort.writeString(testString)

    print("Successfully wrote \(bytesWritten) bytes")
    print("Waiting to receive what was written...")

    let stringReceived = try serialPort.readString(ofLength: bytesWritten)

    if testString == stringReceived {
        print("Received string is the same as transmitted string. Test successful!")
    } else {
        print("Uh oh! Received string is not the same as what was transmitted. This was what we received,")
        print("<\(stringReceived)>")
    }

} catch PortError.failedToOpen {
    print("Serial port \(portName) failed to open. You might need root permissions.")
} catch {
    print("Error: \(error)")
}
