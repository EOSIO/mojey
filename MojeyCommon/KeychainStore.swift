//
//  KeychainStore.swift
//  EmojiOneMessage
//
//  Created by Todd Bowden on 8/31/19.
//  Copyright © 2019 EmojiOne. All rights reserved.
//

import Foundation

class KeychainStore {

    static let `default` = KeychainStore()

    private let keychain = Keychain(accessGroup: Constants.accessGroup)

    func save<T:Encodable>(name: String, object: T, service: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        guard keychain.saveValue(name: name, value: data.hex, service: service) else {
            throw SCError(reason: "Cannot save object \(name)")
        }
    }

    func get<T:Decodable>(name: String, service: String) throws -> T {
        guard let hexData = keychain.getValue(name: name, service: service) else {
            throw SCError(reason: "Cannot find object \(name)")
        }
        let data = try Data(hex: hexData)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

}
