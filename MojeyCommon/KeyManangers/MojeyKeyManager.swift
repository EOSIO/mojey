//
//  KeyManager.swift
//
//  Created by Todd Bowden on 7/22/19.
//  Copyright © 2020. All rights reserved.
//

import Foundation

class MojeyKeyManager {

    static let `default` = MojeyKeyManager()

    let keychain = Keychain(accessGroup: Constants.accessGroup)


    func doesKeyExist(publicKey: String?) -> Bool {
        return (try? getKey(publicKey: publicKey)) != nil
    }

    func getKey(publicKey: String?) throws -> Keychain.ECKey {
        guard let publicKey = publicKey else {
            throw SCError(reason: "No public key provided")
        }
        let key = try keychain.getEllipticCurveKey(publicKey: Data(hex: publicKey))
        guard key.isSecureEnclave else {
            throw SCError(reason: "Invalid key")
        }
        //guard try validate(ecKey: key) == key.compressedPublicKey.sha256 else {
        //    throw SCError(reason: "aFail")
        //}
        return key
    }


    func newSecureEnclaveKey(tag: String) throws -> Keychain.ECKey {
        let key = try keychain.createSecureEnclaveSecKey(tag: tag, label: nil, accessFlag: nil)
        //key attestation
        guard let newPublicKey = key.publicKey?.externalRepresentation else {
            throw SCError(reason: "")
        }
        let deviceKey = try DeviceKey.deviceKey()
        let signature = try keychain.sign(publicKey: deviceKey.uncompressedPublicKey, data: newPublicKey)
        let attestation = SingleAttestation(version: 1, attestingKey: .deviceKey, publicKey: deviceKey.uncompressedPublicKey, signature: signature)
        let encryptedAttestation = try keychain.encrypt(publicKey: newPublicKey, message: attestation.serialize())
        //let att = "a:d|1|\(deviceKey.uncompressedPublicKey.hex)|\(sig.hex) "
        let ecKey = try keychain.update(publicKey: newPublicKey, label: encryptedAttestation.hex)
        print("=====encryptedAttestation=============================================")
        print(newPublicKey.hex)
        print(ecKey.uncompressedPublicKey.hex)
        print(encryptedAttestation.hex)
        //try _ = validate(ecKey: ecKey)
        print("======================================================================")

        return try keychain.getEllipticCurveKey(publicKey: ecKey.uncompressedPublicKey)
    }

    /*
    func validate(ecKey: Keychain.ECKey) throws -> Data {
        //return ecKey.compressedPublicKey.sha256
        print("VALIDATE \(ecKey.compressedPublicKey.hex)")
        guard let encryptedAttestationHex = ecKey.label else {
            throw SCError(reason: "Empty attestation")
        }
        guard ecKey.isSecureEnclave else {
            throw SCError(reason: "Invalid key")
        }
        let attestationData = try keychain.decrypt(privateSecKey: ecKey.privateSecKey, message: Data(hex: encryptedAttestationHex))
        let attestation = try SingleAttestation(attestationData)
        guard attestation.version == 1 && attestation.attestingKey == .deviceKey else {
            throw SCError(reason: "Inalid version or ak attestation")
        }
        let _ = try! keychain.verifyWithEllipticCurvePublicKey(keyData: attestation.publicKey, message: ecKey.uncompressedPublicKey, signature: attestation.signature)
        // TODO: Validate device key here
        print("PASS Validation \(ecKey.compressedPublicKey.hex)")
        return ecKey.compressedPublicKey.sha256
    }
    */
    
    func deleteKey(publicKey: String?) {
        printAllSecureEnclaveKeys()
        guard let key = try? getKey(publicKey: publicKey) else {
            print("delete key \(publicKey ?? "") NOT FOUND")
            return
        }
        print("delete key \(key.compressedPublicKey)")
        keychain.deleteKey(secKey: key.privateSecKey)

        printAllSecureEnclaveKeys()
    }


    func decrypt(message: Data, key: Data) throws -> Data {
        guard let cKey = key.compressedPublicKey else {
            throw SCError(reason: "Cannot get compressed public key from \(key.hex)")
        }
        let ecKey = try getKey(publicKey: cKey.hex)
        guard ecKey.isSecureEnclave else {
            throw SCError(reason: "\(cKey.hex) not a secure key")
        }
        let decryptedMessage = try keychain.decrypt(privateSecKey: ecKey.privateSecKey, message: message)
        return decryptedMessage
    }


    func decryptAndDeleteKey(message: Data, publicKey: Data, tag: String? = nil) throws -> Data {
        print("decryptAndDeleteKey")
        let ecKey = try getKey(publicKey: publicKey.hex)
        print(ecKey)
        guard ecKey.isSecureEnclave else {
            throw SCError(reason: "\(publicKey.hex) not a secure key")
        }
        print("ecKey.privateSecKey \(ecKey.privateSecKey) \(ecKey.privateSecKey.publicKey?.externalRepresentation?.hex ?? "")")
        print("ecKey.isSecureEnclave \(ecKey.isSecureEnclave)")
        print(message.hex)
        let decryptedMessage = try keychain.decrypt(privateSecKey: ecKey.privateSecKey, message: message)

        deleteKey(publicKey: publicKey.hex)
        guard (try? getKey(publicKey: publicKey.hex)) == nil else {
            throw SCError(reason: "Key \(publicKey.hex) not deleted")
        }
        return decryptedMessage
    }

}


extension MojeyKeyManager {

    struct SingleAttestation {

        enum AttestingKey: UInt8 {
            case deviceKey = 1

            init(_ int: UInt8?) throws {
               guard let int = int else {
                       throw SCError(reason: "Attesting key nil")
                   }
                guard let ak = AttestingKey(rawValue: int) else {
                    throw SCError(reason: "Unknown ak type \(int)")
                }
                self = ak
            }
        }

        var version: UInt8 = 1
        var attestingKey: AttestingKey = .deviceKey
        var publicKey = Data()
        var signature = Data()

        func serialize() throws -> Data {
            switch version {
            case 1:
                return [version] + [attestingKey.rawValue] + publicKey + signature
            default:
                throw SCError(reason: "Cannot serialize version \(version)")
            }
        }

        init(version: UInt8, attestingKey: AttestingKey, publicKey: Data, signature: Data) {
            self.version = version
            self.attestingKey = attestingKey
            self.publicKey = publicKey
            self.signature = signature
        }

        init(_ data: Data) throws {
            guard let v = data.first else {
                throw SCError(reason: "Data is empty")
            }
            version = v
            var data = data.dropFirst()
            switch version {
            case 1:
                attestingKey = try AttestingKey(data.first)
                data = data.dropFirst()
                guard data.count > 65 else {
                    throw SCError(reason: "Pub key data is not valid \(data.count) bytes")
                }
                publicKey = data.prefix(65)
                signature = data.dropFirst(65)
            default:
                throw SCError(reason: "Unknown version \(version)")
            }
        }
    }
}


extension MojeyKeyManager {

    func printAllSecureEnclaveKeys(tag: String? = nil, label: String? = nil) {
        guard let keys = try? keychain.getAllEllipticCurveKeys(tag: tag, label: label) else { return }
        print("\n====[\(keys.count) SECURE ENCLAVE KEYS]==============================================================")
        for key in keys {
            var label = key.label ?? ""
            if label.count > 50 {
                label = label.prefix(50) + "..."
            }
            print("\(key.compressedPublicKey.hex) \(key.tag ?? "") LABEL:\(label)")

        }
        print("===========================================================================================\n")
    }

    func printAllSecureEnclaveKeys2() {
        guard let keys = keychain.getAllEllipticCurvePrivateSecKeys() else { return }
        print("\n====[\(keys.count) SECURE ENCLAVE KEYS2]==============================================================")
        for key in keys {
            print("\(key.publicKey?.externalRepresentation?.hex ?? "")")
        }
        print("===========================================================================================\n")
    }

    func printAttributesForAllSecureEnclaveKeys() {
        guard let att = try? keychain.getAttributesForAllEllipticCurveKeys() else { return }
        print("\n====[\(att.count) SECURE ENCLAVE KEYS Attributes]==============================================================")
        for a in att {
            for (k,v) in a {
                print("\(k): \(v)")
            }
            print(" ")
        }
        print("===========================================================================================\n")
    }

    func printGroupedAttributesForAllEllipticCurveKeysSummary() {
        guard let dict = try? keychain.getGroupedAttributesForAllEllipticCurveKeys() else { return }
        print("\n====[GroupedAttributesForAllEllipticCurveKeysSummary]==============================================================")
        for (tagLabel, array) in dict {
            print("\(tagLabel) \(array.count)")
        }
        print("===========================================================================================\n")
    }

}
