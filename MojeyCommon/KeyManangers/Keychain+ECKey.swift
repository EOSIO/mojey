//
//  Keychain.swift
//  EosioSwiftVault

//  Created by Todd Bowden on 8/13/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

public extension Keychain {

    /// ECKey collects properties into a single object for an elliptic curve key.
    class ECKey {
        /// The label for this key in the Keychain.
        private (set) public var label: String?
        /// The tag for this key in the Keychain.
        private (set) public var tag: String?
        /// The description for this key in the Keychain.
        private (set) public var description: String?
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

        static func new(attributes: [String: Any]) throws -> ECKey {
            if let key = try? ECKey(attributes: attributes) {
                return key
            }
            guard let privkey = attributes[kSecValueRef as String] else {
                throw SCError(reason: "Cannot get private key reference.")
            }
            let privateSecKey = privkey as! SecKey // swiftlint:disable:this force_cast
            guard let pubKey = SecKeyCopyPublicKey(privateSecKey) else {
                throw SCError(reason: "Cannot get public key from private key.")
            }
            let publicSecKey = pubKey
            guard let ucpk = publicSecKey.externalRepresentation else {
                throw SCError(reason: "Cannot get public key external representation.")
            }
            let uncompressedPublicKey = ucpk
            guard uncompressedPublicKey.compressedPublicKey != nil else {
                throw SCError(reason: "Cannot get compressed public key.")
            }
            throw SCError(reason: "Cannot create key")
        }


        /// Init an ECKey.
        ///
        /// - Parameter attributes: A dictionary of attributes from a Keychain query.
        public init(attributes: [String: Any]) throws {
            label = attributes[kSecAttrLabel as String] as? String
            tag = attributes[kSecAttrApplicationTag as String] as? String
            description = attributes[kSecAttrDescription as String] as? String
            accessGroup = attributes[kSecAttrAccessGroup as String] as? String ?? ""
            let tokenID = attributes[kSecAttrTokenID as String] as? String ?? ""
            isSecureEnclave = tokenID == kSecAttrTokenIDSecureEnclave as String
            guard let privkey = attributes[kSecValueRef as String] else {
                print("cannot get privkey")
                throw SCError(reason: "Cannot get private key reference.")
            }
            privateSecKey = privkey as! SecKey // swiftlint:disable:this force_cast
            guard let pubKey = SecKeyCopyPublicKey(privateSecKey) else {
                print("cannot get pubkey")
                print("TAG: \(tag ?? "") LABEL: \(label ?? "")")
                throw SCError(reason: "Cannot get public key from private key.")
            }
            publicSecKey = pubKey
            guard let ucpk = publicSecKey.externalRepresentation else {
                throw SCError(reason: "Cannot get public key external representation.")
            }
            uncompressedPublicKey = ucpk
            guard let cpk = uncompressedPublicKey.compressedPublicKey else {
                print("cannot get cpk")
                throw SCError(reason: "Cannot get compressed public key.")
            }
            compressedPublicKey = cpk
        }
    }
}
