//
//  Encodable+toJson.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/22/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Encodable {

    func toJsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dataEncodingStrategy = .base64
        return try encoder.encode(self)
    }

    func toJsonString() throws -> String {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(self)
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw SCError(reason: "Cannot encode json data as utf8")
        }
        return json
    }

    var json: String? {
        return try? toJsonString()
    }

}
