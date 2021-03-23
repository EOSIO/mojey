//
//  BalanceView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/10/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

protocol BalanceViewDelegate: class {
    func didTapBalanceView(_ balanceView: BalanceView)
}


class BalanceView: UIView {

    weak var delegate: BalanceViewDelegate?

    private let emojiView = UIImageView()
    private let balanceLabel = UILabel()

    var emoji: UIImage? {
        didSet {
            emojiView.image = emoji
            setNeedsLayout()
        }
    }

    var balance: UInt64 = 0 {
        didSet {
            balanceLabel.text = "\(balance)"
            setNeedsLayout()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        self.emojiView.image = emoji
        self.balanceLabel.textColor = .black
        self.balanceLabel.alpha = 0.5
        self.addSubview(emojiView)
        self.addSubview(balanceLabel)
        emojiView.isUserInteractionEnabled = false
        emojiView.contentMode = .scaleAspectFit
        balanceLabel.isUserInteractionEnabled = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.frame.size.height
        let font = UIFont.systemFont(ofSize: height * 0.85, weight: .light)
        balanceLabel.font = font
        let labelSize = balanceLabel.text?.boundingSize(font: font, constrainedToSize: self.frame.size) ?? CGSize.zero
        let space: CGFloat = 10
        let x = (self.frame.size.width - height - space - labelSize.width) / 2
        emojiView.frame = CGRect(x: x, y: 0, width: height, height: height)
        let balanceX = emojiView.frame.origin.x + emojiView.frame.size.width + space
        balanceLabel.frame = CGRect(x: balanceX, y: 0, width: labelSize.width, height: height)
    }

    @objc func didTap() {
        delegate?.didTapBalanceView(self)
    }
}
