//
//  MojeyViewCell.swift
//  EmojiOne
//
//  Created by Todd Bowden on 9/18/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

class MojeyViewCell: UICollectionViewCell {

    var mojeyQuantity: MojeyQuantity? {
        didSet {
            mojeyView?.removeFromSuperview()
            guard let mq = mojeyQuantity else { return }
            mojeyView = MojeyView(frame: CGRect.zero, mojeyQuantity: mq)
        }
    }
    var isEnabled: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    var shouldPulse: Bool = false

    private var mojeyView: MojeyView?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        mojeyQuantity = nil
        isEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let mojeyView = mojeyView else { return }
        mojeyView.frame = self.bounds
        mojeyView.alpha = isEnabled ? 1 : 0.4
        if mojeyView.superview == nil {
            self.addSubview(mojeyView)
        }

        if shouldPulse {
            shouldPulse = false
            mojeyView.pulse()
        }
    }


}
