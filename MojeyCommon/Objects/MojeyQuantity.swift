//
//  MojeyQuantity.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/12/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct MojeyQuantity: Equatable {

    static func == (lhs: MojeyQuantity, rhs: MojeyQuantity) -> Bool {
        return lhs.mojey == rhs.mojey && lhs.quantity == rhs.quantity
    }

    var mojey = ""
    var quantity: UInt64 = 0

    mutating func set(mojey: String, quantity: UInt64) {
        self.mojey = mojey
        self.quantity = quantity
    }
}
