//
//  MojeyManager.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/4/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CBORCoding
import Combine
import CryptoKit

class TokenTransferManager {

    struct PendingOutgoingTransfer: Codable {
        var id = ""
        var targetDeviceKey = Data()
        var tokens = Data()

        init(targetDeviceKey: Data, tokens: Data) {
            self.id = UUID().uuidString
            self.targetDeviceKey = targetDeviceKey
            self.tokens = tokens
        }
    }


    static let `defaut` = TokenTransferManager()

    private let nearbyDevicesManager = NearbyDevicesManager.shared
    private let attestedKeyService = AttestedKeyService.default
    private let attestedKeyManager = AttestedKeyManager.default
    private let attestedKeyStore = AttestedKeyStore.default
    private let tokenDefinitionStore = CustomTokenDefinitionStore.default
    private let mojeyStore = MojeyStore.default
    private let keychainStore = KeychainStore.default
    private let keychain = Keychain(accessGroup: Constants.accessGroup)
    private let burnableKeysProvider = BurnableKeysProvider.default

    private let pendingOutgoingTransferService = "PendingOutgoingTransfer"
    private let pendingConnectionKeysRequestService = "PendingConnectionKeysRequest"

    private let noDeviceKeyError = SCError(reason: "No device key")

    private var deviceKey: DeviceKey? {
        return try? DeviceKey.deviceKey()
    }

    private func mainAttestedKey() throws -> Data {
        return try attestedKeyStore.getAttestedKey(name: "Main")
    }


    // initiate a transfer
    func initiateTransfer(targetDeviceKey: Data, tokens: Data, completion: @escaping ((Error?)->Void)) {
        print("\n-----initiateTransfer---------------------------------")
        print(" to device: \(targetDeviceKey.hex)")
        print("------------------------------------------------------\n")
        do {
            // create pending outgoing transfer and save it with the id
            // will be read back when the connection keys response is received
            let outgoingTransfer = PendingOutgoingTransfer(targetDeviceKey: targetDeviceKey, tokens: tokens)
            try keychainStore.save(name: outgoingTransfer.id, object: outgoingTransfer, service: pendingOutgoingTransferService)

            // send connection request
            sendConnectionRequest(outgoingTransfer: outgoingTransfer, targetDeviceKey: targetDeviceKey, completion: completion)
        } catch {
            completion(error)
        }
    }


    private func sendConnectionRequest(outgoingTransfer: PendingOutgoingTransfer,  targetDeviceKey: Data, completion:  @escaping (Error?)->Void) {
        print("\n-----sendConnectionRequest---------------------------------")
        print(outgoingTransfer.id)
        print(" to device: \(targetDeviceKey.hex)")

        do {
            // create connection request
            let attestedKey = try mainAttestedKey()
            var connectionRequest = try Message.ConnectionRequest(id: outgoingTransfer.id)
            connectionRequest.content.targetDeviceKey = targetDeviceKey
            connectionRequest.content.senderAssertingKey = attestedKey
            connectionRequest.content.prospectiveAssertingKeys = [attestedKey]


            // add prospective tokens, and their prospective attested keys here
            connectionRequest.content.prospectiveTokens = allHexTokens(tokenList: outgoingTransfer.tokens)

            signAndEncode(message: connectionRequest, encoding: .json) { (signedEncodedMessage, error) in
                guard let signedEncodedMessage = signedEncodedMessage else { return completion(error) }
                self.nearbyDevicesManager.send(message: signedEncodedMessage, targetDeviceKey: targetDeviceKey)
                print(connectionRequest)
                print("------------------------------------------------------\n")
                completion(nil)
            }
        } catch {
            print(error)
            print("------------------------------------------------------\n")
            completion(error)
        }
    }


    // process an incomming connection keys request
    func processIncoming(connectionKeysRequest: Message.ConnectionRequest, canRequestAttestation: Bool = true, completion:  @escaping (Error?)->Void) {
        print("\n----- processIncoming(connectionKeysRequest -------------------------------------")
        print(connectionKeysRequest)

        do {
            // validate signatures (connection requests to not validate the attestation as it may need to be included with the token transfer)
            guard try validateAssertion(message: connectionKeysRequest) else {
                return completion(SCError(reason: "signature validation error"))
            }
            print("---------------------------------------------------------------------------------\n")
            sendConnectionResponse(id: connectionKeysRequest.content.id, connectionRequest: connectionKeysRequest, completion: completion)
        } catch {
            completion(error)
        }
    }



    private func sendConnectionResponse(id: String, connectionRequest: Message.ConnectionRequest, completion:  @escaping (Error?)->Void) {
        print("\n---sendConnectionKeysResponse---------------------------------------")
        print(id)
        print("---------------------------------------------------------------------------------\n")
        do {
            var connectionResponse = try Message.ConnectionResponse(id: connectionRequest.content.id)
            connectionResponse.content.targetDeviceKey = connectionRequest.content.senderDeviceKey
            connectionResponse.content.senderAssertingKey = try mainAttestedKey()

            // generate burnable key
            let burnableKey = try burnableKeysProvider.newImmediateUseBurnableKey(targetDeviceKey: connectionRequest.content.senderDeviceKey)
            connectionResponse.content.burnableKey = burnableKey

            // request any required attestations
            for ak in connectionRequest.content.prospectiveAssertingKeys {
                if !attestedKeyStore.haveCompactAttestation(key: ak) {
                    print("REQUEST KEY ATTESTATION: \(ak.hex)")
                    connectionResponse.content.requestKeyAttestations.append(ak)
                }
            }

            // request any required token definitions
            for td in connectionRequest.content.prospectiveTokens {
                if !tokenDefinitionStore.haveToken(tokenKey: td.hex) {
                    connectionResponse.content.requestTokenDefinitions.append(td)
                }
            }

            signAndEncode(message: connectionResponse, encoding: .json) { (signedEncodedMessage, error) in
                guard let signedEncodedMessage = signedEncodedMessage else { return completion(error) }
                self.nearbyDevicesManager.send(message: signedEncodedMessage, targetDeviceKey: connectionResponse.content.targetDeviceKey)
                print(signedEncodedMessage.hex)
                print(error)
                print("---------------------------------------------------------------------------------\n")
                completion(nil)

            }
        } catch {
            completion(error)
        }
    }


    func processIncoming(connectionResponse: Message.ConnectionResponse, completion:  @escaping (Error?)->Void) {
        print("\n----- processIncoming(connectionResponse -------------------------------------")
        print(connectionResponse.content.id)
        do {
            // validate sig
            print("validate")
            guard try validateAssertion(message: connectionResponse) else {
                return completion(SCError(reason: "signature validation error"))
            }
            // get and then delete pending transfer
            print("get and then delete pending transfer")
            let outgoingTransfer: PendingOutgoingTransfer = try keychainStore.get(name: connectionResponse.content.id, service: pendingOutgoingTransferService)
            print("delete")
            keychainStore.delete(name: connectionResponse.content.id, service: pendingOutgoingTransferService)
            // send
            print("---------------------------------------------------------------------------------\n")
            sendTokenTransfer(connectionResponse: connectionResponse, tokens: outgoingTransfer.tokens, completion: completion)
        } catch {
            completion(error)
        }
    }


    private func sendTokenTransfer(connectionResponse: Message.ConnectionResponse, tokens: Data, completion:  @escaping (Error?)->Void) {
        print("\n-----sendTokenTransfer(connectionResponse: -------------------------------------")
        do {
            var tokenTransfer = try Message.TokenTransfer(id: connectionResponse.content.id)
            tokenTransfer.content.targetDeviceKey = connectionResponse.content.senderDeviceKey
            tokenTransfer.content.encryptionKey = connectionResponse.content.burnableKey
            tokenTransfer.content.senderAssertingKey = try mainAttestedKey()
            tokenTransfer.content.tokensHash = tokens.sha256

            // add any requested attestations
            var attestations = [Message.Attestation]()
            for ak in connectionResponse.content.requestKeyAttestations {
                let compactAttestation = try attestedKeyStore.getCompactAttestation(key: ak)
                let attestation = Message.Attestation(compactAttestation: compactAttestation)
                attestations.append(attestation)
            }
            if attestations.count > 0 {
                tokenTransfer.attestations = attestations
            }

            // add any requested token definitions
            var definitions = [CustomToken]()
            for tdKey in connectionResponse.content.requestTokenDefinitions {
                if let tokenDef = tokenDefinitionStore.get(tokenKey: tdKey.hex) {
                    definitions.append(tokenDef)
                }
            }
            if definitions.count > 0 {
                tokenTransfer.tokenDefinitions = definitions
            }


            // TODO: dcrement from state the tokens and encrypt with the burnable key
            // for now just encrypt
            let encryptedTokens = try keychain.encrypt(publicKey: connectionResponse.content.burnableKey, message: tokens)
            tokenTransfer.content.encryptedTokens = encryptedTokens

            // sign encode and send
            signAndEncode(message: tokenTransfer, encoding: .json) { (signedEncodedMessage, error) in
                guard let signedEncodedMessage = signedEncodedMessage else { return completion(error) }
                self.nearbyDevicesManager.send(message: signedEncodedMessage, targetDeviceKey: tokenTransfer.content.targetDeviceKey)
                print(signedEncodedMessage.hex)
                print("---------------------------------------------------------------------------------\n")
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }


    func processIncoming(tokenTransfer: Message.TokenTransfer, completion:  @escaping (Error?)->Void) {
        print("\n----- processIncoming(tokenTransfer-------------------------------------")
        do {
            print("Attestations: \(tokenTransfer.attestations?.count)")
            // add included attestations to store (if verified)
            if let attestations = tokenTransfer.attestations {
                let teamId = Constants.teamId
                for a in attestations {
                    print(a.attestedKey.hex)
                    print(a.attestedKey.sha256.hex)
                    if attestedKeyService.verifyAttestation(key: a.attestedKey, certificateChain: a.certificateChain, authData: a.authData, clientHash: a.clientHash, teamId: teamId) {
                        print("ADD ATTESTATION for \(a.attestedKey.hex)")
                        let compactAttestation = AttestedKeyService.CompactAttestation(certificateChain: a.certificateChain, authData: a.authData, attestedKey: a.attestedKey, clientHash: a.clientHash)
                        try attestedKeyStore.saveCompactAttestation(key: a.attestedKey, attestation: compactAttestation)
                    } else {
                        print("CANNOT VERIFY ATTESTATION for \(a.attestedKey.hex)")
                    }
                }
            }

            // add token  definitions
            if let tokenDefinitions = tokenTransfer.tokenDefinitions {
                for tokenDef in tokenDefinitions {
                    print("------ADD TOKEN DEF-------")
                    print(tokenDef)
                    print("--------------------------")
                    try? tokenDefinitionStore.save(customToken: tokenDef)
                }
            }


            // validate sig
            guard try validate(message: tokenTransfer) else {
                return completion(SCError(reason: "signature validation error"))
            }
            // decrypt tokens
            print("decrypt tokens")
            let tokens = try keychain.decryptAndDeleteSecureEnclaveKey(message: tokenTransfer.content.encryptedTokens, publicKey: tokenTransfer.content.encryptionKey)
            guard tokens.sha256 == tokenTransfer.content.tokensHash else {
                return completion(SCError(reason: "token hash validation error"))
            }
            print(tokens.hex)
            print("---------------------------------------------------------------------------------\n")
            if let tokensString = String(data: tokens, encoding: .utf8) {
                mojeyStore.printMojeyStore()
                try mojeyStore.increment(mojey: tokensString)
                mojeyStore.printMojeyStore()
            }

            sendTokenTransferReceipt(status: .complete, tokenTransfer: tokenTransfer, completion: completion)
            completion(nil)

        } catch {
            completion(error)
        }
    }


    private func sendTokenTransferReceipt(status: Message.TokenTransferReceipt.Status, tokenTransfer: Message.TokenTransfer, completion:  @escaping (Error?)->Void) {
        print("\n----- sendTokenTransferReceipt-------------------------------------")
        print(tokenTransfer.content.id)
        do {
            var tokenTransferReceipt = try Message.TokenTransferReceipt(id: tokenTransfer.content.id)
            tokenTransferReceipt.content.targetDeviceKey = tokenTransfer.content.senderDeviceKey
            tokenTransferReceipt.content.senderAssertingKey = try mainAttestedKey()
            tokenTransferReceipt.content.status = status
            signAndEncode(message: tokenTransferReceipt, encoding: .json) { (signedEncodedMessage, error) in
                guard let signedEncodedMessage = signedEncodedMessage else { return completion(error) }
                self.nearbyDevicesManager.send(message: signedEncodedMessage, targetDeviceKey: tokenTransferReceipt.content.targetDeviceKey)
                print(signedEncodedMessage.hex)
                print("---------------------------------------------------------------------------------\n")
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }



    func processIncoming(tokenTransferReceipt: Message.TokenTransferReceipt) throws {
        print("\n-----processIncoming(tokenTransferReceipt:-------------------------------------")

        // validate sig
        guard try validateAssertion(message: tokenTransferReceipt) else {
            throw SCError(reason: "signature validation error")
        }
        // TODO: update status
        print(tokenTransferReceipt.content.id)
        print(tokenTransferReceipt.content.status)
        print(tokenTransferReceipt.content.text)

        print("---------------------------------------------------------------------------------\n")

    }






    func signAndEncode(message: MessageEnvelope, encoding: Message.Encoding, completion: @escaping (Data?, Error?) -> Void) {
        do {
            var message = message
            let hash = try message.hash()
            sign(assertingKey: message.getContent().senderAssertingKey, hash: hash) { (signatures, error) in
                guard let signatures = signatures else { return completion(nil, error) }
                message.signatures = signatures
                switch message.encode(encoding) {
                case .success(let encodedMessage):
                    completion(encodedMessage, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        } catch {
            completion(nil, error)
        }
    }

    func sign(assertingKey: Data, hash: Data, completion: @escaping (Message.Signatures?, Error?) -> Void) {
        guard let deviceKey = deviceKey else { return completion(nil, noDeviceKeyError) }
        var signatures = Message.Signatures()

        keychain.sign(publicKey: deviceKey.uncompressedPublicKey, hash: hash) { (deviceKeySignature,error) in
            guard let deviceKeySignature = deviceKeySignature else { return completion(nil, error) }
            signatures.sigdk = deviceKeySignature
            attestedKeyService.generateAssertion(key: assertingKey, hash: hash) { (assertion, error) in
                guard let assertion = assertion else { return completion(nil, error) }
                signatures.sigak = assertion.signature
                signatures.sigakc = assertion.counter
                completion(signatures, nil)
            }
        }
    }


    func validate(message: MessageEnvelope, attestation: AttestedKeyService.CompactAttestation? = nil) throws -> Bool {
        let content = message.getContent()
        return try validate(signatures: message.signatures, assertingKey: content.senderAssertingKey, attestation: attestation, senderDeviceKey: content.senderDeviceKey, digest: message.digest())
    }

    // validate the signatures
    // first validate the attestation
    // then validate the assertion
    // then validate the device key signature
    func validate(signatures: Message.Signatures, assertingKey: Data, attestation: AttestedKeyService.CompactAttestation? = nil, senderDeviceKey: Data, digest: SHA256.Digest) throws -> Bool {
        var compactAttestation: AttestedKeyService.CompactAttestation
        if let attestation = attestation {
            compactAttestation = attestation
        } else {
            compactAttestation = try attestedKeyStore.getCompactAttestation(key: assertingKey)
        }
        let verifiedPublicKey = attestedKeyService.getVerifiedPublicKey(certificateChain: compactAttestation.certificateChain, authData: compactAttestation.authData, clientHash: senderDeviceKey.sha256, teamId: Constants.teamId)
        guard verifiedPublicKey == assertingKey else {
            throw SCError(reason: "\(assertingKey) attestation failure")
        }
        return try validateAssertion(signatures: signatures, assertingKey: assertingKey, senderDeviceKey: senderDeviceKey, digest: digest)
    }


    func validateAssertion(message: MessageEnvelope, attestation: AttestedKeyService.CompactAttestation? = nil) throws -> Bool {
        let content = message.getContent()
        return try validateAssertion(signatures: message.signatures, assertingKey: content.senderAssertingKey, senderDeviceKey: content.senderDeviceKey, digest: message.digest())
    }


    func validateAssertion(signatures: Message.Signatures, assertingKey: Data, senderDeviceKey: Data, digest: SHA256.Digest) throws -> Bool {
        guard try attestedKeyService.verifyAssertion(publicKey: assertingKey, signature: signatures.sigak, clientHash: digest.data, counter: signatures.sigakc) else {
            throw SCError(reason: "assertion signature failure")
        }
        let senderPublicKey = try P256.Signing.PublicKey(x963Representation: senderDeviceKey)
        let sig = try P256.Signing.ECDSASignature(derRepresentation: signatures.sigdk)
        print("------validate-----------------")
        print(digest.data.hex)
        guard senderPublicKey.isValidSignature(sig, for: digest) else {
            throw SCError(reason: "devicekey signature failure")
        }
        print("-------------------------------")
        return true
    }



    func createTestTransfer(targetDeviceKey: Data, completion: @escaping (Message.TokenTransfer?, Error?)->Void) {
        do {
            var tokenTransfer = try Message.TokenTransfer()
            tokenTransfer.content.targetDeviceKey = targetDeviceKey
            tokenTransfer.content.encryptedTokens = "10 TODD".data(using: .utf8)!
            let h = try tokenTransfer.hash()

            let attestedKey = try attestedKeyStore.getAttestedKey(name: "Main")
            let attestation = try attestedKeyStore.getFullAttestation(key: attestedKey)
            //let attestation = try AttestedKeyService.Attestation(data: attestationData)
            print(attestation)
            print(attestation.attStmt.x5c)

            //tokenTransfer.attestation = Message.Attestation(certs: attestation.attStmt.x5c, data: attestation.authData)

            attestedKeyService.generateAssertion(key: attestedKey, hash: h) { (assertion, error) in
                guard let assertion = assertion else { return completion(nil, error) }
                tokenTransfer.signatures.sigak = assertion.signature
                tokenTransfer.signatures.sigakc = assertion.counter
                print("===HASH + CREATE TEST TRANSFER authenticatorData===========")
                print(h.hex)
                print(assertion.authenticatorData.count)
                print(assertion.authenticatorData.hex)
                print("==================================================")

                let isValid = try! self.attestedKeyService.verifyAssertion(publicKey: attestedKey, signature: assertion.signature, clientHash: h, authData: assertion.authenticatorData)
                print(isValid)
                print(attestedKey.hex)
                print(h.hex)
                print(assertion.authenticatorData.hex)
                print("==================================================")
                completion(tokenTransfer,nil)
            }
            
        } catch {
            completion(nil, error)
        }

    }

    private func allHexTokens(tokenList: Data) -> [Data] {
        var tokens = [Data]()
        guard let tokensString = String(data: tokenList, encoding: .utf8) else { return [] }
        let tokensArray = tokensString.components(separatedBy: ",")
        for tq in tokensArray {
            let tokenString = tq.components(separatedBy: ":")[0]
            if tokenString.count >= 32, let tokenData = try? Data(hex: tokenString) {
                tokens.append(tokenData)
            }
        }
        return tokens
    }

    

}


private extension AttestedKeyService.CompactAttestation {
    init?(messageAttestation: Message.Attestation?) {
        guard let messageAttestation = messageAttestation else { return nil }
        self.attestedKey = messageAttestation.attestedKey
        self.certificateChain = messageAttestation.certificateChain
        self.authData = messageAttestation.authData
        self.clientHash = messageAttestation.clientHash
    }
}



/*
// request an attestation
private func sendAttestationRequest(id: String, attestedKey: Data, targetDeviceKey: Data) throws {
    print("\n-----sendAttestationRequest---------------------------------")
    print(id)
    print(" to device: \(targetDeviceKey.hex)")

    var attestationRequest = try Message.AttestationRequest(id: id)
    attestationRequest.content.targetDeviceKey = targetDeviceKey
    attestationRequest.content.requestedAttestations = [attestedKey]
    print(attestationRequest.content.senderDeviceKey.hex)
    let hash = try attestationRequest.hash()
    print(hash.hex)

    // attestationRequests don't have assertions to prevent endless loop
    attestationRequest.signature = try keychain.sign(publicKey: attestationRequest.content.senderDeviceKey, hash: hash)

    keychain.sign(publicKey: attestationRequest.content.senderDeviceKey, hash: hash) { (sig, error) in
        let senderDeviceKey = try! P256.Signing.PublicKey(x963Representation: attestationRequest.content.senderDeviceKey)
        let signature = try! P256.Signing.ECDSASignature(derRepresentation: sig!)
        let r = senderDeviceKey.isValidSignature(signature, for: hash)
        print(r)
    }

    //let senderDeviceKey = try P256.Signing.PublicKey(x963Representation: attestationRequest.content.senderDeviceKey)
    //let signature = try P256.Signing.ECDSASignature(derRepresentation: attestationRequest.signature)



    print("------------------------------------------------------\n")
    nearbyDevicesManager.send(message: try attestationRequest.tryEncode(.json), targetDeviceKey: targetDeviceKey)
}


// process an incoming attestation request
func processIncoming(attestationRequest: Message.AttestationRequest, completion: @escaping (Error?)->Void) {
    print("\n----- processIncoming(attestationRequest -------------------------------------")
    print(attestationRequest)
    print(try! attestationRequest.hash().hex)
    print("---------------------------------------------------------------------------------\n")
    do {
        // validate the device key signature
        // (attestationRequests do not have assertions because that could result in an endless loop between devices)
        let senderDeviceKey = try P256.Signing.PublicKey(x963Representation: attestationRequest.content.senderDeviceKey)
        let signature = try P256.Signing.ECDSASignature(derRepresentation: attestationRequest.signature)
        let digest = try attestationRequest.digest()
        guard senderDeviceKey.isValidSignature(signature, for: digest) else {
            throw SCError(reason: "devicekey signature failure")
        }
        sendAttestationResponse(attestationRequest: attestationRequest, completion: completion)
    } catch {
        completion(error)
    }
}


private func sendAttestationResponse(attestationRequest: Message.AttestationRequest, completion:  @escaping (Error?)->Void) {
    print("\n----- sendAttestationResponse( -------------------------------------")
    print(attestationRequest.content.id)

    do {
        var attestationResponse = try Message.AttestationResponse(id: attestationRequest.content.id)
        attestationResponse.content.targetDeviceKey = attestationRequest.content.senderDeviceKey
        attestationResponse.content.senderAssertingKey = try mainAttestedKey()
        for ak in attestationRequest.content.requestedAttestations {
            let compactAttestation = try attestedKeyStore.getCompactAttestation(key: ak)
            let attestation = Message.Attestation(compactAttestation: compactAttestation)
            attestationResponse.content.attestations.append(attestation)
        }
        signAndEncode(message: attestationResponse, encoding: .json) { (signedEncodedMessage, error) in
            guard let signedEncodedMessage = signedEncodedMessage else { return completion(error) }
            self.nearbyDevicesManager.send(message: signedEncodedMessage, targetDeviceKey: attestationResponse.content.targetDeviceKey)
            print(attestationResponse)
            print("")
            print(signedEncodedMessage.hex)
            print("---------------------------------------------------------------------------------\n")
            completion(nil)

        }
    } catch {
        print(error)
        print("---------------------------------------------------------------------------------\n")
        completion(error)
    }
}

// process an incoming attestation response
func processIncoming(attestationResponse: Message.AttestationResponse, completion: @escaping (Error?)->Void) {
    print("\n----- processIncoming(attestationResponse -------------------------------------")
    print(attestationResponse)
    do {
        let ar = attestationResponse
        let attestation = ar.content.attestation(key: ar.content.senderAssertingKey)
        // if the attestation for the asserting key is in the response then pass to validate as a param, becasue it is likey not saved (that's why it was requested)
        let compactAttestation = AttestedKeyService.CompactAttestation(messageAttestation: attestation)
        guard try validate(message: attestationResponse, attestation: compactAttestation) else {
            return completion(SCError(reason: "signature validation error"))
        }

        // validate each of the included attestations and save if valid
        for a in ar.content.attestations {
            if a.attestedKey == attestedKeyService.getVerifiedPublicKey(certificateChain: a.certs, authData: a.data, clientHash: ar.content.senderDeviceKey.sha256, teamId: Constants.teamId) {
                if let compactAttestation = AttestedKeyService.CompactAttestation(messageAttestation: a) {
                    try attestedKeyStore.saveCompactAttestation(key: compactAttestation.attestedKey, attestation: compactAttestation)
                }
            }
        }

        // now check to see if there is a connectionKeys request with the same id, if so, delete it from the store and process it
        if let connectionKeysRequest: Message.ConnectionRequest = try? keychainStore.get(name: ar.content.id, service: pendingConnectionKeysRequestService) {
            keychainStore.delete(name: ar.content.id, service: pendingConnectionKeysRequestService)
            processIncoming(connectionKeysRequest: connectionKeysRequest, canRequestAttestation: false, completion: completion)
        }
        print("---------------------------------------------------------------------------------\n")
    } catch {
        completion(error)
        print("---------------------------------------------------------------------------------\n")
    }
}
*/

