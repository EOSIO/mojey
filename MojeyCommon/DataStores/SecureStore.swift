//
//  SecureStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/10/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class SecureStore {

    static let `default` = SecureStore()

    private let keychain = Keychain(accessGroup: Constants.accessGroup)
    private let keyManager  = MojeyKeyManager.default

    private let service = "SecureStore"


    func getPubKey(name: String) -> String {
        guard let keys = try? keychain.getAllEllipticCurveKeys(tag: name, label: nil) else {
            return ""
        }
        return keys.first?.compressedPublicKey.hex ?? ""
    }

    func getItem(name: String) throws -> Data {
        guard let encryptedStateString = keychain.getValue(name: name, service: service) else {
            throw SCError(reason: "Cannot find \(name)")
        }
        let encryptedState = try Data(hex: encryptedStateString)
        let keys = try keychain.getAllEllipticCurveKeys(tag: name, label: nil)
        for key in keys {
            if let state = try? keychain.decrypt(privateSecKey: key.privateSecKey, message: encryptedState) {
                return state
            }
        }
        throw SCError(reason: "Unable to get state for \(name)")
    }


    func setItem(_ item: Data, name: String) throws -> Data {

        // get existing key (should actually only be one key) or create if none
        let existingKeys = try keychain.getAllEllipticCurveKeys(tag: name, label: nil)
        let key = try existingKeys.first ?? keyManager.newSecureEnclaveKey(tag: name)

        // encrypt item
        let encryptedItem = try keychain.encrypt(publicKey: key.uncompressedPublicKey, message: item)

        // save encryptedItem
        if objectExists(name: name, service: service) {
            guard keychain.updateValue(name: name, value: encryptedItem.hex, service: service) else {
                throw SCError(reason: "Cannot save object \(name)")
            }
        } else {
            guard keychain.saveValue(name: name, value: encryptedItem.hex, service: service) else {
                throw SCError(reason: "Cannot update object \(name)")
            }
        }

        return encryptedItem
    }


    func deleteItem(name: String) {
        keychain.delete(name: name, service: service)
    }
    
    private func objectExists(name: String, service: String) -> Bool {
        return keychain.getValue(name: name, service: service) != nil
    }

}
