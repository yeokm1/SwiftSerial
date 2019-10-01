import Foundation
import SwiftSerial

print("You should do a loopback i.e short the TX and RX pins of the target serial port before testing.")

let testString: String = "The quick brown fox jumps over the lazy dog 01234567890."

let numberOfMultiNewLineTest : Int = 5

let test3Strings: String = testString + "\n" + testString + "\n" + testString + "\n"

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

    print("Writing test string <\(testString)> of \(testString.count) characters to serial port")

    let bytesWritten = try serialPort.writeString(testString)

    print("Successfully wrote \(bytesWritten) bytes")
    print("Waiting to receive what was written...")

    let stringReceived = try serialPort.readString(ofLength: bytesWritten)

    if testString == stringReceived {
        print("Received string is the same as transmitted string. Test successful!")
    } else {
        print("Uh oh! Received string is not the same as what was transmitted. This was what we received,")
        print("<\(stringReceived)>")
    }


    print("Now testing reading/writing of \(numberOfMultiNewLineTest) lines")

    var multiLineString: String = ""


    for _ in 1...numberOfMultiNewLineTest { 
        multiLineString += testString + "\n"
    }

    print("Now writing multiLineString")

    var _ = try serialPort.writeString(multiLineString)


    for i in 1...numberOfMultiNewLineTest {
        let stringReceived = try serialPort.readLine()
          
        if testString == stringReceived {
            print("Received string \(i) is the same as transmitted section. Moving on...")
        } else {
            print("Uh oh! Received string \(i) is not the same as what was transmitted. This was what we received,")
            print("<\(stringReceived)>")
            break
        }
    }
    
    print("End of example");


} catch PortError.failedToOpen {
    print("Serial port \(portName) failed to open. You might need root permissions.")
} catch {
    print("Error: \(error)")
}
