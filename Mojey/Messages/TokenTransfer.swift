//
//  MojeyTransfer.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/4/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Message {
 
    struct TokenTransfer: MessageEnvelope { 
        func type() -> Message.MessageType { return .tokenTransfer }

        var content = Content()
        struct Content: MessageContent {
            var version = 1
            var id = ""
            var date = Date()
            var senderDeviceKey = Data()
            var targetDeviceKey = Data()
            var senderAssertingKey = Data()

            var targetAttestedKey = Data() // future: tranfer must be signed with this key to add to local chain
            var encryptionKey = Data() // tokens are encrypted with this key (deleted after processing)
            var encryptedTokens = Data() // the encrypted tokens
            var tokensHash = Data() // hash of the tokens before encryption, should match decrypted tokens hash
        }

        var tokenDefinitions: [CustomToken]?

        var attestations: [Message.Attestation]?

        var signatures = Message.Signatures()

        init(id: String? = nil) throws {
            self.content.id = id ?? UUID().uuidString
            self.content.senderDeviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        }

    }
}


extension Message.TokenTransfer {

    static func decode(data: Data) throws -> Message.TokenTransfer {
        let tokenTransfer: Message.TokenTransfer = try Message.decode(data: data)
        return tokenTransfer
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
                c.targetAttestedKey +
                c.encryptionKey +
                c.encryptedTokens +
                c.tokensHash
            return data
        default:
            throw SCError(reason: "Cannot hash tt version \(self.content.version)")
        }
    }

}

