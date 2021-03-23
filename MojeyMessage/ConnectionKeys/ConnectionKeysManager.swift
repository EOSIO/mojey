//
//  MessageKeysManager.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/21/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class ConnectionKeysManager {

    static let `default` = ConnectionKeysManager()

    static func makeBurnableKeyTag(deviceKey: String) -> String {
        return "BurnableKey Device:\(deviceKey)"
    }

    static func makeSequenceKeyTag(deviceKey: String) -> String {
        return "SequenceKey Device:\(deviceKey)"
    }

    let defaultNumBurnableKeys = 5
    private let keychain = Keychain(accessGroup: Constants.accessGroup)
    private let keyManager = MojeyKeyManager.default
    private let deviceStore = DeviceStore.default
    private let burnablePublicKeysStore = BurnablePublicKeysStore.default
    private let outgoingSequenceStore = OutgoingSequenceStore.default
    private let participantStore = ParticipantStore.default
    private let signatureProvider = SignatureProvider.default



    func concatenate(keys: [Data]) -> Data {
        var data = Data()
        for key in keys {
            data.append(key)
        }
        return data
    }


    func split(keysData: Data) throws -> [String] {
        let keyLength = 33
        guard keysData.count % keyLength == 0 else {
            throw SCError(reason: "key data invalid")
        }
        let numKeys = keysData.count / keyLength
        print("num burnable key = \(numKeys)")
        var keysArray = [String]()
        for i in 0..<numKeys {
            let key = keysData[i*keyLength..<(i+1)*keyLength]
            keysArray.append(key.hex)
        }
        return keysArray
    }

    private func makeBurnableKeyTag(deviceKey: String) -> String {
        return ConnectionKeysManager.makeBurnableKeyTag(deviceKey: deviceKey)
    }

    private func makeSequenceKeyTag(deviceKey: String) -> String {
        return ConnectionKeysManager.makeSequenceKeyTag(deviceKey: deviceKey)
    }


    func getBurnableECKeys(deviceKey: String) throws -> [Keychain.ECKey] {
        return try keychain.getAllEllipticCurveKeys(tag: makeBurnableKeyTag(deviceKey: deviceKey), label: nil)
    }


    func getBurnableKeys(deviceKey: String) throws -> [Data] {
        let ecKeys = try getBurnableECKeys(deviceKey: deviceKey)
        var burnableKeys = [Data]()
        for key in ecKeys {
            burnableKeys.append(key.compressedPublicKey)
        }
        return burnableKeys
    }


    func newBurnableKeys(count: Int, deviceKey: String) throws -> [Data] {
        var burnableKeys = [Data]()
        for _ in 1...count {
            let tag = makeBurnableKeyTag(deviceKey: deviceKey)
            let key = try MojeyKeyManager.default.newSecureEnclaveKey(tag: tag) 
            burnableKeys.append(key.compressedPublicKey)
            //}
        }
        return burnableKeys
    }


    func newSequenceKey(deviceKey: String) throws -> Data {
        let tag = makeSequenceKeyTag(deviceKey: deviceKey)
        let key = try MojeyKeyManager.default.newSecureEnclaveKey(tag: tag)
        return key.compressedPublicKey
    }

    
    func process(connectionKeysRequest: ConnectionKeysRequest, participantId: String, text: String) throws -> ConnectionKeysResponse {

        /// validate keyrequest signatures
        let _ = try validateSignatures(keysRequest: connectionKeysRequest)

        /// create keyResponse
        var keysResponse = try ConnectionKeysResponse.new()
        keysResponse.content.text = text
        keysResponse.content.targetDevice = connectionKeysRequest.content.senderDevice
        keysResponse.content.encryptionPubKey = connectionKeysRequest.content.responseKey

        let senderDeviceKey = connectionKeysRequest.content.senderDevice.key.hex
        let responseKey = connectionKeysRequest.content.responseKey

        /// generate burnable keys
        let burnableKeysArray = try newBurnableKeys(count: defaultNumBurnableKeys, deviceKey: senderDeviceKey)
        let burnableKeysData = concatenate(keys: burnableKeysArray)
        guard burnableKeysData.count > 0 else {
            throw SCError(reason: "Unable to create keys for keys request")
        }
        keysResponse.content.encryptedBurnableKeys = try keychain.encrypt(publicKey: responseKey, message: burnableKeysData)

        /// generateSequenceKey
        let sequenceKeyData = try newSequenceKey(deviceKey: senderDeviceKey)
        keysResponse.content.encryptedSequenceKey = try keychain.encrypt(publicKey: responseKey, message: sequenceKeyData)
        try IncomingSequenceStore.default.setIncomingSequence(IncomingSequence(), key: sequenceKeyData.hex, sig: Data())

        /// sign
        keysResponse.signatures = try signatureProvider.sign(data: keysResponse.content.toJsonData())
        return keysResponse
    }


    // process a connectionKeysResponse
    // if the burnable keys can be decrypted, save/update the deviceInfo, burnable keys and participant info
    func process(connectionKeysResponse: ConnectionKeysResponse, participantId: String) throws {
        print("----connectionKeysResponse----------------------------------")
        print(connectionKeysResponse.json ?? "")
        print("----------------------------------------------------------")

        // decrypt sequenceKey and burnable keys
        let sequenceKey = try keyManager.decrypt(message: connectionKeysResponse.content.encryptedSequenceKey, key: connectionKeysResponse.content.encryptionPubKey)
        let burnableKeysConcatenated = try keyManager.decryptAndDeleteKey(message: connectionKeysResponse.content.encryptedBurnableKeys, publicKey: connectionKeysResponse.content.encryptionPubKey)
        let burnableKeys = try split(keysData: burnableKeysConcatenated)
        print(burnableKeys)

        /// udate the deviceStore, burnableKeysStore and outgoingSequenceStore
        try deviceStore.save(deviceInfo: connectionKeysResponse.content.senderDevice)
        try burnablePublicKeysStore.add(burnablePublicKeys: burnableKeys, deviceKey: connectionKeysResponse.content.senderDevice.key.hex)
        try outgoingSequenceStore.addNewOutgoingSequenceKey(sequenceKey.hex, deviceKey: connectionKeysResponse.content.senderDevice.key.hex)
        

        print("-----allBurnablePublicKeys-----------------------------------------")
        let bk = try burnablePublicKeysStore.allBurnablePublicKeys(deviceKey: connectionKeysResponse.content.senderDevice.key.hex)
        print(bk)
        print("----------------------------------------------------------")
        try? outgoingSequenceStore.printOutgoingSequence()

        /// update the participantStore. set the sending device to the current device for the participant
        let cloudId = connectionKeysResponse.content.senderDevice.cloudId
        let selectedDeviceKey = connectionKeysResponse.content.senderDevice.key.hex
        let date = connectionKeysResponse.content.date
        try participantStore.update(participantId: participantId, cloudId: cloudId, selectedDeviceKey: selectedDeviceKey, date: date)
    }


    func validateSignatures(keysRequest: ConnectionKeysRequest) throws -> Bool {
        let data = try keysRequest.content.toJsonData()
        return try SignatureProvider.default.verify(signatures: keysRequest.signatures, data: data, deviceKey: keysRequest.content.senderDevice.key)
    }




}
