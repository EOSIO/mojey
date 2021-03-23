//
//  String+toCompressedPublicKey.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/2/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension String {

    func toCompressedPublicKey() throws -> String {
        let data = try Data(hex: self)
        if data.count == 33 {
            return self
        }
        guard let compressedPublicKey = data.toCompressedPublicKey else {
            throw SCError(reason: "\(self) is not a valid public key")
        }
        return compressedPublicKey.hex
    }

}
