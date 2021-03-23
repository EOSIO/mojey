//
//  MojeyTransfer.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/4/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Message {

    struct TokenTransferReceipt: MessageEnvelope, Codable {

        enum Status: UInt8, Codable {
            case none = 0
            case received = 1
            case processing = 2
            case complete = 3
            case error = 10
        }

        func type() -> Message.MessageType { return .tokenTransferReceipt }

        var content = Content()
        struct Content: MessageContent {
            var version = 1
            var id = ""
            var date = Date()
            var senderDeviceKey = Data()
            var targetDeviceKey = Data()
            var senderAssertingKey = Data()
            
            var status: Status = .none
            var text = ""
        }

        var attestations: [Message.Attestation]?

        var signatures = Message.Signatures()

        init(id: String? = nil) throws {
            self.content.id = id ?? UUID().uuidString
            self.content.senderDeviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        }

    }
}



extension Message.TokenTransferReceipt {

    static func decode(data: Data) throws -> Message.TokenTransferReceipt {
        let receipt: Message.TokenTransferReceipt = try Message.decode(data: data)
        return receipt
    }

    func getContent() -> MessageContent {
        return content
    }

    // hash the secure data for a mojeyTransfer for signing and later verification
    // if new secure data needs to be added, the version number can be increased
    // non-secure data can be added without having to increase the version num as the hash would not change
    func concat() throws -> Data {
        switch self.content.version {
        case 1:
            let c = self.content
            let data = try
                c.concatBase() +
                "\(c.status.rawValue)".toUtf8Data() +
                c.text.toUtf8Data()
            return data
        default:
            throw SCError(reason: "Cannot hash tt version \(self.content.version)")
        }
    }

}

