//
//  TranscriptKeysResponseView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/20/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

class TranscriptConnectionResponseView: UIView {

    private let label = UILabel()
    private let text: String

    init(frame: CGRect, text: String) {
        self.text = text
        super.init(frame: frame)
        label.text = text //"I'm Ready for\nsome Mojey 😄"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor.white
        self.addSubview(label)
        self.backgroundColor = UIColor.mojeyOrange
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        label.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
    }
}

