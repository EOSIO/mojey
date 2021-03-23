//
//  BluetoothMessageManager.swift
//  Mojey
//
//  Created by Todd Bowden on 7/22/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension BluetoothController {

    enum MessageHeader: UInt8 {
        case v1 = 1
    }

    enum MessageEncryption: UInt8 {
        case none = 0
        case publicKey = 1
    }

    enum MessageType: UInt8 {
        case completeMessage = 10
        case messageReceipt = 11
        case messageResendRequest = 12
        case packet = 20
        case packetResendRequest = 21
    }


    struct Message {
        var messageType = MessageType.completeMessage
        var version: UInt8 = 1
        var messageID: Data
        var senderDeviceKey:  Data
        var signature = Data()
        var data = Data()

        var signable: Data {
            return messageType.rawValue.data + version.data + messageID.varData + senderDeviceKey.varData + data
        }

        var encoded: Data {
            return messageType.rawValue.data + version.data + messageID.varData + senderDeviceKey.varData + signature.varData + data
        }

        init(messageID: Data, senderDeviceKey: Data) {
            self.messageID = messageID
            self.senderDeviceKey = senderDeviceKey
        }

        init(encodedData: Data) {
            var data = encodedData
            messageType = MessageType(rawValue: data.removeFirst()) ?? MessageType.completeMessage
            version = data.removeUInt8()
            messageID = data.removeVarData()
            senderDeviceKey = data.removeVarData()
            signature = data.removeVarData()
            self.data = data
        }
    }
    

    struct MessageReceipt {
        var messageType = MessageType.messageReceipt
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var messageID: Data
        var signature = Data()

        var signable: Data {
            return version.data + senderDeviceKey.varData + messageID.varData
        }

        var encoded: Data {
            return version.data + senderDeviceKey.varData + messageID.varData + signature
        }

        init(messageID: Data, senderDeviceKey: Data) {
            self.messageID = messageID
            self.senderDeviceKey = senderDeviceKey
        }

        init(encodedData: Data) {
            var data = encodedData
            messageType = MessageType(rawValue: data.removeFirst()) ?? MessageType.messageReceipt
            version = data.removeUInt8()
            senderDeviceKey = data.removeVarData()
            messageID = data.removeVarData()
            signature = data
        }
    }


    struct MessageResendRequest {
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var messageID: Data
        var signature: Data

        var encoded: Data {
            return version.data + senderDeviceKey.varData + messageID.varData + signature
        }

        init(encodedData: Data) {
            var data = encodedData
            version = data.removeUInt8()
            senderDeviceKey = data.removeVarData()
            messageID = data.removeVarData()
            signature = data
        }
    }


    struct PacketResendRequest {
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var messageID: Data
        var bytesPerPacketNumber: UInt8 = 1
        var packetNumbers: Data

        var encoded: Data {
            return version.data + senderDeviceKey.varData + messageID.varData + bytesPerPacketNumber.data + packetNumbers
        }

        //init()

        init(encodedData: Data) {
            var data = encodedData
            version = data.removeUInt8()
            senderDeviceKey = data.removeVarData()
            messageID = data.removeVarData()
            bytesPerPacketNumber = data.removeUInt8()
            packetNumbers = data
        }
    }


    struct Packet {
        enum Status {
            case none
            case created
            case sent
            case placeholder
            case validated
            case invalid
        }

        var messageType = MessageType.packet
        var version: UInt8 = 1
        var messageID = Data()
        var packetNumber: UInt16 = 0
        var numberOfPackets: UInt16 = 0
        var checkhash = Data()
        var data = Data()

        var dateReceived: Date?
        var status: Status = .none

        var encoded: Data {
            return messageType.rawValue.data + version.data + messageID.varData + packetNumber.data + packetNumber.data + checkhash.varData + data
        }

        private var hashable: Data {
            return messageType.rawValue.data + version.data + messageID.varData + packetNumber.data + packetNumber.data + data
        }

        mutating func computeCheckhash() {
            checkhash = hashable.sha256.prefix(4)
        }

        var isValid: Bool {
            return checkhash == hashable.sha256.prefix(4)
        }

        mutating func validate() {
            status = isValid ? .validated : .invalid
        }

        init() { }

        init(encodedData: Data) {
            var data = encodedData
            messageType = MessageType(rawValue: data.removeUInt8()) ?? messageType
            version = data.removeUInt8()
            messageID = data.removeVarData()
            packetNumber = data.removeUInt16()
            numberOfPackets = data.removeUInt16()
            checkhash = data.removeVarData()
            self.data = data
            status = .none
        }
    }


    func newMessageID() -> Data {
        let uuid = UUID().uuid
        return Data([uuid.0] + [uuid.2] + [uuid.4] + [uuid.6] + [uuid.8] + [uuid.10] + [uuid.12] + [uuid.14])
    }

    func processIncomming(message: Data) throws {
        guard message.count > 4 else { return }
        var message = message
        let header = message.removeFirst()
        guard header == MessageHeader.v1.rawValue else { return }
        let encryption = message.removeFirst()
        if encryption == MessageEncryption.publicKey.rawValue {
            message = try cryptographyProvider.decrypt(data: message)
        }
        let messageType = MessageType(rawValue: message[0])
        switch messageType {
        case .completeMessage:
            ()
        case .packet:
            let packet = Packet(encodedData: message)
            try processIncomming(packet: packet)
        default:
            ()

        }
    }


    func processIncomming(packet: Packet) throws {
        var packet = packet
        packet.validate()
        if packet.isValid {
            // add to packet set
            let packetSet = packetSets[packet.messageID] ?? PacketSet()
            packetSet.add(packet: packet)
            packetSets[packet.messageID] = packetSet
            if let completeMessage = packetSet.completeMessage {
                packetSets[packet.messageID] = nil
                try processIncomming(message: completeMessage)
            }
        } else {
            // request resend
            //let resendRequest = PacketResendRequest
        }
    }



    class PacketSet {
        var messageID = Data()
        var packets = [Packet]()

        var isComplete: Bool {
            for packet in packets {
                if packet.status != .validated {
                    return false
                }
            }
            return true
        }

        var completeMessage: Data? {
            guard isComplete else { return nil }
            var data = Data()
            for packet in packets {
                data += packet.data
            }
            return data
        }

        func add(packet: Packet) {
            if packets.count == 0 {
                messageID = packet.messageID
                for _ in 0..<packet.numberOfPackets {
                    packets.append(Packet())
                }
            }
            guard packet.messageID == messageID else { return }
            guard packet.packetNumber < packets.count else { return }
            packets[Int(packet.packetNumber)] = packet
        }

    }





}





extension Data {

    mutating func removeUInt8() -> UInt8 {
        return self.removeFirst()
    }

    mutating func removeUInt16() -> UInt16 {
        let d = self.prefix(2)
        guard d.count == 2 else { return 0 }
        self.removeFirst(2)
        return (UInt16(d[0]) * 256) + UInt16(d[1])
    }

    mutating func removeVarData() -> Data {
        guard self.count > 1 else { return Data() }
        let c = Int(self.removeFirst())
        let data = prefix(c)
        self.removeFirst(c)
        return data
    }

    mutating func appendUInt8(_ int: UInt8) {
        self.append(int)
    }

    mutating func appendUInt16(_ int: UInt16) {
        self.append(UInt8(int / 256))
        self.append(UInt8(int % 256))
    }

    mutating func appendVarData(_ data: Data) {
        self.append(UInt8(data.count))
        self.append(data)
    }

    var varData: Data {
        return [UInt8(self.count)] + self
    }

}

extension UInt16 {
    var data: Data {
        return Data([UInt8(self / 256)] + [UInt8(self % 256)])
    }
}

extension UInt8 {
    var data: Data {
        return Data([self])
    }
}
