//
//  TranscriptMojeyTransferView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/16/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

class TranscriptMojeyTransferView: UIView {

    enum Status {
        case unknown
        case success
        case error
    }

    private var mojeyViews = [MojeyView]()
    private let mojeyCollection: MojeyCollection
    private let statusView = UIImageView() 
    let maxMojeyItems = 5
    var status: Status = .unknown {
        didSet {
            refreshStatus()
        }
    }

    init(frame: CGRect, mojeyTransfer: MojeyTransfer) {
        mojeyCollection = (try? MojeyCollection(string: mojeyTransfer.content.displayMojey)) ?? MojeyCollection()
        super.init(frame: frame)
        if mojeyCollection.total > maxMojeyItems {
            addCompact()
        } else {
            addExpanded()
        }
        self.backgroundColor = UIColor(white: 0.2, alpha: 1)
        self.addSubview(statusView)
        statusView.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func addCompact() {
        for i in 0..<mojeyCollection.count {
            guard let mojey = mojeyCollection[i] else { continue }
            let mojeyView = MojeyView(frame: CGRect.zero, mojeyQuantity: mojey)
            mojeyViews.append(mojeyView)
            self.addSubview(mojeyView)
        }
    }

    private func addExpanded() {
        for i in 0..<mojeyCollection.count {
            guard let mojey = mojeyCollection[i] else { continue }
            for _ in 1...mojey.quantity {
                let mojeyView = MojeyView(frame: CGRect.zero, mojey: mojey.mojey, quantity: 1)
                mojeyViews.append(mojeyView)
                self.addSubview(mojeyView)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //print("LAYOUT WIDTH = \(self.sizeWidth)")
        //printSuperWidths(view: self)
        let h: CGFloat = 130
        let overlap = 80 * (310 / self.sizeWidth)
        let w: CGFloat = h - overlap

        let totalW = CGFloat(mojeyViews.count) * w + overlap
        let x = (self.sizeWidth - totalW) / 2
        let y = (self.sizeHeight - h) 

        for i in 0..<mojeyViews.count {
            let view = mojeyViews[i]
            view.frame = CGRect(x: x + w * CGFloat(i), y: y, width: h, height: h)
        }

        layoutStatus()
    }

    private func layoutStatus() {
        let statusD: CGFloat = 18
            let statusInset: CGFloat = 7
            let statusX = self.sizeWidth - statusInset - statusD
            let statusY = self.sizeHeight - statusInset - statusD
            statusView.frame = CGRect(x: statusX, y: statusY, width: statusD, height: statusD)
    }
    
    func refreshStatus() {
        switch status {
        case .success: statusView.image = UIImage(named: "Icon-MiniCheck")
        case .error: statusView.image = UIImage(named: "Icon-MiniAlert")
        default: statusView.image = nil
        }
        layoutStatus()
    }

    func printSuperWidths(view: UIView) {
        if let sv = view.superview {
            print("\(sv) \(sv.frame.width)")
            printSuperWidths(view: sv)
        }
    }

}
