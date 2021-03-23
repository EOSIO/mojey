//
//  String+sha.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/8/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension String {

    func sha256Hex() throws -> String {
        return try self.toUtf8Data().sha256.hex
    }


}
