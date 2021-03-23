//
//  MojeyTransfer.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/4/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct MojeyTransfer: Codable {

    var content = Content()
    struct Content: Codable {
        var version = 1
        var id = ""
        var date = Date()
        var displayMojey = ""
        var senderDevice = DeviceInfo()
        var targetDevice = DeviceInfo()
        var encryptionPubKey = Data()
        var sequence: UInt32 = 0
        var encryptedMojey = Data()
        var encryptedBurnableKeys = Data()

        var numberOfDisplayMojey: Int {
            return displayMojey.components(separatedBy: ",").count
        }
    }

    var signatures = Signatures()

    init() { }
    
}


extension MojeyTransfer {

    static func new() throws -> MojeyTransfer {
        var mojeyTransfer = MojeyTransfer()
        mojeyTransfer.content.id = UUID().uuidString
        mojeyTransfer.content.senderDevice = try DeviceInfo.currentDevice()
        return mojeyTransfer
    }

    static func decode(base64: String) throws -> MojeyTransfer {
        let data = try Data(urlSafeBase64: base64)
        let decoder = JSONDecoder()
        return try decoder.decode(MojeyTransfer.self, from: data)
    }

}
