//
//  KeychainStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/31/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class KeychainStore {

    static let `default` = KeychainStore()

    let keychain = Keychain(accessGroup: Constants.accessGroup)

    func save<T:Encodable>(name: String, object: T, service: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)

        if objectExists(name: name, service: service) {
            guard keychain.updateValue(name: name, value: data.hex, service: service) else {
                throw SCError(reason: "Cannot save object \(name)")
            }
        } else {
            guard keychain.saveValue(name: name, value: data.hex, service: service) else {
                throw SCError(reason: "Cannot update object \(name)")
            }
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



    func getAll<T:Decodable>(service: String) throws -> [String:T] {
        guard let dict = keychain.getValues(service: service) else {
            throw SCError(reason: "Cannot find objects for \(service)")
        }
        let decoder = JSONDecoder()
        var result = [String:T]()
        for (name,hexData) in dict {
            let data = try Data(hex: hexData)
            let item = try decoder.decode(T.self, from: data)
            result[name] = item
        }
        return result
    }

    

    func objectExists(name: String, service: String) -> Bool {
        return keychain.getValue(name: name, service: service) != nil
    }


    func delete(name: String, service: String) {
        keychain.delete(name: name, service: service)
    }

}
