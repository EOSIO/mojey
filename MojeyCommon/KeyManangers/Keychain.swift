//
//  Keychain.swift
//  EosioSwiftVault
//
//  Created by Todd Bowden on 7/11/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import Security
import BigInt

/// General class for interacting with the Keychain and Secure Enclave.
public class Keychain {

    /// The accessGroup allows multiple apps (including extensions) in the same team to share the same Keychain.
    public let accessGroup: String

    /// Init with accessGroup. The accessGroup allows multiple apps (including extensions) in the same team to share the same Keychain.
    ///
    /// - Parameter accessGroup: The access group should be an `App Group` on the developer account.
    public init(accessGroup: String) {
        self.accessGroup = accessGroup
    }

    /// Save a value to the Keychain.
    ///
    /// - Parameters:
    ///   - name: The name associated with this item.
    ///   - value: The value to save.
    ///   - service: The service associated with this item.
    /// - Returns: True if saved, otherwise false.
    public func saveValue(name: String, value: String, service: String) -> Bool {
        guard let data = value.data(using: String.Encoding.utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessGroup as String: accessGroup,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrSynchronizable as String: false,
            kSecAttrIsInvisible as String: true
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Update a value in the Keychain.
    ///
    /// - Parameters:
    ///   - name: The name associated with this item.
    ///   - value: The updated value.
    ///   - service: The service associated with this item.
    /// - Returns: True if updated, otherwise false.
    public func updateValue(name: String, value: String, service: String) -> Bool {
        guard let data = value.data(using: String.Encoding.utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name,
            kSecAttrService as String: service,
            kSecAttrAccessGroup as String: accessGroup
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }

    /// Delete an item from the Keychain.
    ///
    /// - Parameters:
    ///   - name: The name of the item to delete.
    ///   - service: The service associated with this item.
    public func delete(name: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name,
            kSecAttrService as String: service,
            kSecAttrAccessGroup as String: accessGroup
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Get a value from the Keychain.
    ///
    /// - Parameters:
    ///   - name: The name of the item.
    ///   - service: The service associated with this item.
    /// - Returns: The value for the specified item.
    public func getValue(name: String, service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: name,
            kSecAttrService as String: service,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        let data = item as! CFData // swiftlint:disable:this force_cast
        guard let value = String(data: data as Data, encoding: .utf8) else { return nil }
        return value
    }

    /// Get a dictionary of values from the Keychain for the specified service.
    ///
    /// - Parameter service: A service name.
    /// - Returns: A dictionary of names and values for the specified service.
    public func getValues(service: String) -> [String: String]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccessGroup as String: accessGroup,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true,
            kSecReturnRef as String: true
        ]
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status == errSecSuccess else { return nil }
        var values = [String: String]()

        guard let array = items as? [[String: Any]] else { return nil }
        for item in array {
            if let name = item[kSecAttrAccount as String] as? String, let data = item["v_Data"] as? Data, let value = String(data: data as Data, encoding: .utf8) {
                values[name] = value
            }
        }
        return values
    }

    /// Make query for Key.
    private func makeQueryForKey(key: SecKey) -> [String: Any] {
        return [
            kSecValueRef as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnRef as String: true
        ]
    }



    /// Make query for ecKey.
    private func makeQueryForKey(ecKey: ECKey) -> [String: Any] {
        let query: [String: Any] = [
            kSecValueRef as String: ecKey.privateSecKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnRef as String: true
        ]
        return query
    }

    /// Make query to retrieve all elliptic curve keys in the Keychain.
    private func makeQueryForAllEllipticCurveKeys(tag: String? = nil, label: String? = nil, secureEnclave: Bool = false ) -> [String: Any] {
        var query: [String: Any] =  [
            kSecClass as String: kSecClassKey,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnRef as String: true
        ]
        if let tag = tag {
            query[kSecAttrApplicationTag as String] = tag
        }
        if let label = label {
            query[kSecAttrLabel as String] = label
        }
        if secureEnclave {
            query[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }

        return query
    }


    /// Delete key given the SecKey.
    ///
    /// - Parameter secKey: The SecKey to delete.
    public func deleteKey(secKey: SecKey) {
        let query = makeQueryForKey(key: secKey)
        let result = SecItemDelete(query as CFDictionary)
        print("Delete result = \(result)")
    }


    func deleteKey(publicKey: Data) throws {
        let key = try getEllipticCurveKey(publicKey: publicKey)
        deleteKey(secKey: key.privateSecKey)
    }

    public func deleteEllipticCurveKeys(tag: String? = nil, label: String? = nil) {

        guard let keys = try? getAllEllipticCurveKeys(tag: tag, label: label) else { return }
        for key in keys {
            print("TRY DELETE \(key.tag ?? "") \(key.label ?? "")")
            let query = makeQueryForAllEllipticCurveKeys(tag: key.tag, label: key.label, secureEnclave: key.isSecureEnclave)
            SecItemDelete(query as CFDictionary)
            //deleteKey(secKey: key.privateSecKey)
        }
    }


    /*
    /// Delete key if public key exists.
    ///
    /// - Parameter publicKey: The public key of the key to delete.
    public func deleteKey(publicKey: Data) {
        guard let privateSecKey = getPrivateSecKey(publicKey: publicKey) else { return }
        deleteKey(secKey: privateSecKey)
    }
    */

    /// Update label.
    ///
    /// - Parameters:
    ///   - label: The new label value.
    ///   - publicKey: The public key of the key to update.
    public func update(label: String, secKey: SecKey) -> Int32 {
        print("UPDATE \(kSecAttrLabel as String)")
        let query = makeQueryForKey(key: secKey)
        let attributes: [String: Any] = [
            kSecAttrLabel as String: label
        ]
        let result = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        print("UPDATE RESULT: \(result)")
        return result
    }


    func update(publicKey: Data, label: String? = nil, description: String? = nil) throws -> ECKey {
        let uncompressedPublicKey = try uncompressedR1PublicKey(data: publicKey)
        let query: [String: Any] =  [
            kSecClass as String: kSecClassKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecAttrApplicationLabel as String: uncompressedPublicKey.sha1
        ]
        var attributes = [String:Any]()
        if let label = label {
            attributes[kSecAttrLabel as String] = label
        }
        if let description = description {
              attributes[kSecAttrDescription as String] = description
        }
        guard attributes.count > 0 else {
            return try getEllipticCurveKey(publicKey: publicKey)
        }
        let result = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        print("UPDATE RESULT: \(result)")
        guard result == errSecSuccess else {
            throw SCError(reason: "Cannot update \(publicKey.hex) \(result)")
        }
        return try getEllipticCurveKey(publicKey: publicKey)
    }

 

    /// Get elliptic curve key -- getting the key from the Keychain given the key is used for testing.
    public func getSecKey(key: SecKey) -> SecKey? {
        let query = makeQueryForKey(key: key)
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        let key = item as! SecKey // swiftlint:disable:this force_cast
        return key
    }


    public func getAttributes(secKey: SecKey) throws -> [String:Any] {
        let query: [String:Any] = [
            kSecValueRef as String: secKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnRef as String: true,
            kSecReturnAttributes as String: true
        ]
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        if status == errSecItemNotFound {
            return [String: Any]()
        }
        guard status == errSecSuccess else {
            throw SCError(reason: "Get keys query error \(status)")
        }
        guard let attributes = items as? [String: Any] else {
            throw SCError(reason: "items not dictionary")
        }
        return attributes
    }



    /// Get all attributes for elliptic curve keys with option to filter by tag.
    ///
    /// - Parameter tag: The tag to filter by (defaults to `nil`).
    /// - Returns: An array of ECKeys.
    /// - Throws: If there is an error in the key query.
    public func getAttributesForAllEllipticCurveKeys(tag: String? = nil, label: String? = nil, matchLimitAll: Bool = true) throws -> [[String: Any]] {
        var query: [String: Any] =  [
            kSecClass as String: kSecClassKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnAttributes as String: true,
            kSecReturnRef as String: true
        ]
        if matchLimitAll {
            query[kSecMatchLimit as String as String] = kSecMatchLimitAll
        } else {
            query[kSecMatchLimit as String as String] = kSecMatchLimitOne
        }
        if let tag = tag {
            query[kSecAttrApplicationTag as String] = tag
        }
        if let label = label {
            query[kSecAttrLabel as String] = label
        }
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        if status == errSecItemNotFound {
            return [[String: Any]]()
        }
        guard status == errSecSuccess else {
            throw SCError(reason: "Get Attributes query error \(status).")
        }
        guard let array = items as? [[String: Any]] else {
            throw SCError(reason: "Get Attributes items not an array of dictionaries.")
        }
        return array
    }


    public func getGroupedAttributesForAllEllipticCurveKeys(tag: String? = nil, label: String? = nil) throws -> [String: [[String: Any]]] {
        let array = try getAttributesForAllEllipticCurveKeys(tag: tag, label: label)
        var dict = [String: [[String: Any]]]()
        for attributes in array {
            let tag = attributes[kSecAttrApplicationTag as String] as? String ?? ""
            let label = attributes[kSecAttrLabel as String] as? String ?? ""
            var group = dict[tag + " " + label] ?? [[String:Any]]()
            group.append(attributes)
            dict[tag + " " + label] = group
        }
        return dict
    }


    func getECKeys(attributesArray: [[String:Any]]) -> [ECKey] {
        var keys = [ECKey]()
        for item in attributesArray {
            if let key = try? ECKey(attributes: item) {
                keys.append(key)
            }
        }
        return keys
    }


    func getEllipticCurveKey(applicationLabel: Data) throws -> ECKey {
        print(applicationLabel.hex)
        let query: [String: Any] =  [
            kSecClass as String: kSecClassKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnAttributes as String: true,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrApplicationLabel as String: applicationLabel
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            throw SCError(reason: "\(applicationLabel) not found.")
        }
        guard status == errSecSuccess else {
            throw SCError(reason: "Get key query error \(status)")
        }
        guard let attributes = item as? [String: Any] else {
            throw SCError(reason: "Cannot get attributes for \(applicationLabel)")
        }
        return try ECKey(attributes: attributes)
    }


    func getEllipticCurveKey(publicKey: Data) throws -> ECKey {
        let uncompressedPublicKey = try uncompressedR1PublicKey(data: publicKey)
        print(uncompressedPublicKey.hex)
        return try getEllipticCurveKey(applicationLabel: uncompressedPublicKey.sha1)
    }


    /*
    func getEllipticCurveKey(tag: String? = nil, label: String? = nil) throws -> ECKey {
        let array = try getAttributesForAllEllipticCurveKeys(tag: tag, label: label, matchLimitAll: false)
        let keys = getECKeys(attributesArray: array)
        guard let key = keys.first else {
            throw SCError(reason: "Key with tag \(tag ?? "nil") and label \(label ?? "nil") not found")
        }
        return key
    }
    */


    /// Get all elliptic curve keys with option to filter by tag.
    ///
    /// - Parameter tag: The tag to filter by (defaults to `nil`).
    /// - Returns: An array of ECKeys.
    /// - Throws: If there is an error in the key query.
    public func getAllEllipticCurveKeys(tag: String? = nil, label: String? = nil) throws -> [ECKey] {
        var keys = [ECKey]()
        let array = try getAttributesForAllEllipticCurveKeys(tag: tag, label: label)
        for attributes in array {
            if let key = try? ECKey(attributes: attributes) {
                keys.append(key)
            } else {
                // if error try to lookup this key again using the applicationLabel (sha1 of the public key)
                if let applicationLabel = attributes[kSecAttrApplicationLabel as String] as? Data, let key = try? getEllipticCurveKey(applicationLabel: applicationLabel) {
                    keys.append(key)
                }
            }
        }
        if keys.count == 0 && array.count > 0 {
            throw SCError(reason: "Unable to create any ECKeys from \(array.count) items.")
        }
        return keys
    }


     /*
    /// Get all elliptic curve keys with option to filter by tag.
    ///
    /// - Parameter tag: The tag to filter by (defaults to `nil`).
    /// - Returns: An array of ECKeys.
    /// - Throws: If there is an error in the key query.
    public func getAllEllipticCurveKeys(tag: String? = nil, label: String? = nil) throws -> [ECKey] {
        var keysDict = [String:ECKey]()
        let dict = try getGroupedAttributesForAllEllipticCurveKeys(tag: tag, label: label)
        for (_, array) in dict {
            guard let attributes = array.first else { continue }
            var array2 = array
            // if both tag and label are defined, run the search again to possibly address the bug of getting public key not working if there are too many items
            let tag = attributes[kSecAttrApplicationTag as String] as? String
            let label = attributes[kSecAttrLabel as String] as? String
            if tag != nil || label != nil {
                //print("\(tag) \(label)")
                array2 = (try? getAttributesForAllEllipticCurveKeys(tag: tag, label: label)) ?? array
            }
            let keys = getECKeys(attributesArray: array2)
            for key in keys {
                if keysDict[key.compressedPublicKey.hex] != nil {
                    print("Duplicate \(key.compressedPublicKey.hex)")
                }
                keysDict[key.compressedPublicKey.hex] = key
            }
        }
        return Array(keysDict.values)
    }



    /// Get all elliptic curve keys with option to filter by tag.
    ///
    /// - Parameter tag: The tag to filter by (defaults to `nil`).
    /// - Returns: An array of ECKeys.
    /// - Throws: If there is an error in the key query.
    public func getAllEllipticCurveKeys(tag: String? = nil, label: String? = nil) throws -> [ECKey] {
        let array = try getAttributesForAllEllipticCurveKeys(tag: tag, label: label)
        print("array.count = \(array.count)")
        var keys = [ECKey]()
        for item in array {
            if let key = ECKey(attributes: item) {
                keys.append(key)
            }
        }
        return keys
    }
     */

    /// Get all elliptic curve private Sec Keys.
    /// For Secure Enclave private keys, the SecKey is a reference. It's not posible to export the actual private key data.
    ///
    /// - Parameter tag: The tag to filter by (defaults to `nil`).
    /// - Returns: An array of SecKeys.
    public func getAllEllipticCurvePrivateSecKeys(tag: String? = nil) -> [SecKey]? {
        let query = makeQueryForAllEllipticCurveKeys(tag: tag)
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status == errSecSuccess else { return nil }
        guard let keys = items as? [SecKey] else { return nil }
        return keys
    }

    /*
    /// Get all elliptic curve keys and return the public keys.
    ///
    /// - Returns: An array of public SecKeys.
    public func getAllEllipticCurvePublicSecKeys() -> [SecKey]? {
        guard let privateKeys = getAllEllipticCurvePrivateSecKeys() else { return nil }
        var publicKeys = [SecKey]()
        for privateKey in privateKeys {
            if let publicKey = SecKeyCopyPublicKey(privateKey) {
                publicKeys.append(publicKey)
            }
        }
        return publicKeys
    }
    */


    /*
    /// Get the private SecKey for the public key if the key exists in the Keychain.
    /// Public key data can be in either compressed or uncompressed format.
    ///
    /// - Parameter publicKey: A public key in either compressed or uncompressed format.
    /// - Returns: A SecKey.
    public func getPrivateSecKey(publicKey: Data) -> SecKey? {
        let
        let query: [String: Any] =  [
            kSecClass as String: kSecClassKey,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnAttributes as String: true,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrApplicationLabel as String: applicationLabel
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        let key = item as! SecKey // swiftlint:disable:this force_cast
        return key


    }
 */

    func ellipticCurveY(x: BigInt, a: BigInt, b: BigInt, p: BigInt, isOdd: Bool) -> BigUInt {
        let y2 = (x.power(3, modulus: p) + (a * x) + b).modulus(p)
        var y = y2.power((p+1)/4, modulus: p)
        let yMod2 = y.modulus(2)
        if isOdd && yMod2 != 1 || !isOdd && yMod2 != 0  {
            y = p - y
        }
        return BigUInt(y)
    }


    func uncompressedR1PublicKey(data: Data) throws -> Data {
        guard let firstByte = data.first else {
            throw SCError(reason: "No key data provided.")
        }
        guard firstByte == 2 || firstByte == 3 || firstByte == 4 else {
            throw SCError(reason: "\(data.hex) is not a valid public key.")
        }
        if firstByte == 4 {
            guard data.count == 65 else {
                throw SCError(reason: "\(data.hex) is not a valid public key. Expecting 65 bytes.")
            }
            return data
        }
        guard data.count == 33 else {
            throw SCError(reason: "\(data.hex) is not a valid public key. Expecting 33 bytes.")
        }

        let xData = data[1..<data.count]
        let x = BigInt(BigUInt(xData))
        // assume secp256r1 (curve used in Secure Enclave)
        let p = BigInt(BigUInt(Data(hexString: "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF")!))
        let a = BigInt(-3)
        let b = BigInt(BigUInt(Data(hexString: "5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B")!))
        let y = ellipticCurveY(x: x, a: a, b: b, p: p, isOdd: firstByte == 3)
        print(y.serialize().hexEncodedString())
          //let yOdd = ellipticCurveY(x: x, a: a, b: b, p: p, isOdd: true)
          //let yEven = ellipticCurveY(x: x, a: a, b: b, p: p, isOdd: false)
          //print("ODD: \(yOdd.serialize().hexEncodedString())")
          //print("EVEN: \(yEven.serialize().hexEncodedString())")
        let four: UInt8 = 4
        return [four] + xData + y.serialize()
    }


    func createEllipticCurvePublicKey(data: Data) throws -> SecKey {
        let options: [String:Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ]

        let keyData = try uncompressedR1PublicKey(data: data)
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(keyData as CFData, options as CFDictionary, &error) else {
            throw SCError(reason: "Unable to create key from \(data.hex). \(error.debugDescription)")
        }
        //print(key)
        return key
    }


    /// Create a **NON**-Secure-Enclave elliptic curve private key.
    ///
    /// - Parameter isPermanent: Is the key stored permanently in the Keychain?
    /// - Returns: A SecKey.
    public func createEllipticCurvePrivateKey(isPermanent: Bool = false) -> SecKey? {

        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, [], nil) else { return nil }

        let attributes: [String: Any] = [
            kSecUseAuthenticationUI as String: kSecUseAuthenticationContext,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: isPermanent,
                kSecAttrAccessControl as String: access
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            return nil
        }
        return privateKey
    }

    /*
    /// Import an external elliptic curve private key into the Keychain.
    ///
    /// - Parameters:
    ///   - privateKey: The private key as data (97 bytes).
    ///   - tag: A tag to associate with this key.
    ///   - label: A label to associate with this key.
    /// - Returns: The imported key as an ECKey.
    /// - Throws: If the key is not valid or cannot be imported.
    public func importExternal(privateKey: Data, tag: String? = nil, label: String?  = nil) throws -> ECKey {

        //check data length
        guard privateKey.count == 97 else {
            throw SCError(reason: "Private Key data should be 97 bytes, found \(privateKey.count) bytes")
        }

        let publicKey = privateKey.prefix(65)
        if getEllipticCurveKey(publicKey: publicKey) != nil {
            throw SCError(reason: "Key already exists")
        }

        guard let access = makeSecSecAccessControl(secureEnclave: false) else {
            throw SCError(reason: "Error creating Access Control")
        }

        var attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrAccessGroup as String: accessGroup,
            kSecAttrIsPermanent as String: true,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrAccessControl as String: access
            ]
        ]
        if let tag = tag {
            attributes[kSecAttrApplicationTag as String] = tag
        }
        if let label = label {
            attributes[kSecAttrLabel as String] = label
        }

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(privateKey as CFData, attributes as CFDictionary, &error) else {
            print(error.debugDescription)
            throw SCError(reason: error.debugDescription)
        }

        attributes = [
            kSecClass as String: kSecClassKey,
            kSecValueRef as String: secKey,
            kSecAttrAccessGroup as String: accessGroup
        ]
        if let tag = tag {
            attributes[kSecAttrApplicationTag as String] = tag
        }
        if let label = label {
            attributes[kSecAttrLabel as String] = label
        }

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SCError(reason: "Unable to add key \(publicKey) to Keychain")
        }

        guard let key = getEllipticCurveKey(publicKey: publicKey) else {
            throw SCError(reason: "Unable to find key \(publicKey) in Keychain")
        }
        return key
    }
    */

    /// Make SecAccessControl
    private func makeSecSecAccessControl(secureEnclave: Bool, accessFlag: SecAccessControlCreateFlags? = nil) -> SecAccessControl? {
        var flags: SecAccessControlCreateFlags
        if let accessFlag = accessFlag {
            if secureEnclave {
                flags = [.privateKeyUsage, accessFlag]
            } else {
                flags = [accessFlag]
            }
        } else {
            if secureEnclave {
                flags = [.privateKeyUsage]
            } else {
                flags = []
            }
        }

        return SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            nil
        )
    }

    /// Create a new Secure Enclave key.
    ///
    /// - Parameters:
    ///   - tag: A tag to associate with this key.
    ///   - label: A label to associate with this key.
    ///   - accessFlag: accessFlag for this key.
    /// - Returns: A Secure Enclave SecKey.
    /// - Throws: If a key cannot be created.
    public func createSecureEnclaveSecKey(tag: String? = nil, label: String? = nil, accessFlag: SecAccessControlCreateFlags? = nil) throws -> SecKey {
        return try createEllipticCurveSecKey(secureEnclave: true, tag: tag, label: label, accessFlag: accessFlag)
    }

    /// Create a new elliptic curve key.
    ///
    /// - Parameters:
    ///   - secureEnclave: Generate this key in Secure Enclave?
    ///   - tag: A tag to associate with this key.
    ///   - label: A label to associate with this key.
    ///   - accessFlag: The accessFlag for this key.
    /// - Returns: A SecKey.
    /// - Throws: If a key cannot be created.
    public func createEllipticCurveSecKey(secureEnclave: Bool, tag: String? = nil, label: String? = nil, accessFlag: SecAccessControlCreateFlags? = nil) throws -> SecKey {
        guard let access = makeSecSecAccessControl(secureEnclave: secureEnclave, accessFlag: accessFlag) else {
            throw SCError(reason: "Error creating Access Control")
        }

        var attributes: [String: Any] = [
            kSecUseAuthenticationUI as String: kSecUseAuthenticationContext,
            kSecUseOperationPrompt as String: "",
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrAccessGroup as String: accessGroup,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrAccessControl as String: access
            ]
        ]

        if secureEnclave {
            attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }

        if let tag = tag {
            attributes[kSecAttrApplicationTag as String] = tag
        }
        if let label = label {
            attributes[kSecAttrLabel as String] = label
        }

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw SCError(reason: error.debugDescription)
        }
        return privateKey
    }

    /// Create a new elliptic curve key.
    ///
    /// - Parameters:
    ///   - secureEnclave: Generate this key in Secure Enclave?
    ///   - tag: A tag to associate with this key.
    ///   - label: A label to associate with this key.
    ///   - protection: Accessibility defaults to whenUnlockedThisDeviceOnly.
    ///   - accessFlag: The accessFlag for this key.
    /// - Returns: An ECKey.
    /// - Throws: If a key cannot be created.
    public func createEllipticCurveKey(secureEnclave: Bool, tag: String? = nil, label: String? = nil,
                                       accessFlag: SecAccessControlCreateFlags? = nil) throws -> ECKey {

        let secKey = try createEllipticCurveSecKey(secureEnclave: secureEnclave, tag: tag, label: label, accessFlag: accessFlag)

        var keyatt: [String: Any] = [
            kSecAttrAccessGroup as String: accessGroup,
            kSecValueRef as String: secKey
        ]
        if let tag = tag {
            keyatt[kSecAttrApplicationTag as String] = tag
        }
        if let label = label {
            keyatt[kSecAttrLabel as String] = label
        }
        let key = try ECKey(attributes: keyatt)
        return key
    }

    public func createSecureEnclaveKey(tag: String? = nil, label: String? = nil,
                                       accessFlag: SecAccessControlCreateFlags? = nil) throws -> ECKey {
        return try createEllipticCurveKey(secureEnclave: true, tag: tag, label: label, accessFlag: accessFlag)
    }


    /// Sign if the key is in the Keychain.
    ///
    /// - Parameters:
    ///   - publicKey: The public key corresponding to a private key to use for signing.
    ///   - data: The data to sign.
    /// - Returns: A signature.
    /// - Throws: If private key is not available.
    public func sign(publicKey: Data, data: Data) throws -> Data {
        return try sign(publicKey: publicKey, hash: data.sha256)
    }

    /// Sign if the key is in the Keychain.
    ///
    /// - Parameters:
    ///   - publicKey: The public key corresponding to a private key to use for signing.
    ///   - data: The data to sign.
    /// - Returns: A signature.
    /// - Throws: If private key is not available.
    public func sign(publicKey: Data, hash: Data) throws -> Data {
        let key = try getEllipticCurveKey(publicKey: publicKey)
        return try sign(privateKey: key.privateSecKey, hash: hash)
    }

    
    public func sign(publicKey: Data, hash: Data, completion: (Data?,Error?)->Void) {
        do {
            let sig = try sign(publicKey: publicKey, hash: hash)
            completion(sig,nil)
        } catch {
            completion(nil,error)
        }
    }


    /// Sign with Secure Enclave or Keychain.
    ///
    /// - Parameters:
    ///   - privateKey: The private key to use for signing.
    ///   - data: The data to sign.
    /// - Returns: A signature.
    /// - Throws: If an error is encountered attempting to sign.
    public func sign(privateKey: SecKey, hash: Data) throws -> Data {
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureDigestX962SHA256
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            throw SCError(reason: "Algorithm \(algorithm) is not supported")
        }
        var error: Unmanaged<CFError>?
        guard let der = SecKeyCreateSignature(privateKey, algorithm, hash as CFData, &error) else {
            throw SCError(reason: error.debugDescription)
        }
        return der as Data
    }




    func verifyWithEllipticCurvePublicKey(keyData: Data, message: Data, signature: Data) throws -> Bool {
        return try verifyWithEllipticCurvePublicKey(keyData: keyData, hash: message.sha256, signature: signature)
    }


    func verifyWithEllipticCurvePublicKey(keyData: Data, hash: Data, signature: Data) throws -> Bool {
        print("verifyWithEllipticCurvePublicKey key = \(keyData.hex)")
        print(signature.hex)
        let publicKey = try createEllipticCurvePublicKey(data: keyData)
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureDigestX962SHA256
        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey, algorithm, hash as CFData, signature as CFData, &error)
        if let error = error {
            throw SCError(reason: "\(error)")
        }
        return result
    }


    // Encrypt data using SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
    func encrypt(publicKey: Data, message: Data) throws -> Data {
        // if publicKey is compressed form, get the uncompressed form
        let uncompressedPublicKey = try uncompressedR1PublicKey(data: publicKey)

        let attributes: [String:Any] = [
            kSecAttrKeyType as String:              kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String:             kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String:        256,
            kSecAttrIsPermanent as String:          false,
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(uncompressedPublicKey as CFData, attributes as CFDictionary, &error) else {
            throw SCError(reason: error.debugDescription)
        }

        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard let encryptedData = SecKeyCreateEncryptedData(secKey, algorithm, message as CFData, &error) else {
            throw SCError(reason: error.debugDescription)
        }
        return encryptedData as Data
    }


    /// Decrypt data using `SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM`.
    ///
    /// - Parameters:
    ///   - publicKey: The public key corresponding to a private key to use for decrypting.
    ///   - message: The encrypted message.
    /// - Returns: The decrypted message.
    /// - Throws: If the private key is not found or the message cannot be decrypted.
    public func decrypt(publicKey: Data, message: Data) throws -> Data {
        // lookup ecKey in the Keychain
        let ecKey = try getEllipticCurveKey(publicKey: publicKey)
        // decrypt
        print("DECRYPT1: \(message.hex)")
        var error: Unmanaged<CFError>?
        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard let decryptedData = SecKeyCreateDecryptedData(ecKey.privateSecKey, algorithm, message as CFData, &error) else {
            throw SCError(reason: error.debugDescription)
        }
        return decryptedData as Data
    }

    /// Decrypt data using `SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM`.
    ///
    /// - Parameters:
    ///   - privateSecKey: The  private key to use for decrypting.
    ///   - message: The encrypted message.
    /// - Returns: The decrypted message.
    /// - Throws: If the private key is not found or the message cannot be decrypted.
    public func decrypt(privateSecKey: SecKey, message: Data) throws -> Data {
        // decrypt
        print("DECRYPT2: \(message.hex)")
        var error: Unmanaged<CFError>?
        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard let decryptedData = SecKeyCreateDecryptedData(privateSecKey, algorithm, message as CFData, &error) else {
            throw SCError(reason: error.debugDescription)
        }
        return decryptedData as Data
    }

    func decryptAndDeleteSecureEnclaveKey(message: Data, publicKey: Data, tag: String? = nil) throws -> Data {
        print("decryptAndDeleteKey")
        // lookup ecKey in the Keychain
        let ecKey = try getEllipticCurveKey(publicKey: publicKey)
        guard ecKey.isSecureEnclave else {
            throw SCError(reason: "\(publicKey.hex) not a secure key")
        }
        print("ecKey.privateSecKey \(ecKey.privateSecKey) \(ecKey.privateSecKey.publicKey?.externalRepresentation?.hex ?? "")")
        print("ecKey.isSecureEnclave \(ecKey.isSecureEnclave)")
        print(message.hex)
        let decryptedMessage = try decrypt(privateSecKey: ecKey.privateSecKey, message: message)

        deleteKey(secKey: ecKey.privateSecKey)
        guard (try? getEllipticCurveKey(publicKey: publicKey)) == nil else {
            throw SCError(reason: "Key \(publicKey.hex) not deleted")
        }
        return decryptedMessage
    }

}

public extension Data {

    /// Compress an uncompressed 65 byte public key to a 33 byte compressed public key.
    var compressedPublicKey: Data? {
        if self.count == 33 && (self[0] == 2 || self[0] == 3) { return self }
        guard self.count == 65 else { return nil }
        let uncompressedKey = self
        guard uncompressedKey[0] == 4 else { return nil }
        let x = uncompressedKey[1...32]
        let yLastByte = uncompressedKey[64]
        let flag: UInt8 = 2 + (yLastByte % 2)
        let compressedKey = Data([flag]) + x
        return compressedKey
    }

}

public extension SecKey {

    /// The externalRepresentation of a SecKey in ANSI X9.63 format.
    var externalRepresentation: Data? {
        var error: Unmanaged<CFError>?
        if let cfdata = SecKeyCopyExternalRepresentation(self, &error) {
            return cfdata as Data
        }
        return nil
    }

    /// The public key for a private SecKey.
    var publicKey: SecKey? {
        return SecKeyCopyPublicKey(self)
    }

}
