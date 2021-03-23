//
//  MojeyView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/11/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

class MojeyView: UIView {
    private let mojeyLabel = UILabel()
    private let badgeLabel = UILabel()

    let mojey: String

    private(set) var quantity: UInt64 = 0

    func set(quantity: UInt64, animate: Bool = true) {
        self.quantity = quantity
        refreshBadge(animate: animate)
    }

    var mojeyQuantity: MojeyQuantity {
        get {
            return MojeyQuantity(mojey: mojey, quantity: quantity)
        }
    }

    convenience init(frame: CGRect, mojeyQuantity: MojeyQuantity) {
        self.init(frame: frame, mojey: mojeyQuantity.mojey, quantity: mojeyQuantity.quantity)
    }

    init(frame: CGRect, mojey: String, quantity: UInt64 = 0) {
        self.mojey = mojey
        self.quantity = quantity
        super.init(frame: frame)
        mojeyLabel.text = mojey
        self.addSubview(mojeyLabel)
        self.addSubview(badgeLabel)
        badgeLabel.textAlignment = .center
        mojeyLabel.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        mojeyLabel.frame = self.bounds
        mojeyLabel.font = UIFont.systemFont(ofSize: self.frame.size.height*0.5, weight: .regular)
        mojeyLabel.layer.shadowColor = UIColor.black.cgColor
        mojeyLabel.layer.shadowOpacity = 1
        mojeyLabel.layer.shadowRadius = 5
        mojeyLabel.layer.shadowOffset = CGSize.zero
        refreshBadge(animate: false)
    }

    private func refreshBadge(animate: Bool = true) {
        let duration: TimeInterval = animate ? 0.3 : 0
        let badgeAlpha: CGFloat = quantity < 2 ? 0 : 1
        let badgeText = "\(quantity)"
        print(badgeText)
        let badgeHeight = self.frame.size.height * 0.2
        let badgeFont = UIFont.systemFont(ofSize: badgeHeight*0.6, weight: .semibold)
        let boundingSize = badgeText.boundingSize(font: badgeFont, constrainedToSize: self.frame.size)
        //print("badge = \(badgeText) size = \(boundingSize)")

        let badgeWidth = boundingSize.width + badgeHeight/2
        let badgeX = (self.frame.size.width - badgeWidth) / 2
        let badgeY = badgeHeight * 0.2
        self.badgeLabel.layer.cornerRadius = badgeHeight * 0.5
        badgeLabel.backgroundColor = UIColor.darkGray
        badgeLabel.textColor = UIColor.white
        badgeLabel.font = badgeFont
        badgeLabel.layer.cornerRadius = badgeHeight / 2
        badgeLabel.text = badgeText
        badgeLabel.clipsToBounds = true
        UIView.animate(withDuration: duration) {
            self.badgeLabel.frame = CGRect(x: badgeX, y: badgeY, width: badgeWidth, height: badgeHeight)
            self.badgeLabel.alpha = badgeAlpha

        }
    }

    func pulse() {
        UIView.animate(withDuration: 0.1, animations: {
            self.mojeyLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.badgeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (finished) in
            UIView.animate(withDuration: 0.1, animations: {
                self.mojeyLabel.transform = CGAffineTransform.identity
                self.badgeLabel.transform = CGAffineTransform.identity
            })
        }
    }

}


