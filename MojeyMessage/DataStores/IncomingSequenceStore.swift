//
//  SequenceStore.swift
//  EmojiOne
//
//  Created by Todd Bowden on 10/3/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct IncomingSequence: Codable {
    var headSequence: UInt64 = 0
    var previousValid = [UInt64]()
}


class IncomingSequenceStore {

    static let `default` = IncomingSequenceStore()

    private let keychain = MojeyKeyManager.default.keychain
    private let secureStore = SecureStore.default
    private let namePrefix = "IncomingSequence_"


    func getIncomingSequence(key: String) throws -> IncomingSequence {
        let data = try secureStore.getItem(name: (namePrefix+key))
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(IncomingSequence.self, from: data)
    }


    func setIncomingSequence(_ incomingSequence: IncomingSequence, key: String, sig: Data) throws {
        // verify sig
        let encoder = JSONEncoder()
        let data = try encoder.encode(incomingSequence)
        let _ = try secureStore.setItem(data, name: (namePrefix+key))
    }



}
