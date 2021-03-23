//
//  SenderDevice.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/24/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

struct DeviceInfo: Codable {
    var key = Data()
    var cloudId = ""
    var name = ""
    var model = ""
    var modelName = ""
}

extension DeviceInfo {

    static func currentDevice() throws  -> DeviceInfo {
        var device = DeviceInfo()
        let deviceKey = try DeviceKey.deviceKey().compressedPublicKey
        device.cloudId = try CloudId.cloudId()
        device.key = deviceKey
        device.name = UIDevice.current.name
        device.model = UIDevice.current.modelIdentifier
        device.modelName = UIDevice.current.modelNameCase.name
        return device
    }

}
