//
//  MainConnectionRequestViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/1/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import Messages
import UIKit

class MainConnectionRequestViewController: UIViewController {

    private let conversation: MSConversation

    private let askButton = UIButton()

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
        self.view.backgroundColor = UIColor.black
        askButton.setTitle("Ready for some Mojey?", for: .normal)
        askButton.backgroundColor = UIColor(white: 0.1, alpha: 1)
        askButton.setTitleColor(UIColor.white, for: .normal)
        let askWidth: CGFloat = 300
        let askX: CGFloat = (self.view.frame.size.width - askWidth) / 2
        askButton.frame = CGRect(x: askX, y: 100, width: askWidth, height: 50)
        askButton.layer.cornerRadius = askButton.frame.size.height/2
        askButton.titleLabel?.font = UIFont.systemFont(ofSize: askButton.frame.size.height * 0.4, weight: .regular)
        askButton.addTarget(self, action: #selector(didTapAsk), for: .touchUpInside)
        self.view.addSubview(askButton)
    }

    @objc func didTapAsk() {
        try? sendConnectionRequest(text: askButton.title(for: .normal) ?? "")
    }

    private func sendConnectionRequest(text: String) throws {
        let connectionRequest = try ConnectionKeysRequest.new(text: text)
        let payload = try PayloadCoder.defaut.composePayload(connectionRequest, version: 1, type: .connectionRequest, encoding: .jsonUtf8, encryption: .none).urlSafeBase64
        let message = MSMessage.new(session: MSSession(), text: text, image: nil, query: ["p":payload])
        conversation.send(message, completionHandler: nil)
    }

}
