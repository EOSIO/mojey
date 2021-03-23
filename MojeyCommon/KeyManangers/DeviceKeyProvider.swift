//
//  DeviceKey.swift
//
//  Created by Todd Bowden on 7/22/19.
//  Copyright © 2020. All rights reserved.
//

import Foundation

class DeviceKey  {

    /// The label for this key in the Keychain.
    private (set) public var label: String?
    /// The tag for this key in the Keychain.
    private (set) public var tag: String?
    /// The access group for this key in the Keychain.
    private (set) public var accessGroup: String
    /// Is the private key stored in the Secure Enclave?
    private (set) public var isSecureEnclave: Bool
    /// The private SecKey.
    private (set) public var privateSecKey: SecKey
    /// The public SecKey.
    private (set) public var publicSecKey: SecKey
    /// The uncompressed public key in ANSI X9.63 format (65 bytes, starts with 04).
    private (set) public var uncompressedPublicKey: Data
    /// The compressed public key in ANSI X9.63 format (33 bytes, starts with 02 or 03).
    private (set) public var compressedPublicKey: Data

    private (set) public var assertionSignature = Data()
    private (set) public var assertionData = Data()

    init(ecKey: Keychain.ECKey, assertion: (signature: Data, data: Data)?) {
        label = ecKey.label
        tag = ecKey.tag
        accessGroup = ecKey.accessGroup
        isSecureEnclave = ecKey.isSecureEnclave
        privateSecKey = ecKey.privateSecKey
        publicSecKey = ecKey.publicSecKey
        uncompressedPublicKey = ecKey.uncompressedPublicKey
        compressedPublicKey = ecKey.compressedPublicKey
        if let assertion = assertion {
            assertionSignature = assertion.signature
            assertionData = assertion.data
        }
    }

}


extension DeviceKey {

    private static let deviceTag = "DEVICE_KEY_MAIN"
    private static let keychain = Keychain(accessGroup: Constants.accessGroup)

    static func deviceKey() throws -> DeviceKey {
        let keychain = Keychain(accessGroup: Constants.accessGroup)
        var deviceKeyArray: [Keychain.ECKey]
        deviceKeyArray = try keychain.getAllEllipticCurveKeys(tag: deviceTag)
        if deviceKeyArray.count == 0 {
            let _ = try keychain.createSecureEnclaveSecKey(tag: deviceTag, label: nil, accessFlag: nil)
            deviceKeyArray = try keychain.getAllEllipticCurveKeys(tag: deviceTag)
        }
        guard let deviceECKey = deviceKeyArray.first else {
            throw SCError(reason: "No Device Key")
        }
        let deviceKey = DeviceKey(ecKey: deviceECKey, assertion: getAssertion())
        return deviceKey
    }

    static func deviceKey(completion: (Result<DeviceKey,Error>)->Void) {
        do {
            let dk = try deviceKey()
            completion(.success(dk))
        } catch {
            completion(.failure(error))
        }
    }


    private static func service() -> String {
        return deviceTag + "_ASSERTION"
    }

    static func setAssertion(signature: Data, data: Data) {
        let _  = keychain.saveValue(name: deviceTag + "_SIGNATURE", value: signature.hex, service: service())
        let _  = keychain.saveValue(name: deviceTag + "_DATA", value: data.hex, service: service())
    }

    private static func getAssertion() -> (signature: Data, data: Data)? {
        guard let signatureHex = keychain.getValue(name: deviceTag + "_SIGNATURE", service: service()) else { return nil }
        guard let dataHex = keychain.getValue(name: deviceTag + "_DATA", service: service()) else { return nil }
        guard let signature = try? Data(hex: signatureHex) else { return nil }
        guard let data = try? Data(hex: dataHex) else{ return nil }
        return (signature: signature, data: data)
    }


}
