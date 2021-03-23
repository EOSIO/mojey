//
//  BurnableKeyResponse.swift
//  Mojey
//
//  Created by Todd Bowden on 9/10/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Message {

    struct ConnectionResponse: MessageEnvelope, Codable {

        func type() -> Message.MessageType { return .connectionResponse }

        var content = Content()
        struct Content: MessageContent {
            var version = 1
            var id = ""
            var date = Date()
            var senderDeviceKey = Data()
            var targetDeviceKey = Data()
            var senderAssertingKey = Data()
            
            var burnableKey = Data()
            var requestTokenDefinitions = [Data]()
            var requestKeyAttestations = [Data]()

            // will be used to assert the transfer receipt
            var prospectiveAssertingKeys = [Data]()
        }

        var signatures = Message.Signatures()

        init(id: String? = nil) throws {
            self.content.id = id ?? UUID().uuidString
            self.content.senderDeviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        }

    }
}



extension Message.ConnectionResponse {

    static func decode(data: Data) throws -> Message.ConnectionResponse {
        let message: Message.ConnectionResponse = try Message.decode(data: data)
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
                            content.burnableKey +
                            content.requestTokenDefinitions.concat() +
                            content.requestKeyAttestations.concat() +
                            content.prospectiveAssertingKeys.concat()
            )
        default:
            throw SCError(reason: "Cannot hash version \(self.content.version)")
        }
    }

}

