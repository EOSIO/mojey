//
//  Bool+data.swift
//  Mojey
//
//  Created by Todd Bowden on 10/15/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Bool {
    var data: Data {
        return self ? Data([UInt8(1)]) : Data([UInt8(0)])
    }
}
