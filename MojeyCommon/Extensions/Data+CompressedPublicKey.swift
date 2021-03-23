
//

import Foundation


public extension Data {


    /// Compresses a public key.
    var toCompressedPublicKey: Data? {
        guard self.count == 65 else { return nil }
        let uncompressedKey = self
        guard uncompressedKey[0] == 4 else { return nil }
        let x = uncompressedKey[1...32] // swiftlint:disable:this identifier_name
        let yLastByte = uncompressedKey[64]
        let flag: UInt8 = 2 + (yLastByte % 2)
        let compressedKey = Data([flag]) + x
        return compressedKey
    }





}
