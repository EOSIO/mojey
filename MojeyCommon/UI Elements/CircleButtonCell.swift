//
//  CircleButtonCell.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/31/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

class CircleButtonCell: UICollectionViewCell {

    var isEnabled: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }

    var diameter: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    var color: UIColor {
        get { return circleButton.color }
        set { circleButton.color = newValue }
    }
    var text: String {
        get { return circleButton.text }
        set { circleButton.text = newValue }
    }
    var textColor: UIColor {
        get { return circleButton.textColor }
        set { circleButton.textColor = newValue }
    }
    var fontSize: CGFloat {
        get { return circleButton.fontSize }
        set { circleButton.fontSize = newValue }
    }
    var fontWeight: UIFont.Weight {
        get { return circleButton.fontWeight }
        set { circleButton.fontWeight = newValue }
    }

    var tap: (()->Void)? {
        get { return circleButton.tap }
        set { circleButton.tap = newValue }
    }

    private var circleButton = CircleButton()


    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(circleButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        circleButton.removeFromSuperview()
        circleButton = CircleButton()
        addSubview(circleButton)
        isEnabled = true
        tap = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let x = (self.sizeWidth - diameter) / 2
        let y = (self.sizeHeight - diameter) / 2
        circleButton.frame =  CGRect(x: x, y: y, width: diameter, height: diameter)
        circleButton.alpha = isEnabled ? 1 : 0.4
    }


}

