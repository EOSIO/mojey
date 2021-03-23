//
//  MojeyCollection.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/18/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class MojeyCollection: Equatable {

    static func == (lhs: MojeyCollection, rhs: MojeyCollection) -> Bool {
        return lhs.sortedArray == rhs.sortedArray
    }

    struct Diff {
        var additions = MojeyCollection()
        var removals = MojeyCollection()
    }

    private(set) var array = [MojeyQuantity]()
    private var index = [String:Int]()
    var sortedArray: [MojeyQuantity] {
        return array.sorted(by: { (mq1, mq2) -> Bool in
            return mq1.mojey > mq2.mojey
        })
    }

    var count: Int {
        return array.count
    }

    var total: UInt64 {
        var t: UInt64 = 0
        for mq in array {
            t += mq.quantity
        }
        return t
    }

    var unique: [String] {
        return array.map({ (mq) -> String in
            return mq.mojey
        })
    }

    func string() throws -> String {
        try integrityCheck()
        return try mojeyArrayToString(self.array)
    }

    func data() throws -> Data {
        let string = try self.string()
        guard let d = string.data(using: .utf8) else {
            throw SCError(reason: "Cannot encode \(string) as utf8")
        }
        guard String(data: d, encoding: .utf8) == string else {
            throw SCError(reason: "Fail")
        }
        return d
    }

    subscript<S>(sub: S) -> MojeyQuantity? {
        if let stringSub = sub as? String {
            guard let int = index[stringSub] else { return nil }
            guard int < array.count else { return nil }
            let mq = array[int]
            guard mq.mojey == stringSub else { return nil }
            return mq
        }

        if let intSub = sub as? Int {
            guard intSub < array.count && intSub >= 0 else { return nil }
            return array[intSub]
        }
        return nil
    }


    private func integrityCheck() throws {
        guard index.count == array.count else {
            throw SCError(reason: "index.count != array.count")
        }
        for (m,i) in index {
            guard array[i].mojey == m else {
                throw SCError(reason: "array[i].mojey != m")
            }
        }
    }

    private func rebuildIndex() throws {
        index.removeAll()
        for i in 0..<array.count {
            let mq = array[i]
            guard index[mq.mojey] == nil else {
                throw SCError(reason: "\(mq.mojey) alreay in collection")
            }
            index[mq.mojey] = i
        }
    }


    func add(_ mojeyQuantity: MojeyQuantity) throws -> MojeyCollection {
        return try add(MojeyCollection(mojeyQuantity: mojeyQuantity))
    }


    func add(_ mojeyCollection: MojeyCollection, verify: Bool = true) throws -> MojeyCollection {
        try integrityCheck()
        var resultArray = self.array
        for mq in mojeyCollection.array {
            // mojey already exists
            if let i = index[mq.mojey] {
                resultArray[i] = MojeyQuantity(mojey: mq.mojey, quantity: mq.quantity + resultArray[i].quantity)
            } else {
                resultArray.append(mq)
            }
        }
        let resultMojeyCollection = try MojeyCollection(array: resultArray)
        if verify {
            guard try resultMojeyCollection.subtract(mojeyCollection, verify: false) == self else {
                throw SCError(reason: "iFail a")
            }
        }
        return resultMojeyCollection
    }


    func subtract(_ mojeyQuantity: MojeyQuantity) throws -> MojeyCollection {
        return try subtract(MojeyCollection(mojeyQuantity: mojeyQuantity))
    }

    
    func subtract(_ mojeyCollection: MojeyCollection, verify: Bool = true) throws -> MojeyCollection {
        try integrityCheck()
        var resultArray = self.array
        for mq in mojeyCollection.array {
            guard let i = index[mq.mojey] else {
                throw SCError(reason: "Cannot subtract \(mq.quantity) \(mq.mojey) from 0 \(mq.mojey)")
            }
            let smq = array[i]
            guard mq.quantity <= smq.quantity else {
                throw SCError(reason: "Cannot subtract \(mq.quantity) \(mq.mojey) from \(smq.quantity) \(mq.mojey)")
            }
            resultArray[i] = MojeyQuantity(mojey: mq.mojey, quantity: smq.quantity - mq.quantity)
        }
        resultArray = resultArray.filter({ (mq) -> Bool in
            mq.quantity > 0
        })
        let resultMojeyCollection = try MojeyCollection(array: resultArray)
        if verify {
            guard try resultMojeyCollection.add(mojeyCollection, verify: false) == self else {
                throw SCError(reason: "iFail s")
            }
        }
        return resultMojeyCollection
    }

    
    private func mojeyStringToArray(_ string: String, verify: Bool = true) throws -> [MojeyQuantity] {
        var mqArray = [MojeyQuantity]()
        let comp = string.components(separatedBy: ",")
        for item in comp {
            let qm = item.components(separatedBy: ":")
            guard qm.count == 2 else { continue }
            let q = qm[1]
            let m = qm[0]
            guard let qInt = UInt64(q) else { continue }
            mqArray.append(MojeyQuantity(mojey: m, quantity: qInt))
        }
        if verify {
            guard try mojeyArrayToString(mqArray, verify: false) == string else {
                throw SCError(reason: "iFail sta")
            }
        }
        return mqArray
    }


    private func mojeyArrayToString(_ array: [MojeyQuantity], verify: Bool = true) throws -> String {
        var string = ""
        for mq in array {
            if string.count > 0 {
                string = string + ","
            }
            string = string + "\(mq.mojey):\(mq.quantity)"
        }
        if verify {
            guard try mojeyStringToArray(string, verify: false) == array else {
                 throw SCError(reason: "iFail ats")
            }
        }
        return string
    }


    func diff(baseMojeyCollection: MojeyCollection) throws -> Diff {
        var diff = Diff()

        for i in 0..<self.count {
            let mq = array[i]
            if let bmq = baseMojeyCollection[mq.mojey], mq.quantity > bmq.quantity  {
                diff.additions = try diff.additions.add(MojeyQuantity(mojey: mq.mojey, quantity: mq.quantity - bmq.quantity))
            } else {
                diff.additions = try diff.additions.add(mq)
            }
        }

        for i in 0..<baseMojeyCollection.count {
            let bmq = baseMojeyCollection.array[i]
            if let mq = self[bmq.mojey], bmq.quantity > mq.quantity {
                diff.removals = try diff.removals.add(MojeyQuantity(mojey: mq.mojey, quantity: bmq.quantity - mq.quantity))
            } else {
                diff.removals = try diff.removals.add(bmq)
            }
        }

        return diff
    }


    init() { }

    init(string: String) throws {
        self.array = try mojeyStringToArray(string)
        try rebuildIndex()
    }

    init(mojeyQuantity: MojeyQuantity) {
        self.array = [mojeyQuantity]
        self.index[mojeyQuantity.mojey] = 0
    }

    init(array: [MojeyQuantity]) throws {
        self.array = array
        try rebuildIndex()
    }

    init(data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else {
            throw SCError(reason: "Cannot create utf8 string from mojey data")
        }
        self.array = try mojeyStringToArray(string)
        try rebuildIndex()
    }
    


    
}
