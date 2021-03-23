//
//  Signatures.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/25/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct Signatures: Codable {
    var sigw =  Data()          // signature by whitebox embedded key1
    var sigd =  Data()          // signature by device key
    var sigda =  Data()         // attestation of devicekey by whitebox key2
    var sigax = Data()
}

class SignatureProvider {

    static let `default` = SignatureProvider()

    private let keychain = MojeyKeyManager.default.keychain

    func sign(data: Data) throws -> Signatures {
        //print("---DATA TO SIGN bytes: \(data.count) -----------------------------")
        //print(data.hex)
        //print("-----------------------------------------------")
        var signatures = Signatures()
        let deviceKey = try DeviceKey.deviceKey().uncompressedPublicKey
        signatures.sigd = try keychain.sign(publicKey: deviceKey, data: data)
        signatures.sigax = try ArxanEcc.sign(message: data, key: TFIT_key_iECDSASfastP256a).der

        try verify(signatures: signatures, data: data, deviceKey: deviceKey)

        return signatures
    }

    @discardableResult
    func verify(signatures: Signatures, data: Data, deviceKey: Data) throws -> Bool {
        //print("---DATA TO VERIFY  bytes: \(data.count) ---------------------------")
        //print(data.hex)
        //print("-----------------------------------------------")
        guard try ArxanEcc.verify(signature: signatures.sigax, message: data) else {
            throw SCError(reason: "Fail")
        }
        guard try keychain.verifyWithEllipticCurvePublicKey(keyData: deviceKey, message: data, signature: signatures.sigd) else {
            throw SCError(reason: "Fail")
        }

        return true
    }

}
