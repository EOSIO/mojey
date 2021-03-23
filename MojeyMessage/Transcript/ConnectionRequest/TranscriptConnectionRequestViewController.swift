//
//  TranscriptKeysRequestViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/22/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit
import Messages

class TranscriptConnectionRequestViewController: UIViewController, TranscriptChildViewController, TranscriptConnectionRequestViewDelegate {

    private let message: MSMessage?
    private let conversation: MSConversation
    private let keysRequest: ConnectionKeysRequest?
    private var keysRequestView: TranscriptConnectionRequestView!

    private let connectionManager = ConnectionKeysManager.default

    private var amISender: Bool {
        guard let message = self.message else { return false }
        if conversation.localParticipantIdentifier == message.senderParticipantIdentifier { return true }
        guard let cloudId = try? CloudId.cloudId() else { return false }
        return keysRequest?.content.senderDevice.cloudId == cloudId
    }

    var size: CGSize = CGSize(width: 320, height: 120)

    private var responseText: String? {
        return amISender ? nil : "I want some Mojey"
    }


    init(conversation: MSConversation, requestPayload: Data) throws {
        print("init TranscriptKeysRequestViewController:")
        self.conversation = conversation
        self.message = conversation.selectedMessage
        self.keysRequest = try PayloadCoder.defaut.decodePayload(payload: requestPayload)
        print("---senderParticipantIdentifier")
        print(message?.senderParticipantIdentifier ?? "")
        super.init(nibName: nil, bundle: nil)
        if amISender {
            size = CGSize(width: 320, height: 70)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TranscriptKeysRequestViewController: viewDidLoad")
        keysRequestView = TranscriptConnectionRequestView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), text: keysRequest?.content.text ?? "", responseText: responseText)
        keysRequestView.delegate = self
        self.view.addSubview(keysRequestView)
    }


    internal func transcriptConnectionRequestViewDidSelectYes() {
        do {
            try processConnectionRequestYes()
        } catch {
            print("==ERROR==========================================")
            print(error.scError.reason)
            print("=================================================")
        }
    }


    private func processConnectionRequestYes() throws {
        print("processConnectionRequest")
        guard !amISender else { return }
        guard let message = message else { return }
        guard let keysRequest = keysRequest else { return }
        let participantId = message.senderParticipantIdentifier.uuidString
        let text = "I want some Mojey"

        let keysResponse = try connectionManager.process(connectionKeysRequest: keysRequest, participantId: participantId, text: text)
        let payload = try PayloadCoder.defaut.composePayload(keysResponse, version: 1, type: .connectionResponse, encoding: .jsonUtf8, encryption: .none).urlSafeBase64
        let newMessage = MSMessage.new(session: self.message?.session, text: text, image: nil, query: ["p":payload])
        conversation.send(newMessage, completionHandler: nil)
    }


}
