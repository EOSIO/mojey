//
//  DataExtensions.swift
//  EosioSwift
//
//  Created by Steve McCoole on 1/30/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CommonCrypto

public extension Data {

    private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }

    /// Get a hex-encoded string representation of the data.
    ///
    /// - Returns: Base16 encoded string representation of the data.
    func hexEncodedString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
    }

    /// Return the data as a hex encoded string
    var hex: String {
        return self.hexEncodedString()
    }

    /// Init a `Data` object with a base64 string.
    ///
    /// - Parameter base64: The data encoded as a base64 string.
    /// - Throws: If the string is not a valid base64 string.
    init(base64: String) throws {
        var base64 = base64.replacingOccurrences(of: "=", with: "")
        base64 += String(repeating: "=", count: base64.count % 4)

        guard let data = Data(base64Encoded: base64) else {
            throw SCError(reason: "\(base64) is not a valid base64 string")
        }
        self = data
    }

    /// Init a `Data` object with a hex string.
    ///
    /// - Parameter hex: The data encoded as a hex string.
    /// - Throws: If the string is not a valid hex string.
    init(hex: String) throws {
        guard let data = Data(hexString: hex) else {
            throw SCError(reason: "\(hex) is not a valid hex string")
        }
        self = data
    }

    /// Initializes a data object from a Base16 encoded string.
    ///
    /// - Parameter hexString: A Base16 encoded string.
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2) // swiftlint:disable:this identifier_name
            let k = hexString.index(j, offsetBy: 2) // swiftlint:disable:this identifier_name
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    /// Returns the SHA256 hash of the data.
    var sha256: Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let p = self.toUnsafePointerBytes
        _ = CC_SHA256(p, CC_LONG(self.count), &hash)
        p.deallocate()
        return Data(hash)
    }


    /// Returns the SHA1hash of the data.
    var sha1: Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        let p = self.toUnsafePointerBytes
        _ = CC_SHA1(p, CC_LONG(self.count), &hash)
        p.deallocate()
        return Data(hash)
    }



    

}
