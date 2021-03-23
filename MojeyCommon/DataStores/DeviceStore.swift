//
//  DeviceStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/31/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class DeviceStore {

    static let `default` = DeviceStore()

    private let keychainStore = KeychainStore.default
    private let service = "DeviceStore"

    func save(deviceInfo: DeviceInfo) throws {
       try keychainStore.save(name: deviceInfo.key.hex, object: deviceInfo, service: service)
    }

    func getDeviceInfo(deviceKey: String) throws -> DeviceInfo {
        return try keychainStore.get(name: deviceKey, service: service)
    }

    func getAllDevices() throws -> [String:DeviceInfo] {
        return try keychainStore.getAll(service: service)
    }

    func delete(deviceKey: String) {
        keychainStore.delete(name: deviceKey, service: service)
    }

}
