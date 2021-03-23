//
//  MojeyTransferStagingView.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/11/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

protocol MojeyTransferStagingViewDelegate: class {
    func mojeyTransferStagingView(view: MojeyTransferStagingView, didSelect mojeyQuantity: MojeyQuantity, index: Int)
    func mojeyTransferStagingViewDidTapSend(view: MojeyTransferStagingView)
}

class MojeyTransferStagingView: UIView {

    weak var delegate: MojeyTransferStagingViewDelegate?

    private class MojeyLayout {
        var mojeyView: MojeyView
        var quantity: UInt64 = 1
        var startingIndex: Int = 0
        var endIndex: Int = 0
        var isNew: Bool = false
        var shouldRemoveBefore: Bool = false
        var shouldRemoveAfter: Bool = false
        var startingFrame: CGRect?
        var endingFrame: CGRect?

        var mojey: String {
            return mojeyView.mojey
        }

        init(mojeyView: MojeyView) {
            self.mojeyView = mojeyView
        }
    }

    var maxMojeyItems = 5
    private(set) var isAnimating = false

    private let backgroundView = UIView()
    private var sendButton = CircleButton()


    let margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

    private var mojeyLayouts = [MojeyLayout]()

    private var isCollapsed: Bool {
        //if mojeyLayouts.count >= maxMojeyItems { return true }
        for mojeyLayout in mojeyLayouts {
            if mojeyLayout.quantity > 1 {
                return true
            }
        }
        return false
    }

    private var isExpanded: Bool {
        return !isCollapsed
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backgroundView)
        self.addSubview(sendButton)
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        sendButton.color = UIColor.white
        sendButton.textColor = UIColor.black
        sendButton.text = "↑"
        sendButton.fontWeight = UIFont.Weight.regular
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func clear() {
        for layout in mojeyLayouts {
            layout.mojeyView.removeFromSuperview()
        }
        mojeyLayouts.removeAll()
        refreshSendButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.size.width - margin.left - margin.right
        let h = self.frame.size.height - margin.top - margin.bottom
        backgroundView.frame = CGRect(x: margin.left, y: margin.top, width: w, height: h)
        backgroundView.layer.cornerRadius = h * 0.4

        let sendD = self.frame.size.height * 0.4
        let sendY = (self.frame.size.height - sendD) / 2
        let sendX = self.frame.size.width - sendD - 16
        sendButton.frame = CGRect(x: sendX, y: sendY, width: sendD, height: sendD)
    }


    @objc func didTapSend() {
        sendButton.push {
            self.refreshSendButton()
        }
        delegate?.mojeyTransferStagingViewDidTapSend(view: self)
    }

    private func refreshSendButton() {
          sendButton.isEnabled = mojeyLayouts.count > 0
    }

    // add a mojey, return the index where the new mojey will appear
    func add(mojeyQuantity: MojeyQuantity, startingFrame: CGRect, animationDuration: TimeInterval) -> Int? {
        guard !isAnimating else { return nil }
        isAnimating = true
        if needsCollapseLayout(newMojeyQuantity: mojeyQuantity) {
            collapseLayout()
            print("collapse")
            printLayouts()
        }
        sendButton.isEnabled = true

        if isCollapsed || mojeyLayouts.count >= maxMojeyItems {
            print("isCollapsed")
            // mojey already exists and the layout is collapsed to just increment the quantity
            if let index = lastIndex(mojey: mojeyQuantity.mojey) {
                //mojeyLayouts[index].quantity += mojeyQuantity.quantity
                let endIndex = firstEndIndex(mojey: mojeyQuantity.mojey) ?? index
                mojeyLayouts[endIndex].quantity += mojeyQuantity.quantity
                insertLayout(mojeyQuantity: mojeyQuantity, index: endIndex, startingFrame: startingFrame, increment: false, removeAfter: true)
                renderLayout(duration: animationDuration)
                return index
            // mojey does not exist so add to the end
            } else {
                let index = maxEndIndex() + 1
                insertLayout(mojeyQuantity: mojeyQuantity, index: index, startingFrame: startingFrame)
                renderLayout(duration: animationDuration)
                return index
            }

        } else {

            // layout does not need to be collapsed, insert at the end of existing same mojey or the end if mojey is new
            let index = (lastIndex(mojey: mojeyQuantity.mojey) ?? mojeyLayouts.count-1) + 1
            print("insert at \(index)")
            insertLayout(mojeyQuantity: mojeyQuantity, index: index, startingFrame: startingFrame)
            renderLayout(duration: animationDuration)
            return index
        }

    }

    func remove(mojeyIndex: Int, mojeyQuantity: MojeyQuantity, endingFrame: CGRect, animationDuration: TimeInterval) -> Bool {
        guard !isAnimating else { return false }
        guard mojeyIndex < mojeyLayouts.count else { return false }
        isAnimating = true
        let layout = mojeyLayouts[mojeyIndex]
        guard layout.mojey == mojeyQuantity.mojey else { return false }
        layout.endingFrame = endingFrame

        if layout.quantity > mojeyQuantity.quantity {
            layout.quantity -= mojeyQuantity.quantity
        } else {
            layout.quantity = 0
            layout.shouldRemoveBefore = true
        }

        if canExpandLayout() {
            expandLayout()
        }
        renderLayout(duration: animationDuration)
        return true
    }


    private func needsCollapseLayout(newMojeyQuantity: MojeyQuantity) -> Bool {
        if isCollapsed { return false }
        if newMojeyQuantity.quantity > 1 { return true }
        if mojeyLayouts.count < maxMojeyItems { return false }
        return true
    }

    private func canExpandLayout() -> Bool {
        if isExpanded { return false }
        return totalMojeyQuantity() <= maxMojeyItems
    }


    private func insertLayout(mojeyQuantity: MojeyQuantity, index: Int, startingFrame: CGRect, increment: Bool = true, removeAfter: Bool = false) {
        let mojeyView = MojeyView(frame: CGRect.zero, mojeyQuantity: mojeyQuantity)
        let layout = MojeyLayout(mojeyView: mojeyView)
        if increment {
            incrementLayoutIndexesAt(index: index)
        }
        layout.startingIndex = index
        layout.endIndex = index
        layout.isNew = true
        layout.startingFrame = startingFrame
        layout.shouldRemoveAfter = removeAfter
        mojeyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMojeyView)))
        mojeyLayouts.insert(layout, at: index)
    }


    @objc func didTapMojeyView(sender: UITapGestureRecognizer) {
        guard let mojeyView = sender.view else {return }
        guard let index = indexFor(mojeyView: mojeyView) else { return }
        let _ = remove(mojeyIndex: index, mojeyQuantity: MojeyQuantity(), endingFrame: CGRect.zero, animationDuration: 2)
    }


    private func indexFor(mojeyView: UIView) -> Int? {
        print(mojeyLayouts.count)
        for i in 0..<mojeyLayouts.count {
            print(mojeyLayouts[i].mojeyView)
            if mojeyLayouts[i].mojeyView == mojeyView {
                return i
            }
        }
        return nil
    }

    private func incrementLayoutIndexesAt(index: Int) {
        for i in 0..<mojeyLayouts.count {
            let layout = mojeyLayouts[i]
            if layout.endIndex >= index {
                layout.endIndex += 1
            }
            if layout.startingIndex >= index {
                layout.startingIndex += 1
            }
        }
    }

    private func collapseLayout() {
        var i = 0
        var e = 0
        while i < mojeyLayouts.count {
            let layout = mojeyLayouts[i]
            layout.endIndex = e
            let s = countSameMojey(index: i)
            print("same Mojey = \(s)")
            for n in i..<i+s {
                if n == i {
                    layout.quantity = UInt64(s)
                }
                if n > i {
                    mojeyLayouts[n].shouldRemoveAfter = true
                }
                mojeyLayouts[n].endIndex = e
            }
            i += s
            e += 1
        }
    }


    private func expandLayout() {
        var newLayouts = [MojeyLayout]()
        var e = 0
        for i in 0..<mojeyLayouts.count {
            let layout = mojeyLayouts[i]
            if layout.shouldRemoveBefore { continue }
            for n in 0..<layout.quantity {
                let mojeyView = (n == 0) ? layout.mojeyView : MojeyView(frame: CGRect.zero, mojey: layout.mojey)
                let newLayout = MojeyLayout(mojeyView: mojeyView)
                newLayout.quantity = 1
                newLayout.startingIndex = i
                newLayout.endIndex = e
                newLayouts.append(newLayout)
                e += 1
            }
        }
        mojeyLayouts = newLayouts
    }


    private func renderLayout(duration: TimeInterval) {
        printLayouts()
        for i in 0..<mojeyLayouts.count {
            let layout = mojeyLayouts[i]
            // add new mojey to the view
            if layout.isNew {
                layout.mojeyView.frame = layout.startingFrame ?? layoutFrameFor(index: layout.startingIndex)
                self.insertSubview(layout.mojeyView, belowSubview: sendButton)
            }
            if layout.shouldRemoveBefore {
                layout.mojeyView.removeFromSuperview()
            }
            layout.mojeyView.set(quantity: layout.quantity, animate: true)
        }

        // animate
        UIView.animate(withDuration: duration+0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
            for i in 0..<self.mojeyLayouts.count {
                let layout = self.mojeyLayouts[i]
                layout.mojeyView.frame = self.layoutFrameFor(index: layout.endIndex)
            }
        }) { (finished) in
            for layout in self.mojeyLayouts {
                // set new mojey views to visible
                layout.mojeyView.isHidden = false
                layout.startingIndex = layout.endIndex
                layout.isNew = false
                if layout.shouldRemoveAfter {
                    layout.mojeyView.removeFromSuperview()
                }
            }
            // remove views from layout
            self.mojeyLayouts = self.mojeyLayouts.filter({ (layout) -> Bool in
                !layout.shouldRemoveBefore && !layout.shouldRemoveAfter
            })
            self.isAnimating = false
            self.refreshSendButton()
        }



//        UIView.animate(withDuration: duration, animations: {
//            for i in 0..<self.mojeyLayouts.count {
//                let layout = self.mojeyLayouts[i]
//                layout.mojeyView.frame = self.layoutFrameFor(index: layout.endIndex)
//            }
//        }) { (finished) in
//            for layout in self.mojeyLayouts {
//                // set new mojey views to visible
//                layout.mojeyView.isHidden = false
//                layout.startingIndex = layout.endIndex
//                layout.isNew = false
//                if layout.shouldRemoveAfter {
//                    layout.mojeyView.removeFromSuperview()
//                }
//            }
//            // remove views from layout
//            self.mojeyLayouts = self.mojeyLayouts.filter({ (layout) -> Bool in
//                !layout.shouldRemoveBefore && !layout.shouldRemoveAfter
//            })
//            self.isAnimating = false
//        }

    }


    private func layoutFrameFor(index: Int) -> CGRect {
        let aw = self.frame.size.width - 60
        let w = self.frame.size.height * 0.6
        var c = mojeyLayouts.count
        if c > maxMojeyItems { c = maxMojeyItems }
        let s = (aw - CGFloat(c) * w) / 2
        let x = 10 + s + w * CGFloat(index)
        return CGRect(x: x, y: 5, width: w, height: self.frame.size.height * 0.95)
    }


    private func countSameMojey(index: Int) -> Int {
        var n = 1
        let mojey = mojeyLayouts[index].mojey
        while index + n < mojeyLayouts.count && mojeyLayouts[index + n].mojey == mojey {
            n += 1
        }
        return n
    }

    private func totalMojeyQuantity() -> UInt64 {
        var total: UInt64 = 0
        for layout in mojeyLayouts {
            total += layout.quantity
        }
        return total
    }

    private func lastIndex(mojey: String) -> Int? {
        var index: Int? = nil
        for i in 0..<mojeyLayouts.count {
            if mojeyLayouts[i].mojey == mojey {
                index = i
            }
        }
        return index
    }

    private func firstEndIndex(mojey: String) -> Int? {
        for layout in mojeyLayouts {
            if layout.mojey == mojey {
                return layout.endIndex
            }
        }
        return nil
    }

    private func maxEndIndex() -> Int {
        var index: Int = 0
        for i in 0..<mojeyLayouts.count {
            if mojeyLayouts[i].endIndex > index {
                index = mojeyLayouts[i].endIndex
            }
        }
        return index
    }

    private func indexs(mojey: String) -> [Int] {
        var indexes = [Int]()
        for i in 0..<mojeyLayouts.count {
            let view = mojeyLayouts[i].mojeyView
            if view.mojey == mojey {
                indexes.append(i)
            }
        }
        return indexes
    }


    private func printLayouts() {
        print("===================================================================")
        for layout in mojeyLayouts {
            print("s:\(layout.startingIndex) e:\(layout.endIndex)")

        }
        print("===================================================================")
    }

}
