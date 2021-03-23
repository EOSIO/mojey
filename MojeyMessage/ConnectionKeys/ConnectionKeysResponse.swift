//
//  MessageKeysResponse.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/19/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

struct ConnectionKeysResponse: Codable {

    var content = Content()
    struct Content: Codable {
        var version = 1
        var id = ""
        var date = Date()
        var text = ""
        var senderDevice = DeviceInfo()
        var targetDevice = DeviceInfo()
        var encryptionPubKey = Data()
        var encryptedBurnableKeys = Data()
        var encryptedSequenceKey = Data()
    }

    var signatures = Signatures()

    init() { }

}


extension ConnectionKeysResponse {

    static func new() throws -> ConnectionKeysResponse {
        var keysResponse = ConnectionKeysResponse()
        keysResponse.content.id = UUID().uuidString
        keysResponse.content.senderDevice = try DeviceInfo.currentDevice()
        return keysResponse
    }

    static func decode(hex: String) throws -> ConnectionKeysResponse {
        let data = try Data(hex: hex)
        let decoder = JSONDecoder()
        return try decoder.decode(ConnectionKeysResponse.self, from: data)
    }

}

