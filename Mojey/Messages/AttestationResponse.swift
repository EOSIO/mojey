//
//  AttestationRequest.swift
//  Mojey
//
//  Created by Todd Bowden on 9/10/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Message {

    struct AttestationResponse: MessageEnvelope, Codable {

        func type() -> Message.MessageType { return .attestationResponse }

        var content = Content()
        struct Content: MessageContent {
            var version = 1
            var id = ""
            var date = Date()
            var senderDeviceKey = Data()
            var targetDeviceKey = Data()
            var senderAssertingKey = Data()

            var attestations = [Message.Attestation]()
            var assertions = [Message.Assertion]()

            func attestation(key: Data) -> Message.Attestation? {
                return attestations.first { (attestation) -> Bool in
                    attestation.attestedKey == key
                }
            }
        }

        var signatures = Message.Signatures()

        init(id: String? = nil) throws {
            self.content.id = id ?? UUID().uuidString
            self.content.senderDeviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        }
    }
}



extension Message.AttestationResponse {

    static func decode(data: Data) throws -> Message.AttestationResponse {
        let message: Message.AttestationResponse = try Message.decode(data: data)
        return message
    }

    func getContent() -> MessageContent {
        return content
    }

    func concat() throws -> Data {
        switch self.content.version {
        case 1:
            var data = try content.concatBase()
            for a in content.attestations {
                data += a.concat()
            }
            for a in content.assertions {
                data += a.concat()
            }
            return data
        default:
            throw SCError(reason: "Cannot hash version \(self.content.version)")
        }
    }

}

