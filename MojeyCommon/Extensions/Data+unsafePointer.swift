//
//  Data+unsafePointer.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/7/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Data {

    var toUnsafeMutablePointerBytes: UnsafeMutablePointer<UInt8> {
        let pointerBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: self.count)
        self.copyBytes(to: pointerBytes, count: self.count)
        return pointerBytes
    }

    var toUnsafePointerBytes: UnsafePointer<UInt8> {
        return UnsafePointer(self.toUnsafeMutablePointerBytes)
    }





}
