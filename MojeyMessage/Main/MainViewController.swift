//
//  MainViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/9/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit
import Messages

protocol MainViewControllerDelegate: class {
    func mainViewControllerGetPresentationStyle() -> MSMessagesAppPresentationStyle
    func mainViewControllerRequestPresentationStyle(style: MSMessagesAppPresentationStyle)
    func mainViewControllerGetActiveConversation() -> MSConversation?
}

class MainViewController: UIViewController, MainMojeyTransferViewControllerDelegate, MojeyStorefrontViewControllerDelegate {







    weak var delegate:  MainViewControllerDelegate?

    private let conversation: MSConversation

    private let remoteParticipantProvider = RemoteParticipantProvider.default
    private let participantStore = ParticipantStore.default

    private var remoteParticipant: Participant?

    private var childViewController: UIViewController?
    private var sendMojeyViewController: MainMojeyTransferViewController?
    private var connectionRequestViewController: MainConnectionRequestViewController?



    init(conversation: MSConversation) {
        print("init transscript vc")
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        print(self.view.bounds)
        //let keychain = Keychain(accessGroup: Constants.accessGroup)
        //let tag = "BurnableKey E36F072C-9B4C-412E-B66A-C36022A6584D 048f494b0b8e976f059907934f8702b499e75377d6fd35682895dd86d8f0255f4da7391adce34ff8de2c715572dc1a747c3ec1510a8c84f98a161fc3a8a8130bc0"
        //keychain.deleteEllipticCurveKeys(tag: "BurnableKeysResponse", label: nil)
        //KeyManager.default.printAllSecureEnclaveKeys(tag: nil, label: "02e4b1caa583808dc72eb8393fd65ab6ff16b32506e6b0fca0c2fa16f892e1d90d")
        //MojeyKeyManager.default.printAllSecureEnclaveKeys(tag: nil, label: nil)
        //KeyManager.default.printAttributesForAllSecureEnclaveKeys()
        //KeyManager.default.printGroupedAttributesForAllEllipticCurveKeysSummary()
        selectChildViewController()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.selectChildViewController()
        }

        //MojeyStore.default.printMojeyStore()

        print("!!!!! DEVICES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        if let devices = try? DeviceStore.default.getAllDevices() {
            for device in devices {
                print(device)
                print("---------")
            }
        }
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

        if let participants:[String:Participant] = try? KeychainStore.default.getAll(service: "ParticipantStore") {

            for (n,p) in participants {
                print("---[\(n)]--------------------------------------------------------------------------------")
                print(p.json ?? "")
                BurnablePublicKeysStore.default.printAllBurnablePublicKeys(deviceKey: p.selectedDeviceKey ?? "")
            }
            print("-------------------------------------------------------------------------------------------")
    }

//        print("===KEY===============================================================================")
//        let privSecKey = keychain.createEllipticCurvePrivateKey()
//        print(privSecKey!.externalRepresentation!.hex)
//        print(privSecKey!.publicKey!.externalRepresentation!.hex)
//        print(privSecKey!.publicKey!.externalRepresentation!.compressedPublicKey!.hex)
//        print("======================================================================================")

//        for _ in 1...20 {
//            let rand = arc4random_uniform(1000000000)
//            let message = "\(rand)".data(using: .utf8)!
//            try! Arxan.sign(message: message)
//        }
        //let message = "Hello World".data(using: .utf8)!
        /*
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        //let att = try! KeyManager.default.keychain.getAttributes(uuid: "467781F1-FB5A-4D25-9804-F2ECA064EC0B")
        //print(att)

        //let key = try! KeyManager.default.keychain.getEllipticCurveKey(publicKey: Data(hex: "02aaeb6e13eda800c5f5701ea929496931306f8e37f2cbb8500779388b867f27a8"))
        //print(key.compressedPublicKey.hex)
        print("++++ENCRYPT++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

        let message = "Hello World".data(using: .utf8)!
        print(message.count)
        let ct = try! ArxanEcc.encrypt(message: message, key: TFIT_key_iECEGEfastP256epayload)
        print(ct.count)
        print(ct.hex)

        //TFIT_key_iECEGEfastP256epayload

        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

        let pt = try! ArxanEcc.decrypt(message: ct, key: TFIT_key_iECEGDfastP256dpayload).prefix(message.count)
        print(pt.hex)
        let text = String(data: pt, encoding: .utf8)!
        print(text)

        print("++++++encryptArxanECElGamalAES128++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        let p = try! PayloadCoder.defaut.encryptArxanECElGamalAES128(payload: message)
        print(p.hex)
        print(p.dropFirst(128).hex)
        print("+++++decryptArxanECElGamalAES128+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        let d = try! PayloadCoder.defaut.decryptArxanECElGamalAES128(data: p)
        let dText = String(data: d, encoding: .utf8)!
        print(dText)
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")


        do {
            try OutgoingSequenceStore.default.printOutgoingSequence()
        } catch {
            print(error.scError.reason)
        }
        */
        //print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        //let sf = MainMojeyStorefrontViewController()
        //print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        //presentStorefrontViewController()
        print("!!!!")
    }


    func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == .compact {
            sendMojeyViewController?.showCompact()
        }
        if presentationStyle == .expanded {
            sendMojeyViewController?.showExpanded()
        }
    }
 
    func selectChildViewController() {
        //print("select child vc")
        do {
            let cloudId = try CloudId.cloudId()
            selectChildViewController(remoteParticipantIds: conversation.remoteParticipantIdentifiers, myCloudId: cloudId)
        } catch {
            selectErrorViewController(error: error)
        }
    }

    func selectChildViewController(remoteParticipantIds: [UUID], myCloudId: String) {
        //print("selectChildViewController participants = \(remoteParticipantIds)")
        if let remoteParticipant = remoteParticipantProvider.getRemoteParticipant(identifiers: remoteParticipantIds, myCloudId: myCloudId) {
            //print("found remote participant \(remoteParticipant.json ?? "")")
            self.remoteParticipant = remoteParticipant
            selectChildViewController(remoteParticipant: remoteParticipant)
        } else {
            //print("selectBurnableKeysRequestViewController")
            selectConnectionRequestViewController()
        }
    }


    func selectChildViewController(remoteParticipant: Participant) {
        if participantStore.numberOfBurnablePublicKeysForSelectedDevice(participantId: remoteParticipant.participantId) > 0 {
            selectSendMojeyViewController()
        } else {
            selectConnectionRequestViewController()
        }
    }


    private func selectSendMojeyViewController() {
        if childViewController != nil && childViewController == sendMojeyViewController { return }
        sendMojeyViewController = MainMojeyTransferViewController(conversation: conversation)
        sendMojeyViewController?.delegate = self
        setChild(viewController: sendMojeyViewController)
    }


    private func selectConnectionRequestViewController() {
        //print("selectBurnableKeysRequestViewController")
        //print(childViewController)
        if childViewController != nil && childViewController == connectionRequestViewController { return }
        connectionRequestViewController = MainConnectionRequestViewController(conversation: conversation)
        //print(burnableKeyRequestViewController)
        setChild(viewController: connectionRequestViewController)
    }

    private func setChild(viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        childViewController?.view.removeFromSuperview()
        childViewController?.removeFromParent()
        childViewController?.view = nil
        addChild(viewController)
        view.addSubview(viewController.view)
        childViewController = viewController
        //print(childViewController)
    }


    private func selectErrorViewController(error: Error) {
        print("ERROR ERROR ERROR !!")
    }


    func mainSendMojeyViewControllerDidTransfer() {
        selectChildViewController()
    }

    func presentStorefrontViewController() {
        let storefrontViewController = MojeyStorefrontViewController()
        storefrontViewController.delegate = self
        self.present(storefrontViewController, animated: true, completion: nil)
        delegate?.mainViewControllerRequestPresentationStyle(style: .expanded)
    }

    func mainMojeyTransferViewControllerDidSelectAddMojey() {
        presentStorefrontViewController()
    }

    func mojeyStorefrontViewControllerDidFinish() {
        print("Did finish")
        self.dismiss(animated: true, completion: nil)
        delegate?.mainViewControllerRequestPresentationStyle(style: .compact)
    }

}
