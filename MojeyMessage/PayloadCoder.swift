//
//  PayloadCoder.swift
//  MojeyPayload
//
//  Created by Todd Bowden on 10/19/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CryptoKit

extension PayloadCoder {

    enum PayloadType: UInt8 {
        case transfer = 1
        case connectionRequest = 2
        case connectionResponse = 3
        case thanks = 4

        init(_ int: UInt8?) throws {
            guard let int = int else {
                   throw SCError(reason: "PayloadType nil")
               }
            guard let mt = PayloadType(rawValue: int) else {
                throw SCError(reason: "Unknown payload type \(int)")
            }
            self = mt
        }
    }

    enum EncryptionType: UInt8 {
        case none = 0
        case arxanECElGamalAES128 = 1

        init(_ int: UInt8?) throws {
            guard let int = int else {
                throw SCError(reason: "EncryptionType nil")
            }
            guard let et = EncryptionType(rawValue: int) else {
                throw SCError(reason: "Unknown encryption type \(int)")
            }
            self = et
        }
    }
        
    enum EncodingType: UInt8 {
        case jsonUtf8 = 1

        init(_ int: UInt8?) throws {
            guard let int = int else {
                throw SCError(reason: "EncodingType nil")
            }
            guard let et = EncodingType(rawValue: int) else {
                throw SCError(reason: "Unknown encoding type \(int)")
            }
            self = et
        }
    }

}



/*

 Payload Format
 4 byte header: (0-2 reserved for future use)
    0: 0
    1: 0
    2: 0
    4: version
    5...end: payload


 Version 1 Payload
    0: encryption type
    1...end: encrypted payload

 Version 1 Decrypted Payload
    0: PayloadType
    1: Encoding Type
    2...end: encoded payload

 Version 1 Encoded Payload
    0: Encoding Type
    1...end: encoded payload

*/


class PayloadCoder {

    static let `defaut` = PayloadCoder()


    func payloadVersion(payload: Data) throws -> Int {
        guard payload.count >= 4 else {
            throw SCError(reason: "Payload is too short")
        }
        return Int(payload[3])
    }

    
    func stripHeader(payload: Data) throws -> Data {
        guard payload.count >= 4 else {
            throw SCError(reason: "Payload is too short")
        }
        return payload.dropFirst(4)
    }


    func decryptPayload(payload: Data) throws -> Data {
        guard payload.count > 1 else {
            throw SCError(reason: "Cannot decrypt payload of \(payload.count) bytes")
        }
        let encryptionType = try EncryptionType(payload.first)
        let encryptedPayload = payload.dropFirst()
        switch encryptionType {
        case .none:
            return encryptedPayload
        case .arxanECElGamalAES128:
            return try decryptArxanECElGamalAES128(data: encryptedPayload)
        }
    }


    func decryptArxanECElGamalAES128(data: Data) throws -> Data {
        guard data.count > 128 else {
            throw SCError(reason: "Data is too short. \(data.count) bytes.")
        }
        let aesEncryptedKey = data.prefix(128)
        let ciphertext = data.dropFirst(128)
        let aesKeyData = try ArxanEcc.decrypt(message: aesEncryptedKey, key: TFIT_key_iECEGDfastP256dpayload).prefix(16)
        print("AES Key data = \(aesKeyData.hex)")
        print("ciphertext = \(ciphertext)")
        let aesKey = SymmetricKey(data: aesKeyData)
        print("a")
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        print("b")
        return try AES.GCM.open(sealedBox, using: aesKey)
    }


    func payloadType(version: Int, payload: Data) throws -> PayloadType {
        guard payload.count > 1 else {
            throw SCError(reason: "Payload is too short")
        }
        switch version {
        case 1:
            return try PayloadType(payload.first)
        default:
            throw SCError(reason: "Unknown payload version \(version)")
        }
    }

    func stripPayloadType(payload: Data) throws -> Data {
        guard payload.count > 1 else {
            throw SCError(reason: "Payload is too short")
        }
        return payload.dropFirst()
    }


    func decodePayload<T:Decodable>(payload: Data) throws -> T {
        guard payload.count > 1 else {
             throw SCError(reason: "Payload is too short")
        }
        let encoding = try EncodingType(payload.first)
        switch encoding {
        case .jsonUtf8:
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: payload.dropFirst())
        }
    }


    func composePayload<T:Encodable>(_ encodableObject: T, version: UInt8, type: PayloadType, encoding: EncodingType, encryption: EncryptionType) throws -> Data {
        let encodedPayload = try encodePayload(encodableObject, encoding: encoding)
        let typePlusEncodedPayload = Data([type.rawValue] + encodedPayload)
        let encryptedPayload = try encryptPayload(payload: typePlusEncodedPayload, encryption: encryption)
        return [0x00] + [0x00] + [0x00] + [version] + encryptedPayload
    }


    private func encryptPayload(payload: Data, encryption: EncryptionType) throws -> Data {
        switch encryption {
        case .none:
            return [encryption.rawValue] + payload
        case .arxanECElGamalAES128:
            return try [encryption.rawValue] + encryptArxanECElGamalAES128(payload: payload)
        }
    }


    func encryptArxanECElGamalAES128(payload: Data) throws -> Data {
        let aesKey = SymmetricKey.init(size: .bits128)
        let sealedBox = try AES.GCM.seal(payload, using: aesKey)
        let aesKeyData = aesKey.withUnsafeBytes {
            return Data(Array($0))
        }
        print("AES Key data = \(aesKeyData.hex)")
        let aesEncryptedKey = try ArxanEcc.encrypt(message: aesKeyData, key: TFIT_key_iECEGEfastP256epayload)
        guard let combined = sealedBox.combined else {
            throw SCError(reason: "Cannot get sealed box combined")
        }
        return aesEncryptedKey + combined
    }


    private func encodePayload<T:Encodable>(_ encodableObject: T, encoding: EncodingType) throws -> Data {
        switch encoding {
        case .jsonUtf8:
            let data = try encodableObject.toJsonData()
            return [encoding.rawValue] + data
        }
    }
}
