//
//  Message.swift
//  Mojey
//
//  Created by Todd Bowden on 9/14/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CryptoKit


protocol MessageEnvelope: Codable {
    func type() -> Message.MessageType
    var signatures: Message.Signatures { get set }
    func hash() throws -> Data
    func digest() throws -> SHA256.Digest
    func concat() throws -> Data
    func encode(_ encoding: Message.Encoding) -> Result<Data,Error>
    func tryEncode(_ encoding: Message.Encoding) throws -> Data
    func getContent() -> MessageContent
} 


extension MessageEnvelope {
    func encode(_ encoding: Message.Encoding) -> Result<Data,Error> {
        return Message.encode(self, type: type(), encoding: encoding)
    }

    func tryEncode(_ encoding: Message.Encoding) throws -> Data {
        return try Message.tryEncode(self, type: type(), encoding: encoding)
    }

    func hash() throws -> Data {
        return try concat().sha256
    }

    func digest() throws -> SHA256.Digest {
        return try SHA256.hash(data: concat())
    }
}


protocol MessageContent: Codable {
    var version: Int { get set }
    var id: String { get set }
    var date: Date { get set }
    var senderDeviceKey: Data { get set }
    var targetDeviceKey: Data { get set }
    var senderAssertingKey: Data { get set }
}

extension MessageContent {
    func concatBase() throws -> Data {
        switch version {
        case 1:
            let c = self
            let data = try
                "\(c.version)".toUtf8Data() +
                c.id.toUtf8Data() +
                "\(c.date.timeIntervalSince1970)".toUtf8Data() +
                c.senderDeviceKey +
                c.targetDeviceKey +
                c.senderAssertingKey
            return data
        default:
            throw SCError(reason: "Unsupported version \(version)")
        }
    }
}


enum Message {

    enum MessageType: UInt8 {
        case attestationRequest = 1
        case attestationResponse = 2
        case connectionRequest = 3
        case connectionResponse = 4
        case tokenTransfer = 100
        case tokenTransferReceipt = 101
    }

    enum Encoding: UInt8 {
        case json = 1
        case cbor = 2
    }

    struct Signatures: Codable {
        var sigak = Data()
        var sigakc = Data()
        var sigdk = Data()
    }

    struct Attestation: Codable {
        var attestedKey = Data()
        var clientHash = Data()
        var certificateChain = [Data]()
        var authData = Data()

        func concat() -> Data {
            var concatdata = attestedKey
            concatdata += clientHash
            for c in certificateChain {
                concatdata += c
            }
            concatdata += authData
            return concatdata
        }

        init() { }

        init(compactAttestation: AttestedKeyService.CompactAttestation) {
            self.attestedKey = compactAttestation.attestedKey
            self.clientHash = compactAttestation.clientHash
            self.certificateChain = compactAttestation.certificateChain
            self.authData = compactAttestation.authData
        }
    }

    struct Assertion: Codable {
        var assertedKey = Data()
        var attestingKey = Data()
        var signature = Data()
        var counter = Data()

        func concat() -> Data {
            return assertedKey + attestingKey + signature + counter
        }
    }

    static func decode<M:Decodable>(base64: String) throws -> M {
        let data = try Data(urlSafeBase64: base64)
        let decoder = JSONDecoder()
        return try decoder.decode(M.self, from: data)
    }

    static func decode<M:Decodable>(data: Data) throws -> M {
        var data = data
        guard data.count > 1 else {
            throw SCError(reason: "Cannot decode data of length \(data.count)")
        }
        let encodingUInt8 = data.removeFirst()
        guard let encoding = Message.Encoding(rawValue: encodingUInt8) else {
            throw SCError(reason: "Invalid encoding \(encodingUInt8)")
        }
        switch encoding {
        case .json:
            let decoder = JSONDecoder()
            return try decoder.decode(M.self, from: data)
        default:
            throw SCError(reason: "encoding not supported \(encoding.rawValue)")
        }
    }

    static func tryEncode(_ message: Encodable, type: Message.MessageType, encoding: Message.Encoding) throws -> Data {
        switch encoding {
        case .json:
            let jsonData = try message.toJsonData()
            return [type.rawValue] + [encoding.rawValue] + jsonData
        default:
            throw SCError(reason: "encoding not supported \(encoding.rawValue)")
        }
    }

    static func encode(_ message: Encodable, type: Message.MessageType, encoding: Message.Encoding) -> Result<Data,Error> {
        do {
            let encodedMessage = try tryEncode(message, type: type, encoding: encoding)
            return .success(encodedMessage)
        } catch {
            return .failure(error)
        }
    }

}
