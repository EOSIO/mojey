//
//  TokenQuantity.swift
//  Mojey
//
//  Created by Todd Bowden on 12/3/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct TokenQuantity: Equatable {

    static func == (lhs: TokenQuantity, rhs: TokenQuantity) -> Bool {
        return lhs.token == rhs.token && lhs.quantity == rhs.quantity
    }

    var token: CustomToken
    var quantity: UInt64 = 0

    mutating func set(token: CustomToken, quantity: UInt64) {
        self.token = token
        self.quantity = quantity
    }
}
