//
//  BurnableKeyRequest.swift
//  Mojey
//
//  Created by Todd Bowden on 9/10/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Message {

    struct ConnectionRequest: MessageEnvelope, Codable {

        func type() -> Message.MessageType { return .connectionRequest }

        var content = Content()
        struct Content: MessageContent {
            var version = 1
            var id = ""
            var date = Date()
            var senderDeviceKey = Data()
            var targetDeviceKey = Data()
            var senderAssertingKey = Data()

            // used to encrypt the tokens (deleted after processing)
            var requestBurnableKey = true

            // future: tranfer must be signed with this key to add to local chain
            var requestAttestedKey = true

            // the tokens that will be send.
            // if the receiving device does not have the token definitions it can request them in the ConnectionResponse
            var prospectiveTokens = [Data]()

            // the attested (asserting) keys that will be used to assert the token transfer or to assert a token defenition.
            // if the receiving device does not have the attestations it can request them in the ConnectionResponse
            var prospectiveAssertingKeys = [Data]()
        }

        var signatures = Message.Signatures()

        init(id: String? = nil) throws {
            self.content.id = id ?? UUID().uuidString
            self.content.senderDeviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        }
    }
}



extension Message.ConnectionRequest {

    static func decode(data: Data) throws -> Message.ConnectionRequest {
        let message: Message.ConnectionRequest = try Message.decode(data: data)
        return message
    }

    func getContent() -> MessageContent {
        return content
    }

    func concat() throws -> Data {
        switch self.content.version {
        case 1:
            return try (
                    content.concatBase() +
                    content.requestBurnableKey.data +
                    content.requestAttestedKey.data +
                    content.prospectiveTokens.concat() +
                    content.prospectiveAssertingKeys.concat()
            )
        default:
            throw SCError(reason: "Cannot hash version \(self.content.version)")
        }
    }

}

