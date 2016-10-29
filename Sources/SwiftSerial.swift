import Foundation

#if os(Linux)
public enum BaudRate {
    case baud0
    case baud50
    case baud75
    case baud110
    case baud134
    case baud150
    case baud200
    case baud300
    case baud600
    case baud1200
    case baud1800
    case baud2400
    case baud4800
    case baud9600
    case baud19200
    case baud38400
    case baud57600
    case baud115200
    case baud230400
    case baud460800
    case baud500000
    case baud576000
    case baud921600
    case baud1000000
    case baud1152000
    case baud1500000
    case baud2000000
    case baud2500000
    case baud3500000
    case baud4000000

    var speedValue: speed_t {
        switch self {
        case .baud0:
            return speed_t(B0)
        case .baud50:
            return speed_t(B50)
        case .baud75:
            return speed_t(B75)
        case .baud110:
            return speed_t(B110)
        case .baud134:
            return speed_t(B134)
        case .baud150:
            return speed_t(B150)
        case .baud200:
            return speed_t(B200)
        case .baud300:
            return speed_t(B300)
        case .baud600:
            return speed_t(B600)
        case .baud1200:
            return speed_t(B1200)
        case .baud1800:
            return speed_t(B1800)
        case .baud2400:
            return speed_t(B2400)
        case .baud4800:
            return speed_t(B4800)
        case .baud9600:
            return speed_t(B9600)
        case .baud19200:
            return speed_t(B19200)
        case .baud38400:
            return speed_t(B38400)
        case .baud57600:
            return speed_t(B57600)
        case .baud115200:
            return speed_t(B115200)
        case .baud230400:
            return speed_t(B230400)
        case .baud460800:
            return speed_t(B460800)
        case .baud500000:
            return speed_t(B500000)
        case .baud576000:
            return speed_t(B576000)
        case .baud921600:
            return speed_t(B921600)
        case .baud1000000:
            return speed_t(B1000000)
        case .baud1152000:
            return speed_t(B1152000)
        case .baud1500000:
            return speed_t(B1500000)
        case .baud2000000:
            return speed_t(B2000000)
        case .baud2500000:
            return speed_t(B2500000)
        case .baud3500000:
            return speed_t(B3500000)
        case .baud4000000:
            return speed_t(B4000000)
        }
    }
}
#elseif os(OSX)
public enum BaudRate {
    case baud0
    case baud50
    case baud75
    case baud110
    case baud134
    case baud150
    case baud200
    case baud300
    case baud600
    case baud1200
    case baud1800
    case baud2400
    case baud4800
    case baud9600
    case baud19200
    case baud38400
    case baud57600
    case baud115200
    case baud230400

    var speedValue: speed_t {
        switch self {
        case .baud0:
            return speed_t(B0)
        case .baud50:
            return speed_t(B50)
        case .baud75:
            return speed_t(B75)
        case .baud110:
            return speed_t(B110)
        case .baud134:
            return speed_t(B134)
        case .baud150:
            return speed_t(B150)
        case .baud200:
            return speed_t(B200)
        case .baud300:
            return speed_t(B300)
        case .baud600:
            return speed_t(B600)
        case .baud1200:
            return speed_t(B1200)
        case .baud1800:
            return speed_t(B1800)
        case .baud2400:
            return speed_t(B2400)
        case .baud4800:
            return speed_t(B4800)
        case .baud9600:
            return speed_t(B9600)
        case .baud19200:
            return speed_t(B19200)
        case .baud38400:
            return speed_t(B38400)
        case .baud57600:
            return speed_t(B57600)
        case .baud115200:
            return speed_t(B115200)
        case .baud230400:
            return speed_t(B230400)
        }
    }
}
#endif

public enum DataBitsSize {
    case bits5
    case bits6
    case bits7
    case bits8

    var flagValue: tcflag_t {
        switch self {
        case .bits5:
            return tcflag_t(CS5)
        case .bits6:
            return tcflag_t(CS6)
        case .bits7:
            return tcflag_t(CS7)
        case .bits8:
            return tcflag_t(CS8)
        }
    }

}

public enum ParityType {
    case none
    case even
    case odd

    var parityValue: tcflag_t {
        switch self {
        case .none:
            return 0
        case .even:
            return tcflag_t(PARENB)
        case .odd:
            return tcflag_t(PARENB | PARODD)
        }
    }
}

public enum PortError: Int32, Error {
    case failedToOpen = -1 // refer to open()
    case invalidPath
    case mustReceiveOrTransmit
    case mustBeOpen
    case stringsMustBeUTF8
}

public class SerialPort {

    var path: String
    var fileDescriptor: Int32?

    public init(path: String) {
        self.path = path
    }

    public func openPort() throws {
        try openPort(toReceive: true, andTransmit: true)
    }

    public func openPort(toReceive receive: Bool, andTransmit transmit: Bool) throws {
        guard !path.isEmpty else {
            throw PortError.invalidPath
        }

        guard receive || transmit else {
            throw PortError.mustReceiveOrTransmit
        }

        var readWriteParam : Int32

        if receive && transmit {
            readWriteParam = O_RDWR
        } else if receive {
            readWriteParam = O_RDONLY
        } else if transmit {
            readWriteParam = O_WRONLY
        } else {
            fatalError()
        }

    #if os(Linux)
        fileDescriptor = open(path, readWriteParam | O_NOCTTY)
    #elseif os(OSX)
        fileDescriptor = open(path, readWriteParam | O_NOCTTY | O_EXLOCK)
    #endif

        // Throw error if open() failed
        if fileDescriptor == PortError.failedToOpen.rawValue {
            throw PortError.failedToOpen
        }
    }

    public func setSettings(receiveRate: BaudRate,
                            transmitRate: BaudRate,
                            minimumBytesToRead: Int,
                            timeout: Int = 0, /* 0 means wait indefinitely */
                            parityType: ParityType = .none,
                            sendTwoStopBits: Bool = false, /* 1 stop bit is the default */
                            dataBitsSize: DataBitsSize = .bits8,
                            useHardwareFlowControl: Bool = false,
                            useSoftwareFlowControl: Bool = false,
                            processOutput: Bool = false) {
        
        guard let fileDescriptor = fileDescriptor else {
            return
        }


        // Set up the control structure
        var settings = termios()

        // Get options structure for the port
        tcgetattr(fileDescriptor, &settings)

        // Set baud rates
        cfsetispeed(&settings, receiveRate.speedValue)
        cfsetospeed(&settings, transmitRate.speedValue)

        // Enable parity (even/odd) if needed
        settings.c_cflag |= parityType.parityValue

        // Set stop bit flag
        if sendTwoStopBits {
            settings.c_cflag |= tcflag_t(CSTOPB)
        } else {
            settings.c_cflag &= ~tcflag_t(CSTOPB)
        }

        // Set data bits size flag
        settings.c_cflag &= ~tcflag_t(CSIZE)
        settings.c_cflag |= dataBitsSize.flagValue

        // Set hardware flow control flag
    #if os(Linux)
        if useHardwareFlowControl {
            settings.c_cflag |= tcflag_t(CRTSCTS)
        } else {
            settings.c_cflag &= ~tcflag_t(CRTSCTS)
        }
    #elseif os(OSX)
        if useHardwareFlowControl {
            settings.c_cflag |= tcflag_t(CRTS_IFLOW)
            settings.c_cflag |= tcflag_t(CCTS_OFLOW)
        } else {
            settings.c_cflag &= ~tcflag_t(CRTS_IFLOW)
            settings.c_cflag &= ~tcflag_t(CCTS_OFLOW)
        }
    #endif

        // Set software flow control flags
        let softwareFlowControlFlags = tcflag_t(IXON | IXOFF | IXANY)
        if useSoftwareFlowControl {
            settings.c_iflag |= softwareFlowControlFlags
        } else {
            settings.c_iflag &= ~softwareFlowControlFlags
        }

        // Turn on the receiver of the serial port, and ignore modem control lines
        settings.c_cflag |= tcflag_t(CREAD | CLOCAL)

        // Turn off canonical mode
        settings.c_lflag &= ~tcflag_t(ICANON | ECHO | ECHOE | ISIG)

        // Set output processing flag
        if processOutput {
            settings.c_oflag |= tcflag_t(OPOST)
        } else {
            settings.c_oflag &= ~tcflag_t(OPOST)
        }

        //Special characters
        //We do this as c_cc is a C-fixed array which is imported as a tuple in Swift.
        //To avoid hardcoding the VMIN or VTIME value to access the tuple value, we use the typealias instead
    #if os(Linux)
        typealias specialCharactersTuple = (VINTR: cc_t, VQUIT: cc_t, VERASE: cc_t, VKILL: cc_t, VEOF: cc_t, VTIME: cc_t, VMIN: cc_t, VSWTC: cc_t, VSTART: cc_t, VSTOP: cc_t, VSUSP: cc_t, VEOL: cc_t, VREPRINT: cc_t, VDISCARD: cc_t, VWERASE: cc_t, VLNEXT: cc_t, VEOL2: cc_t, spare1: cc_t, spare2: cc_t, spare3: cc_t, spare4: cc_t, spare5: cc_t, spare6: cc_t, spare7: cc_t, spare8: cc_t, spare9: cc_t, spare10: cc_t, spare11: cc_t, spare12: cc_t, spare13: cc_t, spare14: cc_t, spare15: cc_t)
        var specialCharacters: specialCharactersTuple = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) // NCCS = 32
    #elseif os(OSX)
        typealias specialCharactersTuple = (VEOF: cc_t, VEOL: cc_t, VEOL2: cc_t, VERASE: cc_t, VWERASE: cc_t, VKILL: cc_t, VREPRINT: cc_t, spare1: cc_t, VINTR: cc_t, VQUIT: cc_t, VSUSP: cc_t, VDSUSP: cc_t, VSTART: cc_t, VSTOP: cc_t, VLNEXT: cc_t, VDISCARD: cc_t, VMIN: cc_t, VTIME: cc_t, VSTATUS: cc_t, spare: cc_t)
        var specialCharacters: specialCharactersTuple = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) // NCCS = 20
    #endif

        specialCharacters.VMIN = cc_t(minimumBytesToRead)
        specialCharacters.VTIME = cc_t(timeout)
        settings.c_cc = specialCharacters

        // Commit settings
        tcsetattr(fileDescriptor, TCSANOW, &settings)
    }

    public func closePort() {
        if let fileDescriptor = fileDescriptor {
            close(fileDescriptor)
        }
        fileDescriptor = nil
    }
}

// MARK: Receiving

extension SerialPort {

    public func readBytes(into buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw PortError.mustBeOpen
        }

        let bytesRead = read(fileDescriptor, buffer, size)
        return bytesRead
    }

    public func readData(ofLength length: Int) throws -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        defer {
            buffer.deallocate(capacity: length)
        }

        let bytesRead = try readBytes(into: buffer, size: length)

        var data : Data

        if bytesRead > 0 {
            data = Data(bytes: buffer, count: bytesRead)
        } else {
            //This is to avoid the case where bytesRead can be negative causing problems allocating the Data buffer
            data = Data(bytes: buffer, count: 0)
        }

        return data
    }

    public func readString(ofLength length: Int) throws -> String {
        var remainingBytesToRead = length
        var result = ""

        while remainingBytesToRead > 0 {
            let data = try readData(ofLength: remainingBytesToRead)

            if let string = String(data: data, encoding: String.Encoding.utf8) {
                result += string
                remainingBytesToRead -= data.count
            } else {
                return result
            }
        }

        return result
    }

    public func readUntilChar(_ terminator: CChar) throws -> String {
        var data = Data()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer {
            buffer.deallocate(capacity: 1)
        }

        while true {
            let bytesRead = try readBytes(into: buffer, size: 1)

            if bytesRead > 0 {
                let character = CChar(buffer[0])
                
                if character == terminator {
                    break
                } else {
                    data.append(buffer, count: 1)
                }
            }
        }

        if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        } else {
            throw PortError.stringsMustBeUTF8
        }
    }

    public func readLine() throws -> String {
        let newlineChar = CChar(10) // Newline/Line feed character `\n` is 10
        return try readUntilChar(newlineChar)
    }

    public func readChar() throws -> UnicodeScalar {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        
        defer {
            buffer.deallocate(capacity: 1)
        }

        while true {
            let bytesRead = try readBytes(into: buffer, size: 1)

            if bytesRead > 0 {
                let character = UnicodeScalar(buffer[0])
                return character     
            }
        }         

    }

}

// MARK: Transmitting

extension SerialPort {

    public func writeBytes(from buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw PortError.mustBeOpen
        }

        let bytesWritten = write(fileDescriptor, buffer, size)
        return bytesWritten
    }

    public func writeData(_ data: Data) throws -> Int {
        let size = data.count
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        defer {
            buffer.deallocate(capacity: size)
        }

        data.copyBytes(to: buffer, count: size)

        let bytesWritten = try writeBytes(from: buffer, size: size)
        return bytesWritten
    }

    public func writeString(_ string: String) throws -> Int {
        guard let data = string.data(using: String.Encoding.utf8) else {
            throw PortError.stringsMustBeUTF8
        }

        return try writeData(data)
    }

    public func writeChar(_ character: UnicodeScalar) throws -> Int{
        let stringEquiv = String(character)
        let bytesWritten = try writeString(stringEquiv)
        return bytesWritten
    }
}
