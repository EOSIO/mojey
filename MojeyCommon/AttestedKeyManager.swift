//
//  AttestedKeyManager.swift
//  Mojey
//
//  Created by Todd Bowden on 8/27/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class AttestedKeyManager {

    static let `default` = AttestedKeyManager()

    private let attestedKeyStore = AttestedKeyStore.default
    private let attestedKeyService = AttestedKeyService.default


    func getOrGenerateAttestedKey(name: String, completion: @escaping (Data?, AttestedKeyService.FullAttestation?, Error?)->Void) {
        do {
            let key = try AttestedKeyStore.default.getAttestedKey(name: name)
            let fullAttestation = try AttestedKeyStore.default.getFullAttestation(key: key)
            let deviceKey = try DeviceKey.deviceKey()
            if key == attestedKeyService.getVerifiedPublicKey(fullAttestation: fullAttestation, clientHash: deviceKey.uncompressedPublicKey.sha256, teamId: Constants.teamId) { 
                completion(key, fullAttestation, nil)
            } else {
                generateAndSaveAttestedKey(name: name, completion: completion)
            }
        } catch {
            generateAndSaveAttestedKey(name: name, completion: completion)
        }
    }


    func generateAndSaveAttestedKey(name: String, completion: @escaping (Data?, AttestedKeyService.FullAttestation?, Error?)->Void) {
        var deviceKey: DeviceKey
        do {
            deviceKey = try DeviceKey.deviceKey()
            let clientHash = deviceKey.uncompressedPublicKey.sha256
            attestedKeyService.generateAttestedKey(clientHash: clientHash) { (keyID, attestation, error) in
                guard let keyID = keyID, let attestation = attestation else {
                    return completion(nil, nil, error)
                }
                do {
                    let fullAttestation = try AttestedKeyService.FullAttestation(data: attestation)
                    guard let pubKey = self.attestedKeyService.getVerifiedPublicKey(fullAttestation: fullAttestation, clientHash: clientHash, teamId: Constants.teamId) else {
                        return completion(nil, nil, SCError(reason: "Unable to validate key"))
                    }
                    guard pubKey.sha256.base64EncodedString() == keyID else {
                        return completion(nil, nil, SCError(reason: "Unable to validate keyID"))
                    }

                    try self.attestedKeyStore.saveAttestedKey(name: name, key: pubKey)

                    try self.attestedKeyStore.saveFullAttestation(key: pubKey, attestation: fullAttestation)
                    completion(pubKey, fullAttestation, nil)
                } catch {
                    completion(nil, nil, error)
                }
            }
        } catch {
            completion(nil, nil, error)
        }

    }


    



}
