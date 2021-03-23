//
//  MojeyPackProvider.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/15/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct MojeyPack: Hashable, Identifiable {
    var id = UUID()

    var productIdentifier = ""
    var mojey = [String]()
    var multiplier = 1
    var bonus = ""
    var count = 0
    var price = ""

    var signatures = Signatures()
    struct Signatures: Hashable, Identifiable {
        var id = UUID()
        var sigp = Data()
    }

    func mojeyCollection() throws -> MojeyCollection {
        var array = mojey.map { (mojey) -> MojeyQuantity in
            return MojeyQuantity(mojey: mojey, quantity: UInt64(multiplier))
        }
        if bonus != "" {
            array.append(MojeyQuantity(mojey: bonus, quantity: 1))
        }
        return try MojeyCollection(array: Array(array))
    }

}

class MojeyPackProvider {

    static let `default` = MojeyPackProvider()



    var allCurrentPacks: [MojeyPack] {

        let pack25 = MojeyPack(
            productIdentifier: "test.pack25",
            mojey: ["⏱️", "🧶", "🐵", "💥", "🍎", "😀", "🤩", "🎈", "❤️", "🦊", "🥶", "🍏", "🦄", "🐼", "🥳", "🍔", "👽", "😂", "🥺", "🔥", "🎄", "💣", "🥰", "🎉"],
            bonus: "",
            count: 25,
            price: "")

        let pack50 = MojeyPack(
            productIdentifier: "test.pack50",
            mojey: ["⏱️", "🧶", "🐵", "💥", "🍎", "😀", "🤩", "🎈", "❤️", "🦊", "🥶", "🍏", "🦄", "🐼", "🥳", "🍔", "👽", "😂", "🥺", "🔥", "🎄", "💣", "🥰", "🎉"],
            multiplier: 2,
            bonus: "",
            count: 50,
            price: "")

        let pack100 = MojeyPack(
            productIdentifier: "pack100",
            mojey: ["⏱️", "🧶", "🐵", "💥", "🍎", "😀", "🤩", "🎈", "❤️", "🦊", "🥶", "🍏", "🦄", "🐼", "🥳", "🍔", "👽", "😂", "🥺", "🔥", "🎄", "💣", "🥰", "🎉"],
            multiplier: 4,
            bonus: "",
            count: 100,
            price: "")


        return [pack25, pack50, pack100]
    }


    var allCurrentProductIdentifiers: [String] {
        return allCurrentPacks.map { (pack) -> String in
            return pack.productIdentifier
        }
    }


    func pack(productIdentifier: String) -> MojeyPack? {
        for pack in allCurrentPacks {
            if pack.productIdentifier == productIdentifier {
                return pack
            }
        }
        return nil
    }

    
    func packs(productIdentifiers: [String]) -> [MojeyPack] {
        var packs = [MojeyPack]()
        for pack in allCurrentPacks {
            if productIdentifiers.contains(pack.productIdentifier) {
                packs.append(pack)
            }
        }
        return packs
    }



}
