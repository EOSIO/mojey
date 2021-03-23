//
//  MojeyManager.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/4/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class MojeyTransferManager {

    static let `defaut` = MojeyTransferManager()

    private let useSequenceKey = false

    private let burnablePublicKeyStore = BurnablePublicKeysStore.default
    private let connectionKeysManager = ConnectionKeysManager.default
    private let burnablePublicKeysStore = BurnablePublicKeysStore.default
    private let outgoingSequenceStore = OutgoingSequenceStore.default
    private let incomingSequenceStore = IncomingSequenceStore.default
    private let deviceStore = DeviceStore.default
    private let keychain = MojeyKeyManager.default.keychain
    private let keyManager = MojeyKeyManager.default
    private let mojeyStore = MojeyStore.default
    private let transferStore = TransferStore.default

     
    func createMojeyTransfer(mojey: String, participant: Participant) throws -> MojeyTransfer {
        guard let targetDeviceKey = participant.selectedDeviceKey else {
            throw SCError(reason: "Participant \(participant.participantId) does not have a selected device")
        }
        return try createMojeyTransfer(mojey: mojey, targetDeviceKey: targetDeviceKey)

    }


    func createMojeyTransfer(mojey: String, targetDeviceKey: String) throws -> MojeyTransfer {

        var mojeyTransfer = try MojeyTransfer.new()
        mojeyTransfer.content.targetDevice = try deviceStore.getDeviceInfo(deviceKey: targetDeviceKey)

        mojeyTransfer.content.displayMojey = mojey

        // decrement state and return encrypted mojey or error
        if useSequenceKey {
            var outgoingSequence = try outgoingSequenceStore.getOutgoingSequence(deviceKey: targetDeviceKey)
            outgoingSequence.sequenceNumber += 1
            mojeyTransfer.content.sequence = UInt32(outgoingSequence.sequenceNumber)
            mojeyTransfer.content.encryptedMojey = try mojeyStore.decrement(mojey: mojey, encryptionKey: outgoingSequence.sequenceKey)
            mojeyTransfer.content.encryptionPubKey = try Data(hex: outgoingSequence.sequenceKey)
            try outgoingSequenceStore.save(outgoingSequence: outgoingSequence, deviceKey: targetDeviceKey)
            try? outgoingSequenceStore.printOutgoingSequence()

        // burnable key
        } else {
            burnablePublicKeyStore.printAllBurnablePublicKeys(deviceKey: targetDeviceKey)
            // burn a key, use to to encrypt
            let burnedKey = try burnablePublicKeyStore.burnPublicKey(deviceKey: targetDeviceKey)
            print("Burn Key \(burnedKey)")
            burnablePublicKeyStore.printAllBurnablePublicKeys(deviceKey: targetDeviceKey)
            mojeyTransfer.content.encryptedMojey = try mojeyStore.decrement(mojey: mojey, encryptionKey: burnedKey)
            mojeyTransfer.content.encryptionPubKey = try Data(hex: burnedKey)

            // if I have less than (5) burnable keys for partner device, send some more
            let remainingBurnableKeys = try connectionKeysManager.getBurnableKeys(deviceKey: targetDeviceKey)
            print("REMAINING BURNABLE KEYS = \(remainingBurnableKeys.count)")
            var newBurnableKeys = [Data]()
            if remainingBurnableKeys.count < connectionKeysManager.defaultNumBurnableKeys {
                let numNewBurnableKeys = connectionKeysManager.defaultNumBurnableKeys - remainingBurnableKeys.count
                print("ADD \(numNewBurnableKeys) new burnable keys")
                newBurnableKeys = try connectionKeysManager.newBurnableKeys(count: numNewBurnableKeys, deviceKey: targetDeviceKey)
            }
            var allBurnableKeys = remainingBurnableKeys + newBurnableKeys
            if allBurnableKeys.count > connectionKeysManager.defaultNumBurnableKeys {
                allBurnableKeys = Array(allBurnableKeys[0..<connectionKeysManager.defaultNumBurnableKeys])
            }
            let burnableKeysData = connectionKeysManager.concatenate(keys: allBurnableKeys)
            let burnedKeyData = try Data(hex: burnedKey)
            mojeyTransfer.content.encryptedBurnableKeys = try keychain.encrypt(publicKey: burnedKeyData, message: burnableKeysData)
        }

        mojeyTransfer.signatures = try SignatureProvider.default.sign(data: hash(mojeyTransfer: mojeyTransfer))


        // TODO: save mojeyTransfer in case the iMessage transfer does not work. Option to resend. delete transfer after send
        // OutgoingMojeyTransferStore

        return mojeyTransfer
    }



    func process(mojeyTransfer: MojeyTransfer) throws {
        do {
            print("::: process mojeyTransfer: :::::::::::::::::::::::::::::::::::::")
            print(mojeyTransfer.json ?? "")
            print("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")

            // validate signatures
            try SignatureProvider.default.verify(signatures: mojeyTransfer.signatures, data: hash(mojeyTransfer: mojeyTransfer), deviceKey: mojeyTransfer.content.senderDevice.key)

            // if newEncryptedBurnableKeys, add the new keys
            if mojeyTransfer.content.encryptedBurnableKeys.count > 0 {
                let data = try keyManager.decrypt(message: mojeyTransfer.content.encryptedBurnableKeys, key: mojeyTransfer.content.encryptionPubKey)
                let keys = try connectionKeysManager.split(keysData: data)
                print(keys)

                // udate the deviceStore and burnableKeysStore
                try deviceStore.save(deviceInfo: mojeyTransfer.content.senderDevice)
                try burnablePublicKeysStore.add(burnablePublicKeys: keys, deviceKey: mojeyTransfer.content.senderDevice.key.hex)
            }

            var mojeyData: Data
            // sequence
            if mojeyTransfer.content.sequence > 0 {
                var sequence = try incomingSequenceStore.getIncomingSequence(key: mojeyTransfer.content.encryptionPubKey.hex)
                sequence.headSequence += 1
                if mojeyTransfer.content.sequence >= sequence.headSequence {
                    mojeyData = try keyManager.decrypt(message: mojeyTransfer.content.encryptedMojey, key: mojeyTransfer.content.encryptionPubKey)
                    try incomingSequenceStore.setIncomingSequence(sequence, key: mojeyTransfer.content.encryptionPubKey.hex, sig: Data())
                } else {
                    throw SCError(reason: "Invalid sequence")
                }
            // burnable key
            } else {
                let tag = ConnectionKeysManager.makeBurnableKeyTag(deviceKey: mojeyTransfer.content.senderDevice.key.hex)
                mojeyData = try keyManager.decryptAndDeleteKey(message: mojeyTransfer.content.encryptedMojey, publicKey: mojeyTransfer.content.encryptionPubKey, tag: tag)
            }
           

            guard let mojey = String(data: mojeyData, encoding: .utf8) else {
                throw SCError(reason: "Cannot decode utf8 string")
            }
            print("::: Decrypted Mojey :::::::::::::::::::::::::::::::::::::")
            print(mojey)
            print("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")

            // increment mojey
            try mojeyStore.increment(mojey: mojey)
            try? TransferStore.default.setSuccess(id: mojeyTransfer.content.id)

        } catch {
            try? transferStore.setError(error.localizedDescription, id: mojeyTransfer.content.id)
            throw error
        }
    }

    // hash the secure data for a mojeyTransfer for signing and later verification
    // if new secure data needs to be added, the version number can be increased
    // non-secure data can be added without having to increase the version num as the hash would not change
    private func hash(mojeyTransfer: MojeyTransfer) throws -> Data {
        switch mojeyTransfer.content.version {
        case 1:
            let c = mojeyTransfer.content
            let data = try
                "\(c.version)".toUtf8Data() +
                c.id.toUtf8Data() +
                "\(c.date.timeIntervalSince1970)".toUtf8Data() +
                c.displayMojey.toUtf8Data() +
                c.senderDevice.cloudId.toUtf8Data() + c.senderDevice.key +
                c.targetDevice.cloudId.toUtf8Data() + c.targetDevice.key +
                c.encryptionPubKey +
                "\(c.sequence)".toUtf8Data() +
                c.encryptedMojey +
                c.encryptedBurnableKeys
            return data.sha256
        default:
            throw SCError(reason: "Cannot hash mt version \(mojeyTransfer.content.version)")
        }
    }


}
