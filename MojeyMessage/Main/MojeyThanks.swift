//
//  MojeyThanks.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 1/28/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct MojeyThanks: Codable {

    var content = Content()
    struct Content: Codable {
        var version = 1
        var id = ""
        var date = Date()
        var senderDevice = DeviceInfo()
        var targetDevice = DeviceInfo()
        var encryptionPubKey = Data()
        var encryptedBurnableKeys = Data()

    }

    var signatures = Signatures()

    init() { }

}


extension MojeyThanks {

    static func new() throws -> MojeyThanks {
        var mojeyThanks = MojeyThanks()
        mojeyThanks.content.id = UUID().uuidString
        mojeyThanks.content.senderDevice = try DeviceInfo.currentDevice()
        return mojeyThanks
    }

    static func decode(base64: String) throws -> MojeyThanks {
        let data = try Data(urlSafeBase64: base64)
        let decoder = JSONDecoder()
        return try decoder.decode(MojeyThanks.self, from: data)
    }

}
