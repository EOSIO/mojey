//
//  AttestedKeyStore.swift
//  Mojey
//
//  Created by Todd Bowden on 8/26/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class AttestedKeyStore {

    static let `default` = AttestedKeyStore()

    private let fileStore = FileStore(.documents, directory: "AttestedKeys")
    private let keychainStore = KeychainStore.default
    private let fullAttestationService = "KeyAttestationsFull"
    private let compactAttestationService = "KeyAttestationsCompact"
    private let assertionService = "KeyAssertions"

    // attested keys by name are stored in the filestore becasue attested keys are deleted if the app is deleted so the attested key would be as well
    // the attestations are stored in the keychain store (which is preserved across app deletion and reinstall becasue order attestions may still need to be validated

    func getAttestedKey(name: String) throws -> Data {
        return try fileStore.read(file: name)
    }

    func saveAttestedKey(name: String, key: Data) throws {
        try fileStore.write(file: name, data: key)
    }

    func getFullAttestation(key: Data) throws -> AttestedKeyService.FullAttestation {
        return try keychainStore.get(name: key.sha256.hex, service: fullAttestationService)
    }

    func saveFullAttestation(key: Data, attestation: AttestedKeyService.FullAttestation) throws {
        try keychainStore.save(name: key.sha256.hex, object: attestation, service: fullAttestationService)
    }

    func getCompactAttestation(key: Data) throws -> AttestedKeyService.CompactAttestation {
        do {
            return try keychainStore.get(name: key.sha256.hex, service: compactAttestationService)
        } catch {
            let fullAttestation = try getFullAttestation(key: key)
            let clientHash = try DeviceKey.deviceKey().uncompressedPublicKey.sha256
            return AttestedKeyService.CompactAttestation(fullAttestation: fullAttestation, attestedKey: key, clientHash: clientHash)
        }
    }

    func haveCompactAttestation(key: Data) -> Bool {
        return (try? getCompactAttestation(key: key)) != nil
    }

    func saveCompactAttestation(key: Data, attestation: AttestedKeyService.CompactAttestation) throws {
        try keychainStore.save(name: key.sha256.hex, object: attestation, service: compactAttestationService)
    }

    func getAssertion(key: Data) throws -> AttestedKeyService.Assertion {
        try keychainStore.get(name: key.sha256.hex, service: assertionService)
    }

    func saveAssertion(key: Data, assertion: AttestedKeyService.Assertion) throws {
        try keychainStore.save(name: key.sha256.hex, object: assertion, service: assertionService)
    }

    func clearCompactAttestations() throws {
        let all: [String:AttestedKeyService.CompactAttestation] = try keychainStore.getAll(service: compactAttestationService)
        for key in all.keys {
            keychainStore.delete(name: key, service: compactAttestationService)
        }
    }
}
