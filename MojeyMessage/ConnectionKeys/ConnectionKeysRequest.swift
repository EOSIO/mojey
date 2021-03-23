//
//  MessageKeyRequest.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/19/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct ConnectionKeysRequest: Codable {

    var content = Content()
    struct Content: Codable {
        var version = 1
        var id = ""
        var text = ""
        var date = Date()
        var responseKey = Data()
        var senderDevice = DeviceInfo()
    }

    var signatures = Signatures()

}


extension ConnectionKeysRequest {

    static func new(text: String = "") throws -> ConnectionKeysRequest {
        var keysRequest = ConnectionKeysRequest()
        keysRequest.content.id = UUID().uuidString
        keysRequest.content.text = text
        keysRequest.content.senderDevice = try DeviceInfo.currentDevice()
        keysRequest.content.responseKey = try MojeyKeyManager.default.newSecureEnclaveKey(tag: "ConnectionResponse").uncompressedPublicKey
        keysRequest.signatures = try SignatureProvider.default.sign(data: keysRequest.content.toJsonData())
        return keysRequest
    }

    static func decode(hex: String) throws -> ConnectionKeysRequest {
        let data = try Data(hex: hex)
        let decoder = JSONDecoder()
        return try decoder.decode(ConnectionKeysRequest.self, from: data)
    }


}
