//
//  OutgoingSequenceStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/8/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation


struct OutgoingSequence: Codable {
    var sequenceKey: String
    var sequenceNumber: UInt64
}


class OutgoingSequenceStore {

    static let `default` = OutgoingSequenceStore()

    private let keychainStore = KeychainStore.default
    private let service = "OutgoingSequence"


    func getOutgoingSequence(deviceKey: String) throws -> OutgoingSequence {
        try printOutgoingSequence()
        return try keychainStore.get(name: deviceKey, service: service)
    }


    func save(outgoingSequence: OutgoingSequence, deviceKey: String) throws {
        try keychainStore.save(name: deviceKey, object: outgoingSequence, service: service)
    }


    func addNewOutgoingSequenceKey(_ sequenceKey: String, deviceKey: String) throws {
        let newSeq = OutgoingSequence(sequenceKey: sequenceKey, sequenceNumber: 0)
        try save(outgoingSequence: newSeq, deviceKey: deviceKey)
    }


    func printOutgoingSequence() throws {
        let sequenceKeys:[String:OutgoingSequence] = try keychainStore.getAll(service: service)
        print("\n=====[ Current Sequence Keys (DeviceKey:{SequenceKey,SequenceNumber}) ]======================================")
        for (dk,os) in sequenceKeys {
            print("\(dk): \(os.json ?? "")")
        }
        print("======================================================================================================\n")
    }


}

