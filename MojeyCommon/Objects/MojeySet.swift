//
//  MojeyBalance.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/8/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct MojeySet: Equatable {

    private(set) var order = [String]()
    private(set) var dictionary = [String: UInt64]()

    var count: Int {
        return dictionary.count
    }

    var total: UInt64 {
        var t: UInt64 = 0
        for (_,q) in dictionary {
            t += q
        }
        return t
    }
    
    var string: String {
        return mojeyDictionaryToString(dictionary)
    }

    func data() throws -> Data {
        guard let d = string.data(using: .utf8) else {
            throw SCError(reason: "Cannot encode \(string) as utf8")
        }
        guard String(data: d, encoding: .utf8) == string else {
            throw SCError(reason: "Fail")
        }
        return d
    }

    func add(mojey: MojeySet, verify: Bool = true) throws -> MojeySet {
        var resultDict = dictionary
        for (m, q) in mojey.dictionary {
            resultDict[m] = (self.dictionary[m] ?? 0) + q
        }
        let resultMojeySet = MojeySet(dictionary: resultDict)
        if verify {
            guard try resultMojeySet.subtract(mojey: mojey, verify: false) == self else {
                throw SCError(reason: "Addition verification error")
            }
        }
        return resultMojeySet
    }

 
    func subtract(mojey: MojeySet, verify: Bool = true) throws -> MojeySet {
        var resultDict = dictionary
        for (m, q) in mojey.dictionary {
            let currentQ = dictionary[m] ?? 0
            guard q <= currentQ else {
                throw SCError(reason: "Cannot subtract \(q) \(m) from \(currentQ) \(m)")
            }
            resultDict[m] = currentQ - q
            if resultDict[m] == 0 {
                resultDict[m] = nil
            }
        }
        let resultMojeySet = MojeySet(dictionary: resultDict)
        if verify {
            guard try resultMojeySet.add(mojey: mojey, verify: false) == self else {
                throw SCError(reason: "Subtraction verification error")
            }
        }
        return resultMojeySet
    }


    private func mojeyStringToDictionary(_ string: String) -> [String:UInt64] {
        var dict = [String:UInt64]()
        let array = string.components(separatedBy: ",")
        for item in array {
            let qm = item.components(separatedBy: " ")
            guard qm.count == 2 else { continue }
            let q = qm[0]
            let m = qm[1]
            guard let qInt = UInt64(q) else { continue }
            dict[m] = qInt
        }
        return dict
    }


//    private func mojeyStringToArray(_ string: String, verify: Bool = true) throws -> [MojeyQuantity] {
//        var mqArray = [MojeyQuantity]()
//        let comp = string.components(separatedBy: ",")
//        for item in comp {
//            let qm = item.components(separatedBy: " ")
//            guard qm.count == 2 else { continue }
//            let q = qm[0]
//            let m = qm[1]
//            guard let qInt = UInt64(q) else { continue }
//            mqArray.append(MojeyQuantity(mojey: m, quantity: qInt))
//        }
//        if verify {
//            guard try mojeyArrayToString(mqArray, verify: false) == string else {
//                throw SCError(reason: "Fail")
//            }
//        }
//        return mqArray
//    }
//
//
//    private func mojeyArrayToString(_ array: [MojeyQuantity], verify: Bool = true) throws -> String {
//        var string = ""
//        for mq in array {
//            if string.count > 0 {
//                string = string + ","
//            }
//            string = string + "\(mq.quantity) \(mq.mojey)"
//        }
//        if verify {
//            guard try mojeyStringToArray(string, verify: false) == array else {
//                 throw SCError(reason: "Fail")
//            }
//        }
//        return string
//    }


    private func mojeyDictionaryToString(_ dictionary: [String:UInt64]) -> String {
        var string = ""
        for (m,q) in dictionary {
            if string.count > 0 {
                string = string + ","
            }
            string = string + "\(q) \(m)"
        }
        return string
    }


    private func integrityCheck() throws {
        guard order.sorted() == Array(dictionary.keys).sorted() else {
            throw SCError(reason: "")
        }
    }

    init() { }

    init(dictionary: [String:UInt64]) {
        self.dictionary = dictionary
    }

    init(string: String) {
        self.dictionary = mojeyStringToDictionary(string)
    }

    init(mojeyQuantity: MojeyQuantity) {
        self.dictionary = [mojeyQuantity.mojey : mojeyQuantity.quantity]
        self.order = [mojeyQuantity.mojey]
    }

    init(data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else {
            throw SCError(reason: "Cannot create utf8 string from mojey data")
        }
        self.dictionary = mojeyStringToDictionary(string)
    }

}
