//
//  Participant.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/19/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct Participant: Codable, Equatable {
    var participantId = ""
    var cloudId = ""
    var selectedDeviceKey: String?
    private(set) var deviceKeys = [String]()
    var date = Date(timeIntervalSince1970: 0)

    init() { }

    init(participantId: String, cloudId: String) {
        self.participantId = participantId
        self.cloudId = cloudId
    }

    mutating func add(deviceKey: String) {
        if !deviceKeys.contains(deviceKey) {
            deviceKeys.append(deviceKey)
        }
    }

    mutating func remove(deviceKey: String) {
        if let i = deviceKeys.firstIndex(of: deviceKey) {
            deviceKeys.remove(at: i)
        }
        if selectedDeviceKey == deviceKey {
            selectedDeviceKey = nil
        }
    }


}
