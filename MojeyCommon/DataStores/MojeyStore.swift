//
//  MojeyStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/6/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class MojeyStore {

    static let `default` = MojeyStore()

    private let keychain = MojeyKeyManager.default.keychain
    private let secureStore = SecureStore.default
    private let tokenDefinitionStore = CustomTokenDefinitionStore.default


    func getExistingMojey() throws -> MojeyCollection {
        let existingMojeyData = try secureStore.getItem(name: "Mojey")
        print("existing")
        print(String(data: existingMojeyData, encoding: .utf8)!)
        return try MojeyCollection(data: existingMojeyData)
    }


    func getExistingTokenQuantities() throws -> [TokenQuantity] {
        let all = try getExistingMojey().array
        var tokens = [TokenQuantity]()
        for mq in all {
            if mq.mojey.count >= 32, let tokenKey = try? Data(hex: mq.mojey) {
                let tokenDef = tokenDefinitionStore.get(tokenKey: mq.mojey) ?? CustomToken(tokenKey: tokenKey)
                let tq = TokenQuantity(token: tokenDef, quantity: mq.quantity)
                tokens.append(tq)
            }
        }
        return tokens
    }


    // decrement mojey from the secure store, return the amount decremented encrypted with the provided key
    func decrement(mojey: String, encryptionKey: String) throws  -> Data {
        let decrementMojey = try MojeyCollection(string: mojey)

        let encryptionKeyData = try Data(hex: encryptionKey)
        let mojeyData = try decrementMojey.data()
        // encrypt the amout to return, assuming the decrement and save are successful
        let encryptedDecrementMojey = try keychain.encrypt(publicKey: encryptionKeyData, message: mojeyData)

        // decrement state, throw error if not possible
        let existingMojey = try getExistingMojey()
        let newMojey = try existingMojey.subtract(decrementMojey)

        // set new mojey state in secureStore
        let _ = try secureStore.setItem(newMojey.data(), name: "Mojey")

        return encryptedDecrementMojey
    }


    func increment(mojey: String) throws {
        let incrementMojey = try MojeyCollection(string: mojey)

        // increment state, throw error if not possible
        let existingMojey = try getExistingMojey()
        let newMojey = try existingMojey.add(incrementMojey)

        // set new mojey state in secureStore
        let _ = try secureStore.setItem(newMojey.data(), name: "Mojey")
    }


    init() {
        //secureStore.deleteItem(name: "Mojey")
        //try? setInitalMojey()
        printMojeyStore()
    }

    private func setInitalMojey() throws {
        if (try? getExistingMojey()) == nil {
            let initalMojey = try MojeyCollection(string: "❤️:10,😊:25") 
            let _ = try secureStore.setItem(initalMojey.data(), name: "Mojey")
        }

        //let initalMojey = try MojeyCollection(string: "😀:100,😎:200,😺:100,❤️:100,😎:100,👽:100,😻:100,🖖:100")
        //let _ = try secureStore.setItem(initalMojey.data(), name: "Mojey")
    }


    func printMojeyStore() {
        let pubKey = secureStore.getPubKey(name: "Mojey")
        print("\n===[Mojey Store key: \(pubKey)]==================" )
        do {
            let mojey = try getExistingMojey()
            for mq in mojey.array {
                print("\(mq.mojey) \(mq.quantity)")
            }
        } catch {
            print(error)
        }
        print("======================================================================================================" )


    }


}
