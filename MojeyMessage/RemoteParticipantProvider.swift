//
//  RemoteParticipantProvider.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/31/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class RemoteParticipantProvider {

    static let `default` = RemoteParticipantProvider()
    private let participantStore = ParticipantStore.default

    func getRemoteParticipant(identifiers: [UUID]) -> Participant? {
        guard let myCloudId = try? CloudId.cloudId() else { return nil }
        return getRemoteParticipant(identifiers: identifiers, myCloudId: myCloudId)
    }

    // get remote participant from list of identifiers
    // if participant cloudId == current user cloudId then the participant is another device of the current user, so skip
    // in most two party conveersations there will only be one identifier
    // if more than one participant found, return the most recent
    // if no participant found then return nil
    func getRemoteParticipant(identifiers: [UUID], myCloudId: String) -> Participant? {
        //participantStore.printAllParticipants()
        var remoteParticipant: Participant? = nil
        let participants = participantStore.getParticipants(identifiers: identifiers)
        //print(participants)
        guard participants.count > 0 else { return nil }

        for participant in participants {
            // if participant is self, skip
            if participant.cloudId == myCloudId {
                continue
            }
            if remoteParticipant == nil {
                remoteParticipant = participant
            }
            // if more than one participant found, return the most recent
            if let remoteParticipantDate = remoteParticipant?.date, participant.date > remoteParticipantDate {
                remoteParticipant = participant
            }
        }

        return remoteParticipant
    }


}
