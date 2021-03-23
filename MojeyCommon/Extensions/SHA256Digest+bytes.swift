//
//  SHA256Digest+bytes.swift
//  Mojey
//
//  Created by Todd Bowden on 10/8/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CryptoKit

extension SHA256.Digest {
    var data: Data {
        let bytes = self.map { (element) -> UInt8 in
            return UInt8(element)
        }
        return Data(bytes)
    }
}
