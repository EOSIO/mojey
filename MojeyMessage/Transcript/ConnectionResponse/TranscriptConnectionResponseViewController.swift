//
//  TranscriptConnectionResponseViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/23/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit
import Messages

class TranscriptConnectionResponseViewController: UIViewController, TranscriptChildViewController {

    private let message: MSMessage?
    private let conversation: MSConversation
    private let connectionResponse: ConnectionKeysResponse?
    private var connectionResponseView: TranscriptConnectionResponseView!

    private let connectionKeysManager = ConnectionKeysManager.default

    private var amISender: Bool {
        guard let message = self.message else { return false }
        if conversation.localParticipantIdentifier == message.senderParticipantIdentifier { return true }
        guard let connectionResponse = connectionResponse else { return false }
        guard let cloudId = try? CloudId.cloudId() else { return false }
        return connectionResponse.content.senderDevice.cloudId == cloudId
    }

    var size: CGSize = CGSize(width: 250, height: 70)

    init(conversation: MSConversation, responsePayload: Data) throws {
        print("init TranscriptKeysResponseViewController:")
        self.conversation = conversation
        self.message = conversation.selectedMessage
        self.connectionResponse = try PayloadCoder.defaut.decodePayload(payload: responsePayload)
        print("---senderParticipantIdentifier")
        print(message?.senderParticipantIdentifier ?? "")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TranscriptKeysResponseViewController: viewDidLoad")
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        connectionResponseView = TranscriptConnectionResponseView(frame: frame, text: "I want some Mojey")
        self.view.addSubview(connectionResponseView)
        if !amISender {
            do {
                try processConnectionResponse()
            } catch {
                print("===ERROR=====")
                print(error.scError.reason)
            }

        }
    }

    // process the keysResponse. Check if this device has the key to decrypt the burnableKeys, if so decrypt the keys and add to participant store
    private func processConnectionResponse() throws {
        print("processConnectionResponse")
        guard let message = message else { return }
        print(message)
        guard let keysResponse = connectionResponse else { return }
        print(keysResponse)
        guard let compressedHexKey = keysResponse.content.encryptionPubKey.compressedPublicKey?.hex else { return }
        print(compressedHexKey)
        guard MojeyKeyManager.default.doesKeyExist(publicKey: compressedHexKey) else {
            print("key \(compressedHexKey) does not exist"); return
        }
        print("KeyExist")

        let participantId = message.senderParticipantIdentifier.uuidString
        try connectionKeysManager.process(connectionKeysResponse: keysResponse, participantId: participantId)

    }


}
