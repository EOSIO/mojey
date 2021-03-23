//
//  BurnableKeysStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/31/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class BurnablePublicKeysStore {

    static let `default` = BurnablePublicKeysStore()

    private let keychainStore = KeychainStore.default
    private let service = "BurnablePublicKeysStore"


    // add burnable keys for device key
    func add(burnablePublicKeys: [String], deviceKey: String) throws {
        var keys = (try? allBurnablePublicKeys(deviceKey: deviceKey)) ?? [String]()
        for key in burnablePublicKeys {
            if !keys.contains(key) {
                keys.append(key)
            }
        }
        try save(burnablePublicKeys: keys, deviceKey: deviceKey)
    }


    // save burnable keys for device key
    private func save(burnablePublicKeys: [String], deviceKey: String) throws {
        try keychainStore.save(name: deviceKey, object: burnablePublicKeys, service: service)
    }


    // return all burnable keys for device key
    func allBurnablePublicKeys(deviceKey: String) throws -> [String] {
        return try keychainStore.get(name: deviceKey, service: service)
    }


    // delete device key
    func delete(deviceKey: String) {
        keychainStore.delete(name: deviceKey, service: service)
    }


    // return the first burnable public key for deviceKey and delete (burn) it
    func burnPublicKey(deviceKey: String) throws -> String {
        var keys = try allBurnablePublicKeys(deviceKey: deviceKey)
        guard keys.count > 0 else {
            throw SCError(reason: "No burnable public keys available for device \(deviceKey)")
        }
        let key = keys[0]
        keys.remove(at: 0)
        try save(burnablePublicKeys: keys, deviceKey: deviceKey)
        return key
    }


    func printAllBurnablePublicKeys(deviceKey: String) {
        do {
            let keys = try allBurnablePublicKeys(deviceKey: deviceKey)
            print("\n====[\(keys.count) Burnable Public Keys for Device \(deviceKey)]============")
            for key in keys {
                print(key)
            }
        } catch {
            print("====[Error for Burnable PublicKeys for Device \(deviceKey)]============")
            print(error.localizedDescription)
        }
        print("==========================================================================================================================================\n")
    }


}
