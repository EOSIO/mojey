//
//  TransscriptMojeyTransferViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/9/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import Messages


class TranscriptMojeyTransferViewController: UIViewController, TranscriptChildViewController {

    static let maxViewSize = CGSize(width: 320, height: 140)

    private let message: MSMessage?
    private let conversation: MSConversation

    private let mojeyTransfer: MojeyTransfer
    private var mojeyTransferView: TranscriptMojeyTransferView?

    private let mojeyTransferManafer = MojeyTransferManager.defaut
    private let transferStore = TransferStore.default

    private let participantStore = ParticipantStore.default

    private var hostingController: UIViewController
    private var viewModel: TransscriptMojeyTransfer.Model

    private var amISender: Bool {
        guard let message = self.message else { return false }
        if conversation.localParticipantIdentifier == message.senderParticipantIdentifier { return true }
        guard let cloudId = try? CloudId.cloudId() else { return false }
        print("????? \(cloudId) ?= \(mojeyTransfer.content.senderDevice.cloudId)")
        return mojeyTransfer.content.senderDevice.cloudId == cloudId
    }

    private var amITarget: Bool {
        guard let deviceKey = try? DeviceKey.deviceKey() else { return false }
        return mojeyTransfer.content.targetDevice.key == deviceKey.compressedPublicKey ||
               mojeyTransfer.content.targetDevice.key == deviceKey.uncompressedPublicKey
    }

    var size: CGSize = TranscriptMojeyTransferViewController.maxViewSize {
        didSet {
            self.view.setNeedsLayout()
        }
    }

    static func maxWidth(numMojey: Int) -> CGFloat {
        switch numMojey {
        case 1: return 180
        case 2: return 220
        case 3: return 260
        case 4: return 300
        default: return 320
        }
    }

    init(conversation: MSConversation, transferPayload: Data) throws {
        print("init TranscriptKeysRequestViewController:")
        self.conversation = conversation
        self.message = conversation.selectedMessage
        print("---senderParticipantIdentifier")
        print(message?.senderParticipantIdentifier ?? "")
        mojeyTransfer = try PayloadCoder.defaut.decodePayload(payload: transferPayload)
        size = CGSize(width: TranscriptMojeyTransferViewController.maxWidth(numMojey: mojeyTransfer.content.numberOfDisplayMojey), height: size.height)
        hostingController = UIViewController()
        viewModel = TransscriptMojeyTransfer.Model()
        super.init(nibName: nil, bundle: nil)
        //size = CGSize(width: maxWidth(numMojey: mojeyTransfer.content.numberOfDisplayMojey), height: size.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .brown
        print("TranscriptKeysRequestViewController: viewDidLoad")
        do {
            viewModel.mojeyQuantities = try MojeyCollection(string: mojeyTransfer.content.displayMojey).array
            viewModel.info = .none
            viewModel.isDim =  amISender || amITarget ? false : true
            let icon = "icon-" + UIDevice.modelNameCase(identifier: mojeyTransfer.content.targetDevice.model).case
            viewModel.targetDevice = TransscriptMojeyTransfer.Device(
                sent: "Sent to",
                device: mojeyTransfer.content.targetDevice.modelName,
                name: mojeyTransfer.content.targetDevice.name,
                icon: icon)


            let subscriber = Subscribers.Sink<Bool, Never>(
               receiveCompletion: { completion in
             }) { shouldSendThanks in
                if shouldSendThanks {
                    try? self.sendThanks()
                }
            }

            self.viewModel.$sendThanks.subscribe(subscriber)

            let transscriptMojeyTransfer =  TransscriptMojeyTransfer(model: viewModel)
            hostingController = UIHostingController(rootView: transscriptMojeyTransfer)
            self.addChild(hostingController)
            self.view.addSubview(hostingController.view)

            // if I am the target device, proccess transfer, otherwise update the info to show the target device
            if amITarget {
                try processMojeyTransfer()
            } else if amISender {
                viewModel.info = .none
            } else {
                let icon = "icon-" + UIDevice.modelNameCase(identifier: mojeyTransfer.content.targetDevice.model).case
                let device = TransscriptMojeyTransfer.Device(
                    sent: "Sent to",
                    device: mojeyTransfer.content.targetDevice.modelName,
                    name: mojeyTransfer.content.targetDevice.name,
                    icon: icon)
                viewModel.info = .device(target: device)
            }

            // update participant record for sender
            if let message = self.message, !amISender {
                let _ = try? participantStore.update(
                    participantId: message.senderParticipantIdentifier.uuidString,
                    cloudId: mojeyTransfer.content.senderDevice.cloudId,
                    selectedDeviceKey: mojeyTransfer.content.senderDevice.key.hex,
                    date: mojeyTransfer.content.date)
            }

            try? DeviceStore.default.save(deviceInfo: mojeyTransfer.content.targetDevice)
            try? DeviceStore.default.save(deviceInfo: mojeyTransfer.content.senderDevice)


        } catch {
            print("PROCESSING ERROR \(error.scError.reason)")
            viewModel.info = .error(error: error.scError.reason)
        }

    }

    private func getViewFrame() -> CGRect {
        var viewFrame = self.view.superview?.bounds ?? self.view.frame
        let maxViewSize = TranscriptMojeyTransferViewController.maxViewSize
        if viewFrame.width > maxViewSize.width {
            viewFrame = CGRect(x: 0, y: 0, width: maxViewSize.width, height: viewFrame.height)
        }
        if viewFrame.height > maxViewSize.height {
             viewFrame = CGRect(x: 0, y: 0, width: viewFrame.width, height: maxViewSize.height)
         }
        return viewFrame
    }

     
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame = CGRect(origin: CGPoint.zero, size: size)
        //mojeyTransferView?.frame = self.view.superview?.bounds ?? self.view.frame
        hostingController.view.frame = getViewFrame()
    }

    private func refreshStatus(id: String) {
        if let status = try? transferStore.getTransferStatus(id: id) {
            if status.success {
                mojeyTransferView?.status = .success
                viewModel.info = .success
            } else if let error = status.error {
                mojeyTransferView?.status = .error
                viewModel.info = .error(error: error)
            }
        }
    }

    private func processMojeyTransfer() throws {
        print("processMojeyTransfer")
        guard !amISender && amITarget else { return }

        let id = mojeyTransfer.content.id
        refreshStatus(id: id)
        if let status = try? transferStore.getTransferStatus(id: id), status.success {
            return
        }

        guard let compressedHexKey = mojeyTransfer.content.encryptionPubKey.compressedPublicKey?.hex else { return }
        print(compressedHexKey)
        do {
            try mojeyTransferManafer.process(mojeyTransfer: mojeyTransfer)
            refreshStatus(id: mojeyTransfer.content.id)
        } catch {
            refreshStatus(id: mojeyTransfer.content.id)
            throw error
        }

    }


    private func sendThanks() throws {
        let thanks = MojeyThanks()
        let payload = try PayloadCoder.defaut.composePayload(thanks, version: 1, type: .thanks, encoding: .jsonUtf8, encryption: .none).urlSafeBase64
        let newMessage = MSMessage.new(session: self.message?.session, text: "Thanks!", image: nil, query: ["p":payload])
        conversation.send(newMessage, completionHandler: nil)
    }


}
