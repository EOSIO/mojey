//
//  NearbyDevice.swift
//
//  Created by Todd Bowden on 5/12/18.
//  Copyright © 2018. All rights reserved.
//

import Foundation
import UIKit

class NearbyDevice {

    var name = "" // ex. "Thomas Hallgren's iPhone"
    var type = "" // ex. "iPhone 11"
    var key = Data()
    var date = Date()
    var icon: UIImage? {
        if type.range(of: "iPad") != nil {
            return UIImage(named: "icon-iPad")
        }
        if type.range(of: "iPhone X") != nil {
            return UIImage(named: "icon-iPhoneX")
        }
        return UIImage(named: "icon-iPhone")
    }

    init(name: String, type: String, key: Data) {
        self.name = name
        self.type = type
        self.key = key
    }
    
}
