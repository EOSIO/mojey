//
//  BluetoothControllerCryptographyProvider.swift
//  Mojey
//
//  Created by Todd Bowden on 7/15/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class BluetoothControllerCryptographyProvider: BluetoothControllerCryptographyProviderProtocol {

    let keychain = Keychain(accessGroup: Constants.accessGroup)

    private var pubKey: Data?

    func devicePublicKey() throws -> Data {
        if let pubKey = pubKey {
            return pubKey
        }
        let deviceKey = try DeviceKey.deviceKey()
        return deviceKey.uncompressedPublicKey  
        /*
        if let keys = try? keychain.getAllEllipticCurveKeys(tag: "BluetoothDeviceKey", label: nil), let key = keys.first {
            pubKey = key.uncompressedPublicKey
            return key.uncompressedPublicKey
        }
        let key = try keychain.createSecureEnclaveKey(tag: "BluetoothDeviceKey", label: nil, accessFlag: nil)
        pubKey = key.uncompressedPublicKey
        return key.uncompressedPublicKey
        */
    }

    func sign(data: Data) throws -> Data {
        return try keychain.sign(publicKey: devicePublicKey(), data: data)
    }

    func verify(publicKey: Data, data: Data, signature: Data) throws -> Bool {
        return try keychain.verifyWithEllipticCurvePublicKey(keyData: publicKey, message: data, signature: signature)
    }

    func encrypt(key: Data, data: Data) throws  -> Data {
        return try keychain.encrypt(publicKey: key, message: data)
    }

    func decrypt(data: Data) throws -> Data {
        return try keychain.decrypt(publicKey: devicePublicKey(), message: data)
    }

    func sha256(data: Data) -> Data {
        return data.sha256
    }

    func randomBytes() -> Data? {
        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else { return nil }
        return Data(bytes)
    }




}
