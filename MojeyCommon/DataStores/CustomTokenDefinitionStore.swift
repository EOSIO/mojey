//
//  CustomTokenStore.swift
//  Mojey
//
//  Created by Todd Bowden on 11/16/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation


class CustomTokenDefinitionStore {

    static let `default` = CustomTokenDefinitionStore()

    private let keychainStore = KeychainStore.default
    private let service = "CustomTokenStore"


    func get(tokenKey: String) -> CustomToken? {
        return try? keychainStore.get(name: tokenKey, service: service)
    }

    func save(customToken: CustomToken) throws {
        try keychainStore.save(name: customToken.tokenKey.hex, object: customToken, service: service)
    }

    func haveToken(tokenKey: String) -> Bool {
        return get(tokenKey: tokenKey) != nil
    }


}
