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

    var attestation = Data()

    init(ecKey: Keychain.ECKey) {
        label = ecKey.label
        tag = ecKey.tag
        accessGroup = ecKey.accessGroup
        isSecureEnclave = ecKey.isSecureEnclave
        privateSecKey = ecKey.privateSecKey
        publicSecKey = ecKey.publicSecKey
        uncompressedPublicKey = ecKey.uncompressedPublicKey
        compressedPublicKey = ecKey.compressedPublicKey
    }

}


extension DeviceKey {

    private static let deviceTag = "DEVICE_KEY"

    static func deviceKey(requireAttestation: Bool = false) throws -> DeviceKey {
        let keychain = Keychain(accessGroup: Constants.accessGroup)
        let cloudId = try CloudId.cloudId()
        let deviceKeyArray = try keychain.getAllEllipticCurveKeys(tag: deviceTag + cloudId)
        guard let deviceECKey = deviceKeyArray.first else {
            throw SCError(reason: "No Device Key")
        }
        let deviceKey = DeviceKey(ecKey: deviceECKey)
        if requireAttestation {
            guard let attestation = keychain.getValue(name: "DeviceKeyAttestation" + cloudId, service: "DeviceKey") else {
                throw SCError(reason: "Attestation missing for Device Key " + cloudId)
            }
            deviceKey.attestation = try Data(hex: attestation)
        }
        return deviceKey
    }

    static func createDeviceKeyIfNone(completion: @escaping (DeviceKey?, Error?)->Void) {
        CloudId.shared.cloudId { (cloudId, error) in
            guard let cloudId = cloudId else {
                return completion(nil, error)
            }
            do {
                let key = try deviceKey()
                completion(key, nil)
            } catch {
                createDeviceKey(cloudId: cloudId, completion: completion)
            }
        }
    }

    /// Create DeviceIdentifierKey. 
    private static func createDeviceKey(cloudId: String, completion: (DeviceKey?, Error?)->Void) {
        //let keychain = Keychain(accessGroup: Constants.accessGroup)
        let keyManager = MojeyKeyManager.default

        do {
            let _ = try keyManager.newSecureEnclaveKey(tag: deviceTag + cloudId)
            let key = try deviceKey(requireAttestation: false)

//            guard keychain.saveValue(name: "DeviceKeyAttestation", value: attestation.hex, service: "DeviceKey") else {
//                throw SCError(reason: "Error saving device key attestation")
//            }
//            key.attestation = attestation
            completion(key, nil)
        } catch {
            completion(nil, error.scError)
        }

    }



}
