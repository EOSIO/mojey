//
//  ParticipantStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/14/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class ParticipantStore {

    static let `default` = ParticipantStore()

    private let burnablePublicKeyStore = BurnablePublicKeysStore.default
    private let keychainStore = KeychainStore.default
    private let service = "ParticipantStore"


    // ge the number of burnable public keys for the selected device for the participant id
    func numberOfBurnablePublicKeysForSelectedDevice(participantId: String) -> Int {
        guard let participant = try? getParticipant(participantId: participantId) else { return 0 }
        guard let selectedDeviceKey = participant.selectedDeviceKey else { return 0 }
        guard let burnableKeys = try? burnablePublicKeyStore.allBurnablePublicKeys(deviceKey: selectedDeviceKey) else { return 0 }
        return burnableKeys.count
    }

    // get participant from the id
    func getParticipant(participantId: String) throws -> Participant {
        return try keychainStore.get(name: participantId, service: service)
    }


    // get all participants for the provided identifiers
    func getParticipants(identifiers: [UUID]) -> [Participant] {
        var participants = [Participant]()
        for id in identifiers {
            if let participant = try? getParticipant(participantId: id.uuidString) {
                participants.append(participant)
            }
        }
        return participants
    }

    func getAllParticipants() throws -> [String:Participant] {
        return try keychainStore.getAll(service: service)
    }

    // save participant
    private func save(participant: Participant) throws {
        try keychainStore.save(name: participant.participantId, object: participant, service: service)
        //TODO: TBNotification
    }

    // new participant
    private func new(participantId: String, cloudId: String, selectedDeviceKey: String, date: Date) throws -> Participant {
        var participant = Participant(participantId: participantId, cloudId: cloudId)
        participant.selectedDeviceKey = selectedDeviceKey
        participant.add(deviceKey: selectedDeviceKey)
        participant.date = Date.earlier(date1: date, date2: Date())
        try save(participant: participant)
        return participant
    }

    // update participant
    // main thing updating here is the selected device and the date of the update
    // if the selected device is new add to the list of devices
    @discardableResult
    func update(participantId: String, cloudId: String, selectedDeviceKey: String, date: Date) throws -> Participant {
        if var participant = try? getParticipant(participantId: participantId) {
            let earlierDate = Date.earlier(date1: date, date2: Date())
            // if the existing date is before than the earlierDate then do the update
            if participant.date < earlierDate {
                participant.cloudId = cloudId
                participant.selectedDeviceKey = selectedDeviceKey
                participant.add(deviceKey: selectedDeviceKey)
                participant.date = earlierDate
                try save(participant: participant)
            }
            return participant
        } else {
            let earlierDate = Date.earlier(date1: date, date2: Date())
            return try new(participantId: participantId, cloudId: cloudId, selectedDeviceKey: selectedDeviceKey, date: earlierDate)
        }
    }

    // remove a device from a participant
    // if the selected device is the one removed then selectedDeviceKey will also be set to nil
    // this sould only happen when a user deactivates their device from the device manager in the main app
    @discardableResult
    func remove(deviceKey: String, participantId: String, date: Date) throws -> Participant {
        var participant =  try getParticipant(participantId: participantId)
        let earlierDate = Date.earlier(date1: date, date2: Date())
        if participant.date < earlierDate && participant.deviceKeys.contains(deviceKey) {
            participant.remove(deviceKey: deviceKey)
            try save(participant: participant)
        }
        return participant
    }


    func printAllParticipants() {
        print("===ALL PARTICIPANTS========================")
        if let participants = try? getAllParticipants() {
            print(participants)
        }
        print("===ALL PARTICIPANTS========================")
    }

}
