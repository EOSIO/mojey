//
//  TranscriptThanksViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 1/28/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SwiftUI
import Messages

class TranscriptThanksViewController: UIViewController, TranscriptChildViewController {

    private let message: MSMessage?
    private let conversation: MSConversation
    private let mojeyThanks: MojeyThanks?

    private let connectionManager = ConnectionKeysManager.default

    private var hostingController = UIViewController()

    private var amISender: Bool {
        guard let message = self.message else { return false }
        if conversation.localParticipantIdentifier == message.senderParticipantIdentifier { return true }
        guard let cloudId = try? CloudId.cloudId() else { return false }
        return mojeyThanks?.content.senderDevice.cloudId == cloudId
    }

    var size: CGSize = CGSize(width: 200, height: 60)

    private var responseText: String? {
        return amISender ? nil : "I want some Mojey"
    }


    init(conversation: MSConversation, payload: Data) throws {
        self.conversation = conversation
        self.message = conversation.selectedMessage
        self.mojeyThanks = try PayloadCoder.defaut.decodePayload(payload: payload)
        print("---senderParticipantIdentifier")
        print(message?.senderParticipantIdentifier ?? "")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TranscriptKeysRequestViewController: viewDidLoad")
        hostingController = UIHostingController(rootView: TransscriptThanks())
        self.addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = self.view.bounds
        if !amISender {
            try? processThanks()
        }

    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame = CGRect(origin: CGPoint.zero, size: size)
        //mojeyTransferView?.frame = self.view.superview?.bounds ?? self.view.frame
        hostingController.view.frame = self.view.bounds
    }


    private func processThanks() throws {
        print("processThanks")
        guard let mojeyThanks = mojeyThanks else { return }
        try DeviceStore.default.save(deviceInfo: mojeyThanks.content.senderDevice)
    }


}
