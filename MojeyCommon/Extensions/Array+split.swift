//
//  Array+split.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/7/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Array {

    func split(numberOfSubarrays: Int) -> [[Element]] {
        var arrayOfArrays = [[Element]]()
        let minElementsPerArray = Int(self.count / numberOfSubarrays)
        var elementsPerArray = Array<Int>(repeating: minElementsPerArray, count: numberOfSubarrays)
        let remainder = self.count % numberOfSubarrays
        for r in 0..<remainder {
            elementsPerArray[r] += 1
        }
        var a = 0
        for e in elementsPerArray {
            var array = [Element]()
            for i in a..<a+e {
                array.append(self[i])
            }
            arrayOfArrays.append(array)
            a = a + e
        }
        return arrayOfArrays
    }


    func concat() -> Data where Element == Data {
        var concat = Data()
        for element in self {
            concat += element
        }
        return concat
    }

}
