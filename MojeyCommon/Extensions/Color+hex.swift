//
//  Color+hex.swift
//  Mojey
//
//  Created by Todd Bowden on 11/6/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {

    var hex: String {
        guard let cgColor = self.cgColor else { return "" }
        guard let rgb = cgColor.components?.prefix(3) else { return "" }
        guard rgb.count == 3 else { return "" }
        let r = Data([UInt8(rgb[0] * 255)]).hex
        let g = Data([UInt8(rgb[1] * 255)]).hex
        let b = Data([UInt8(rgb[2] * 255)]).hex
        return r + g + b

    }



    init(hex: String) {
        guard hex.count >= 6 else {
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
            return
        }
        var hex = hex
        let r = Color.decimal(hexDigit: hex.removeFirst()) * 16 + Color.decimal(hexDigit: hex.removeFirst())
        let g = Color.decimal(hexDigit: hex.removeFirst()) * 16 + Color.decimal(hexDigit: hex.removeFirst())
        let b = Color.decimal(hexDigit: hex.removeFirst()) * 16 + Color.decimal(hexDigit: hex.removeFirst())

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }



    private static func decimal(hexDigit: Character) -> UInt8 {
        switch hexDigit.lowercased() {
        case "0": return 0
        case "1": return 1
        case "2": return 2
        case "3": return 3
        case "4": return 4
        case "5": return 5
        case "6": return 6
        case "7": return 7
        case "8": return 8
        case "9": return 9
        case "a": return 10
        case "b": return 11
        case "c": return 12
        case "d": return 13
        case "e": return 14
        case "f": return 15
        default: return 0
        }
    }


}
