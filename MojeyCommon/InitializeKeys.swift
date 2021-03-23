//
//  InitializeKeys.swift
//  Mojey
//
//  Created by Todd Bowden on 8/29/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class InitializeKeys {

    // the device key is a se key and the hash of the uncompressed key is the challenge for the main attested key. in turn the attested key is used to assert the device key

    static func initializeKeys() throws {
        let deviceKey = try DeviceKey.deviceKey()
        var initError: Error?
        print("=====init keys========================================================================")
        print(deviceKey.uncompressedPublicKey.hex)
        print(deviceKey.assertionSignature.hex)
        print(deviceKey.assertionData.hex)
        AttestedKeyManager.default.getOrGenerateAttestedKey(name: "Main") { (key, attestation, error) in
            guard let key = key else {
                initError = error
                print(initError?.scError.description)
                return
            }
            //print("=====================================================================================")
            //print(key.hex)
            //print(attestation?.hex ?? "")
            //print("======================================================================================")
            if deviceKey.assertionSignature.count == 0 || deviceKey.assertionData.count == 0 {
                AttestedKeyService.default.generateAssertion(key: key, hash: deviceKey.uncompressedPublicKey.sha256) { (assertion, error) in
                    guard let assertion = assertion else {
                        initError = error
                        return
                    }
                    DeviceKey.setAssertion(signature: assertion.signature, data: assertion.authenticatorData)
                    //print(assertion.signature.hex)
                    //print(assertion.authenticatorData.hex)
                    //print("======================================================================================")
                }
            }
        }

        if let initError = initError {
            print(initError)
            print("======================================================================================")
            throw initError
        }

    }
}


