//
//  TransscriptViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/9/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit
import Messages


protocol TranscriptChildViewController: UIViewController {
    var size: CGSize { get set }
}

protocol TranscriptViewControllerDelegate: class {
    func transcriptViewControllerGetActiveConversation() -> MSConversation?
}

class TranscriptViewController: UIViewController {


    private let message: MSMessage?
    private let conversation: MSConversation

    private var childViewController: TranscriptChildViewController?

    private let messageKeysManager = ConnectionKeysManager.default

    var size = CGSize(width: 310, height: 150) {
        didSet {
            childViewController?.size = self.size
        }
    }

    func contentSizeThatFits(_ size: CGSize) -> CGSize {
        // if current size is greater than the max size, then reduce current size to max size
        var newSize = self.size
        if newSize.width > size.width {
            newSize.width = size.width
        }
        if newSize.height > size.height {
            newSize.height = size.height
        }
        self.size = newSize
        print("--- contentSizeThatFits size = \(self.size)")
        return self.size
    }


    init(conversation: MSConversation) throws {
        print("init transscript vc")
        self.conversation = conversation
        self.message = conversation.selectedMessage
        print("---senderParticipantIdentifier")
        print(message?.senderParticipantIdentifier.uuidString ?? "")
        super.init(nibName: nil, bundle: nil)

        // process message
        guard let message = message else { return }
        guard let queryDict = message.url?.dictionaryFromQueryItems else { return }

        // decrypt payload
        let payloadCoder = PayloadCoder.defaut
        guard let base64Payload = queryDict["p"] else {
            throw SCError(reason: "Message does not include a payload")
        }
        var payload = try Data(urlSafeBase64: base64Payload)
        let version = try payloadCoder.payloadVersion(payload: payload)
        payload = try payloadCoder.stripHeader(payload: payload)
        payload = try payloadCoder.decryptPayload(payload: payload)
        let payloadType = try payloadCoder.payloadType(version: version, payload: payload)
        payload = try payloadCoder.stripPayloadType(payload: payload)

        switch payloadType {
        case .connectionRequest:
            let keysRequestViewController = try TranscriptConnectionRequestViewController(conversation: conversation, requestPayload: payload)
            childViewController = keysRequestViewController
            self.size = keysRequestViewController.size
        case .connectionResponse:
            let keysResponseViewController = try TranscriptConnectionResponseViewController(conversation: conversation, responsePayload: payload)
            childViewController = keysResponseViewController
            self.size = keysResponseViewController.size
        case .transfer:
            let mojeyTransferViewController = try TranscriptMojeyTransferViewController(conversation: conversation, transferPayload: payload)
            childViewController = mojeyTransferViewController
            self.size = mojeyTransferViewController.size
        case .thanks:
            let thanksViewController = try TranscriptThanksViewController(conversation: conversation, payload: payload)
            childViewController = thanksViewController
            self.size = thanksViewController.size
        }

        

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Transscript VC did load")
        self.view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        //processMessage()
        guard let childViewController = childViewController else { return }
        self.addChild(childViewController)
        self.view.addSubview(childViewController.view)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }


}
