//
//  AppAttestationTrust.swift
//  AttestIt
//
//  Created by Todd Bowden on 8/9/20.
//

import Foundation
import DeviceCheck
import CBORCoding
import CryptoKit
import Combine

extension AttestedKeyService {

    struct Assertion: Codable {
        var attestedKey: Data? = nil
        var signature: Data
        var authenticatorData: Data

        var counter: Data {
            var ad = authenticatorData
            ad.removeFirst(33)
            return ad.prefix(4)
        }
    }


    struct FullAttestation: Codable {
        struct AttStmt: Codable {
            var x5c: [Data]
            var receipt: Data
        }

        var fmt: String
        var attStmt: AttStmt
        var authData: Data

        init(data: Data) throws {
            let decoder = CBORDecoder()
            let att = try decoder.decode(FullAttestation.self, from: data)
            self = att
        }
    }


    struct CompactAttestation: Codable {
        var attestedKey: Data
        var clientHash: Data
        var certificateChain: [Data]
        var authData: Data

        init(certificateChain: [Data], authData: Data, attestedKey: Data? = nil, clientHash: Data) {
            self.certificateChain = certificateChain
            self.authData = authData
            self.attestedKey = attestedKey ?? Data()
            self.clientHash = clientHash
        }

        init(fullAttestation: FullAttestation, attestedKey: Data? = nil, clientHash: Data) {
            self.certificateChain = fullAttestation.attStmt.x5c
            self.authData = fullAttestation.authData
            self.attestedKey = attestedKey ?? Data()
            self.clientHash = clientHash
        }

    }


    struct AttestationAuthData {
        var rpid = Data()
        var flags: UInt8 = 0
        var counter = Data()
        var aaguid = Data()
        var credentialId = Data()
        var rest = Data()

        init(authData: Data) {
            var authData = authData
            let requiredLen = 32 + 1 + 4 + 16 + 2 + 32
            guard authData.count >= requiredLen else { return }
            rpid = authData.prefix(32)
            authData.removeFirst(32)
            flags = authData.removeFirst()
            counter = authData.prefix(4)
            authData.removeFirst(4)
            aaguid = authData.prefix(16)
            authData.removeFirst(16)
            authData.removeFirst(2)
            credentialId = authData.prefix(32)
            authData.removeFirst(32)
            rest = authData
        }
    }

}

class AttestedKeyService {

    static let `default` = AttestedKeyService()

    private let attestService = DCAppAttestService.shared

    func generateAttestedKey(clientHash: Data, completion: @escaping (String?, Data?, Error?)->Void) {
        guard attestService.isSupported else {
            return completion(nil, nil, SCError(reason: "Attest service not supported"))
        }
        print(attestService.isSupported)
        attestService.generateKey { (keyId, error) in
            print(error)
            guard let keyId = keyId else { return completion(nil, nil, error) }
            print(keyId)
            self.attestService.attestKey(keyId, clientDataHash: clientHash) { (attestationData, error) in
                completion(keyId, attestationData, error)
            }
        }
    }

    /*
    func verifyAttestation(publicKeyHash: Data, challenge: Data, certificateChain: [Data], authData: Data, teamID: String) -> Bool {
        guard let trustedPublicKey = getTrustedPublicKey(certificateChain: certificateChain) else { return false }
        guard trustedPublicKey.sha256 == publicKeyHash else { return false }
        guard let cert = certificateChain.first else { return false }

        let authDataComp = Attestation.AuthDataComponents(authData: authData)
        guard let appID = (teamID + "." + (Bundle.main.bundleIdentifier ?? "")).data(using: .utf8) else { return false }
        guard authDataComp.rpid == appID.sha256 else { return false }
        guard publicKeyHash == authDataComp.credentialId else { return false }

        return verifyNonce(challenge: challenge, authData: authData, cert: cert)
    }
    */

    func getVerifiedPublicKey(fullAttestation: AttestedKeyService.FullAttestation, clientHash: Data, teamId: String) -> Data? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        let appId = teamId + "." + bundleId
        return getVerifiedPublicKey(fullAttestation: fullAttestation, clientHash: clientHash, appId: appId)
    }

    func getVerifiedPublicKey(certificateChain: [Data], authData: Data, clientHash: Data, teamId: String) -> Data? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        let appId = teamId + "." + bundleId
        return getVerifiedPublicKey(certificateChain: certificateChain, authData: authData, clientHash: clientHash, appId: appId)
    }


    func getVerifiedPublicKey(fullAttestation: AttestedKeyService.FullAttestation, clientHash: Data, appId: String) -> Data? {
        let att = fullAttestation
        return getVerifiedPublicKey(certificateChain: att.attStmt.x5c, authData: att.authData, clientHash: clientHash, appId: appId)
    }


    func verifyAttestation(key: Data, certificateChain: [Data], authData: Data, clientHash: Data, teamId: String) -> Bool {
        print(key.hex)
        print(clientHash.hex)
        print(authData.hex)
        print(teamId)
        return getVerifiedPublicKey(certificateChain: certificateChain, authData: authData, clientHash: clientHash, teamId: teamId) == key
    }

    func getVerifiedPublicKey(certificateChain: [Data], authData: Data, clientHash: Data, appId: String) -> Data? {
        guard let trustedPublicKey = getTrustedPublicKey(certificateChain: certificateChain) else { return nil }
        print("Trusted Pub Key = \(trustedPublicKey.hex)")
        guard let cert = certificateChain.first else { return nil }

        let authDataComp = AttestationAuthData(authData: authData)
        guard let appIdData = appId.data(using: .utf8) else { return nil }
        guard authDataComp.rpid == appIdData.sha256 else { return nil }
        guard trustedPublicKey.sha256 == authDataComp.credentialId else { return nil }
        print("a")
        guard verifyNonce(clientHash: clientHash, authData: authData, cert: cert) else { return nil }
        print("b")
        return trustedPublicKey
    }


    func getTrustedPublicKey(certificateChain: [Data]) -> Data? {

       let rootCertB64 = """
            MIICITCCAaegAwIBAgIQC/O+DvHN0uD7jG5yH2IXmDAKBggqhkjOPQQDAzBSMSYwJAYDVQQDDB1BcHBsZSBBcHAgQXR0ZXN0YXRpb24gUm9vdCBDQTETMBEGA1UECgwKQXBwbGUgSW5jLjETMBEGA1UECAwKQ2FsaWZvcm5pYTAeFw0yMDAzMTgxODMyNTNaFw00NTAzMTUwMDAwMDBaMFIxJjAkBgNVBAMMHUFwcGxlIEFwcCBBdHRlc3RhdGlvbiBSb290IENBMRMwEQYDVQQKDApBcHBsZSBJbmMuMRMwEQYDVQQIDApDYWxpZm9ybmlhMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAERTHhmLW07ATaFQIEVwTtT4dyctdhNbJhFs/Ii2FdCgAHGbpphY3+d8qjuDngIN3WVhQUBHAoMeQ/cLiP1sOUtgjqK9auYen1mMEvRq9Sk3Jm5X8U62H+xTD3FE9TgS41o0IwQDAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSskRBTM72+aEH/pwyp5frq5eWKoTAOBgNVHQ8BAf8EBAMCAQYwCgYIKoZIzj0EAwMDaAAwZQIwQgFGnByvsiVbpTKwSga0kP0e8EeDS4+sQmTvb7vn53O5+FRXgeLhpJ06ysC5PrOyAjEAp5U4xDgEgllF7En3VcE3iexZZtKeYnpqtijVoyFraWVIyd/dganmrduC1bmTBGwD
            """
        guard let rootCertData = try? Data(base64: rootCertB64) else { return nil }
        guard let rootCert = SecCertificateCreateWithData(nil, rootCertData as CFData) else  { return nil }

        var certs = [SecCertificate]()
        for certData in certificateChain {
            guard let cert = SecCertificateCreateWithData(nil, certData as CFData) else { return nil }
            certs.append(cert)
        }

        let policy = SecPolicyCreateBasicX509()
        var optionalTrust: SecTrust?
        SecTrustCreateWithCertificates(certs as AnyObject, policy, &optionalTrust)
        guard let trust = optionalTrust else { return nil }

        guard let firstCert = certificateChain.first else { return nil }
        guard let dates = getValidityDates(certificate: firstCert) else { return nil }
        let verifyDate = Date(timeIntervalSince1970: (dates.notBefore.timeIntervalSince1970 + dates.notAfter.timeIntervalSince1970)/2)
        SecTrustSetVerifyDate(trust, verifyDate as CFDate)

        SecTrustSetAnchorCertificates(trust, [rootCert] as CFArray)

        var error: CFError?
        guard SecTrustEvaluateWithError(trust, &error) else {
            print(error?.localizedDescription ?? "")
            return nil
        }

        guard let pubKey = SecTrustCopyKey(trust) else { return nil }
        guard let keyData = SecKeyCopyExternalRepresentation(pubKey, nil) else { return nil }
        return keyData as Data
    }


    func verifyNonce(clientHash: Data, authData: Data, cert: Data) -> Bool {
        let nonce = (authData + clientHash).sha256
        guard let p = cert.firstRange(of: nonce) else { return false }
        return p.startIndex > 0 && p.count == nonce.count
    }


    func generateAssertion(key: Data, hash: Data) -> Future<Assertion,Error> {
        return Future() { promise in
            self.generateAssertion(key: key, hash: hash) { (assertion, error) in
                if let assertion = assertion {
                    promise(Result.success(assertion))
                } else if let error = error {
                    promise(Result.failure(error))
                }
            }
        }
    }


    func generateAssertion(key: Data, hash: Data, completion: @escaping (Assertion?, Error?)->Void) {
        generateAssertion(keyId: key.sha256.base64EncodedString(), hash: hash, completion: completion)
    }

    func generateAssertion(keyId: String, hash: Data, completion: @escaping (Assertion?, Error?)->Void) {
        attestService.generateAssertion(keyId, clientDataHash: hash) { (assertionData, error) in
            if let error = error {
                completion(nil, error)
            }
            if let assertionData = assertionData {
                //print(assertionData.count)
                //print(assertionData.hex)

                let decoder = CBORDecoder()
                do {
                    let assertion = try decoder.decode(AttestedKeyService.Assertion.self, from: assertionData)
                    completion(assertion, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }


    func verifyAssertion(publicKey: Data, signature: Data, clientHash: Data, authData: Data) throws -> Bool {
        let nonce = (authData + clientHash).sha256
        //print("VERIFY ASSERTION nonce = \(nonce.hex)")
        let pk = try P256.Signing.PublicKey(x963Representation: publicKey)
        let sig = try P256.Signing.ECDSASignature(derRepresentation: signature)
        return pk.isValidSignature(sig, for: nonce)
    }

    func verifyAssertion(publicKey: Data, signature: Data, clientHash: Data, counter: Data) throws -> Bool {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            throw SCError(reason: "Unable to get bundleIdentifier")
        }
        guard let appId = (Constants.teamId + "." + bundleId).data(using: .utf8) else {
            throw SCError(reason: "Unable to create app Id")
        }
        let authData = appId.sha256 + [0x40] + counter
        return try verifyAssertion(publicKey: publicKey, signature: signature, clientHash: clientHash, authData: authData)
    }


    // MARK: Der parsing

    private struct DerItem {
        var tag: UInt8 = 0
        var sequence = [DerItem]()
        var data = Data()
    }

    // parse Der sequences. This is all that is needed to get the validity dates out.
    // can update if more data needs to be extracted in the future
    private func parseDerSequence(data: Data) -> [DerItem] {
        var items = [DerItem]()
        var data = data
        while data.count > 0 {
            let tag = data.removeFirst()
            let length = data.removeDerLength()
            guard length > 0 else { break }
            let itemData = data.prefix(length)
            //let tagHex = Data([tag]).hex
            //print("TAG: \(tagHex) LENGTH: \(length) COUNT: \(itemData.count)")
            guard itemData.count == length else { break }
            data.removeFirst(length)
            var item = DerItem(tag: tag)
            if tag == 0x30 {
                item.sequence = parseDerSequence(data: itemData)
            } else {
                item.data = itemData
            }
            items.append(item)
        }
        return items
    }

    private func getValidityDates(certificate: Data) -> (notBefore: Date, notAfter: Date)? {
        let derItems = parseDerSequence(data: certificate)
        guard let datesData = getValidityDates(derItems: derItems) else { return nil }
        guard datesData.count == 2 else { return nil }
        guard let date1 = makeDate(data: datesData[0]) else { return nil }
        guard let date2 = makeDate(data: datesData[1]) else { return nil }
        return (date1, date2)
    }


    private func getValidityDates(derItems: [DerItem]) -> [Data]? {
        for item in derItems {
            if item.sequence.count > 0 {
                if item.sequence.count == 2 && item.sequence[0].tag == 0x17 && item.sequence[1].tag == 0x17 {
                    return [item.sequence[0].data, item.sequence[1].data]
                }
                if let dates = getValidityDates(derItems: item.sequence) {
                    return dates
                }
            }
        }
        return nil
    }

    private func makeDate(data: Data) -> Date? {
        guard let dateString = String(data: data, encoding: .utf8) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmssZ"
        let date = formatter.date(from: dateString)
        return date
    }


    private func printDerItem(_ derItem: DerItem, level: Int = 0) {
        var indent = ""
        for _ in 0...level {
            indent += "   "
        }
        let tagHex = Data([derItem.tag]).hex
        //print(indent + tagHex + " " + derItem.data.hex)
        for item in derItem.sequence {
            //printDerItem(item, level: level + 1)
        }
    }


}


private extension Data {
    mutating func removeDerLength() -> Int {
        guard self.count > 0 else  { return 0 }
        let b = self.removeFirst()
        if b < 128 {
            return Int(b)
        }
        let n = b - 128
        switch n {
        case 1:
            guard self.count > 0 else  { return 0 }
            return Int(self.removeFirst())
        case 2:
            guard self.count > 1 else  { return 0 }
            let b1 = self.removeFirst()
            let b2 = self.removeFirst()
            return (Int(b1) * 256) + Int(b2)
        default:
            return 0
        }
    }
}
