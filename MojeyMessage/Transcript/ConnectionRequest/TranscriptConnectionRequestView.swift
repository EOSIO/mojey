//
//  TranscriptKeysRequestView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/19/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

protocol TranscriptConnectionRequestViewDelegate: class {
    func transcriptConnectionRequestViewDidSelectYes()
}


class TranscriptConnectionRequestView: UIView {

    weak var delegate: TranscriptConnectionRequestViewDelegate?

    private let questionLabel = UILabel()
    private let yesButton = UIButton()
    private let showButton: Bool
    private let responseText: String?

    init(frame: CGRect, text: String, responseText: String?) {
        self.responseText = responseText
        self.showButton = responseText != nil
        super.init(frame: frame)
        self.backgroundColor = UIColor.mojeyOrange
        questionLabel.text = text
        questionLabel.textAlignment = .center
        questionLabel.textColor = .white
        questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        yesButton.setTitle(responseText, for: .normal)
        yesButton.addTarget(self, action: #selector(didTapYes), for: .touchUpInside)
        yesButton.setTitleColor(UIColor.mojeyOrange, for: .normal)
        yesButton.titleLabel?.textAlignment = .center
        yesButton.backgroundColor = UIColor.white
        self.addSubview(questionLabel)
        if showButton {
            self.addSubview(yesButton)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        if yesButton.superview == nil {
            questionLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        } else {
            questionLabel.frame = CGRect(x: 0, y: 20, width: self.frame.size.width, height: self.frame.size.height/2 - 10)
            questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            yesButton.frame = CGRect(x: 20, y: questionLabel.bottomY, width: self.frame.size.width-40, height: self.frame.size.height - questionLabel.bottomY - 10)
            yesButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            yesButton.layer.cornerRadius = yesButton.sizeHeight * 0.25
        }
    }


    @objc func didTapYes() {
        delegate?.transcriptConnectionRequestViewDidSelectYes()
    }





}
