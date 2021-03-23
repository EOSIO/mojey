//
//  AttestationRequest.swift
//  Mojey
//
//  Created by Todd Bowden on 9/10/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CryptoKit

extension Message {

    struct AttestationRequest: Codable {

        func type() -> Message.MessageType { return .attestationRequest }

        var content = Content()
        struct Content: MessageContent {
            var version = 1
            var id = ""
            var date = Date()
            var senderDeviceKey = Data()
            var targetDeviceKey = Data()
            var senderAssertingKey = Data()

            var requestedAttestations = [Data]()
            var requestedAssertions = [Data]()
        }

        // attestation request does not require an assertion signature (that could lead to a endless loop if neither device has an attestation)
        // attestation requests are signed by the sender device key
        var signature = Data()

        init(id: String? = nil) throws {
            self.content.id = id ?? UUID().uuidString
            self.content.senderDeviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        }
    }
}



extension Message.AttestationRequest {

    static func decode(data: Data) throws -> Message.AttestationRequest {
        let message: Message.AttestationRequest = try Message.decode(data: data)
        return message
    }

    func tryEncode(_ encoding: Message.Encoding) throws -> Data {
        return try Message.tryEncode(self, type: type(), encoding: encoding)
    }

    func getContent() -> MessageContent {
        return content
    }

    func concat() throws -> Data {
        switch self.content.version {
        case 1:
            var data = try content.concatBase()
            for a in content.requestedAttestations {
                data += a
            }
            for a in content.requestedAssertions {
                data += a
            }
            return data
        default:
            throw SCError(reason: "Cannot hash version \(self.content.version)")
        }
    }

    func hash() throws -> Data {
        return try concat().sha256
    }

    func digest() throws -> SHA256.Digest {
        return try SHA256.hash(data: concat())
    }

}

