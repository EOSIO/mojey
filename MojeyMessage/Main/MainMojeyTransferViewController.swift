//
//  MainMojeyTransferViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/11/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import Messages
import UIKit

protocol MainMojeyTransferViewControllerDelegate: class {
    func mainMojeyTransferViewControllerDidSelectAddMojey()
}

class MainMojeyTransferViewController: UIViewController, MojeyTransferStagingViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    weak var delegate: MainMojeyTransferViewControllerDelegate?

    private let conversation: MSConversation

    private let mojeyStore = MojeyStore.default

    private let stagingView = MojeyTransferStagingView()
    private var stagedMojey = MojeyCollection()
    private var oldAdjustedInventoryMojey = MojeyCollection()
    private var fullInventoryMojey = MojeyCollection()
    private var adjustedInventoryMojey = MojeyCollection()
    private let collectionView: UICollectionView

    private var compactLayout = UICollectionViewFlowLayout()
    private var expandedLayout = UICollectionViewFlowLayout()
    

    private var mojeyArray = ["😀","😀","😎","😎","😺","❤️","😎","😺","👽","😻","🖖"]


    init(conversation: MSConversation) {
        print("init transscript vc")
        self.conversation = conversation
        //let flowLayout = UICollectionViewFlowLayout()
        compactLayout.scrollDirection = .horizontal
        compactLayout.itemSize = CGSize(width: 65, height: 100)
        compactLayout.minimumInteritemSpacing = 0

        expandedLayout.scrollDirection = .vertical
        expandedLayout.itemSize = CGSize(width: 65, height: 100)
        expandedLayout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: expandedLayout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stagingView.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 100)
        stagingView.backgroundColor = UIColor.black
        stagingView.delegate = self
        self.view.addSubview(stagingView)
        self.view.backgroundColor = UIColor.black
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))

        collectionView.frame = CGRect(x: 0, y: stagingView.bottomY+10, width: self.view.frame.size.width, height: 100)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MojeyViewCell.self, forCellWithReuseIdentifier: "MojeyViewCell")
        collectionView.register(CircleButtonCell.self, forCellWithReuseIdentifier: "CircleButtonCell")
        collectionView.backgroundColor = UIColor.black
        collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionView)
        try? refreshInventory()

        self.view.addSubview(stagingView)

        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            try? self.pollMojey()
        }
    }

    func showCompact() {
        collectionView.collectionViewLayout = compactLayout
        collectionView.frame = CGRect(x: 0, y: stagingView.bottomY+10, width: self.view.frame.size.width, height: 100)
    }

    func showExpanded() {
        collectionView.collectionViewLayout = expandedLayout
        collectionView.frame = CGRect(x: 0, y: stagingView.bottomY+10, width: self.view.frame.size.width, height: 700)
    }


    private func pollMojey() throws {
        //print("poll")
        if (try mojeyStore.getExistingMojey()) != fullInventoryMojey {
            print("UPDATE DETECTED")
            try refreshInventory()
        }
    }


    @objc func didTap() {
        print("didTap")
        let mojey = mojeyArray[Int(arc4random_uniform(UInt32(mojeyArray.count)))]
        //let mojey = mojeyArray[0]
        //mojeyArray.remove(at: 0)
        print(mojey)
        //let mojeyQuantity = MojeyQuantity(mojey: mojey, quantity: 1)
        //try? stage(mojeyQuantity: mojeyQuantity, startingFrame: CGRect(x: 100, y: stagingView.bottomY + 20, width: stagingView.sizeHeight, height: stagingView.sizeHeight))
    }


    func stage(mojeyQuantity: MojeyQuantity, startingFrame: CGRect) throws -> Bool {
        guard !stagingView.isAnimating else { return false }
        stagedMojey = try stagedMojey.add(mojeyQuantity)
        print("STAGED MOJEY : \(try! stagedMojey.string())")
        //let startingFrame = CGRect(x: 100, y: stagingView.bottomY + 20, width: stagingView.sizeHeight, height: stagingView.sizeHeight)
        let _ = stagingView.add(mojeyQuantity: mojeyQuantity, startingFrame: startingFrame, animationDuration: 0.15)
        return true
    }


    private func send(mojey: String) throws {
        print(":::::::remoteParticipantIdentifiers ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
        print(conversation.remoteParticipantIdentifiers)
        print(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
        guard let participant = RemoteParticipantProvider.default.getRemoteParticipant(identifiers: conversation.remoteParticipantIdentifiers) else { return }
        print("Participant = \(participant.participantId)")
        print("::Participant:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
        print(participant)
        let mojeyTransfer = try MojeyTransferManager.defaut.createMojeyTransfer(mojey: mojey, participant: participant)
        print(":::::::mojeyTransfer ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
        print(mojeyTransfer.json ?? "")
        print(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")

        let payload = try PayloadCoder.defaut.composePayload(mojeyTransfer, version: 1, type: .transfer, encoding: .jsonUtf8, encryption: .arxanECElGamalAES128)
        let payloadB64 = payload.urlSafeBase64
        //let hexQuery = try mojeyTransfer.toJsonData().urlSafeBase64
        print("PAYLOAD SIZE = \(payloadB64.count)")
        print(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
        let message = MSMessage.new(session: nil, text: nil, image: nil, query: ["p":payloadB64])
        print(message)
        conversation.send(message) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }



    func mojeyTransferStagingView(view: MojeyTransferStagingView, didSelect mojeyQuantity: MojeyQuantity, index: Int) {

    }


    func mojeyTransferStagingViewDidTapSend(view: MojeyTransferStagingView) {
        do {
            try send(mojey: stagedMojey.string())
        } catch {
            print(error)
        }
        stagedMojey = MojeyCollection()
        stagingView.clear()
    }



    private func refreshInventory() throws  {

        fullInventoryMojey = try mojeyStore.getExistingMojey()
        //print(try! fullInventoryMojey.string())
        oldAdjustedInventoryMojey = adjustedInventoryMojey
        adjustedInventoryMojey = try fullInventoryMojey.subtract(stagedMojey)
        //print(try! adjustedInventoryMojey.string())
        collectionView.reloadData()
    }


    private func getMojey(indexPath: IndexPath) -> MojeyQuantity? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MojeyViewCell else { return nil }
        guard let mojey = adjustedInventoryMojey[indexPath.item-1] else { return nil }
        guard mojey == cell.mojeyQuantity else { return nil }
        return mojey
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adjustedInventoryMojey.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleButtonCell", for: indexPath) as! CircleButtonCell
            cell.text = "＋"
            cell.textColor = .black
            cell.color = .white
            cell.fontWeight = .regular
            cell.diameter = 48
            cell.tap = {
                self.delegate?.mainMojeyTransferViewControllerDidSelectAddMojey()
            }
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MojeyViewCell", for: indexPath) as! MojeyViewCell
        let mojeyQuantity = adjustedInventoryMojey[indexPath.item-1]
        cell.mojeyQuantity = mojeyQuantity
        if stagedMojey.count >= 5 {
            cell.isEnabled = stagedMojey.unique.contains(mojeyQuantity?.mojey ?? "")
        }
        if let mojeyQuantity = mojeyQuantity, let oldMojeyQuantity = oldAdjustedInventoryMojey[mojeyQuantity.mojey], mojeyQuantity.quantity > oldMojeyQuantity.quantity {
             cell.shouldPulse = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item > 0 else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? MojeyViewCell else { return }
        guard let mojey = getMojey(indexPath: indexPath) else { return }
        print("TAP \(indexPath.item) \(mojey.mojey) \(mojey.quantity)")
        if cell.isEnabled {
            try? processTap(cell: cell, mojey: mojey.mojey)
        }

    }


    private func processTap(cell: MojeyViewCell, mojey: String) throws {
        let x = cell.frame.origin.x - collectionView.contentOffset.x
        //let y = cell.frame.origin.y - collectionView.contentOffset.y
        let y = collectionView.originY - stagingView.originY + (cell.frame.origin.y - collectionView.contentOffset.y)
        let startingFrame = CGRect(origin: CGPoint(x: x, y: y), size: cell.frame.size)
        if try stage(mojeyQuantity: MojeyQuantity(mojey: mojey, quantity: 1), startingFrame: startingFrame) {
            try refreshInventory()
        }
    }


}


