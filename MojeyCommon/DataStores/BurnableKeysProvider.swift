//
//  BurnableKeyProvider..swift
//  Mojey
//
//  Created by Todd Bowden on 10/11/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class BurnableKeysProvider {

    static let `default` = BurnableKeysProvider()

    private let keychain = Keychain(accessGroup: Constants.accessGroup)
    private let immediateUseBurnableKeyTag = "ImmediateUseBurnableKey"

    func newImmediateUseBurnableKey(targetDeviceKey: Data) throws -> Data {
        let key = try keychain.createSecureEnclaveKey(tag: immediateUseBurnableKeyTag, label: targetDeviceKey.hex, accessFlag: nil)
        return key.uncompressedPublicKey
    }

}
