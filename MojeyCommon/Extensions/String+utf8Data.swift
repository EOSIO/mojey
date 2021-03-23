//
//  String+utf8Data.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/8/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension String {

    func toUtf8Data() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw SCError(reason: "Cannot convert \(self) to utf8 data")
        }
        return data
    }


}
