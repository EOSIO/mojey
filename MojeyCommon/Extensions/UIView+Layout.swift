//
//  UIView+Layout.swift
//
//  Created by Todd Bowden on 3/30/17.
//  Copyright © 2017 Todd Bowden. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var originX: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame = CGRect(x:newValue, y:self.frame.origin.y, width:self.frame.size.width, height:self.frame.size.height)
        }
    }
    
    var originY: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame = CGRect(x:self.frame.origin.x, y:newValue, width:self.frame.size.width, height:self.frame.size.height)
        }
    }
    
    var sizeWidth: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame = CGRect(x:self.frame.origin.x, y:self.frame.origin.y, width:newValue, height:self.frame.size.height)
        }
    }
    
    var sizeHalfWidth: CGFloat {
        get {
            return self.frame.size.width / 2
        }
    }
    
    var sizeHeight: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame = CGRect(x:self.frame.origin.x, y:self.frame.origin.y, width:self.frame.size.width, height:newValue)
        }
    }
    
    var sizeHalfHeight: CGFloat {
        get {
            return self.frame.size.height / 2
        }
    }
    
    var rightX: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    var bottomY: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    
    enum LayoutAlignment {
        case topLeft
        case top
        case topRight
        case left
        case center
        case right
        case bottomLeft
        case bottom
        case bottomRight
        
        case topSpan
        case leftSpan
        case rightSpan
        case bottomSpan
        case horizontalSpan
        case verticalSpan
        case fullSpan
    }
    
    
    func layout(inRect rect: CGRect, size: CGSize?, alignment: LayoutAlignment, offset: CGPoint) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        var newSize = size ?? self.frame.size
        if alignment == .topSpan || alignment == .bottomSpan || alignment == .horizontalSpan || alignment == .fullSpan {
            newSize = CGSize(width: rect.width, height: newSize.height)
        }
        if alignment == .leftSpan || alignment ==  .rightSpan || alignment == .verticalSpan || alignment == .fullSpan {
            newSize = CGSize(width: newSize.width, height: rect.height)
        }
        
        switch alignment {
        case .topLeft:
            x = 0
            y = 0
            
        case .top, .topSpan:
            x = (rect.size.width - newSize.width)/2
            y = 0
            
        case .topRight:
            x = rect.size.width - newSize.width
            y = 0
            
        case .left, .leftSpan:
            x = 0
            y = (rect.size.height - newSize.height)/2
            
        case .center, .horizontalSpan, .verticalSpan, .fullSpan:
            x = (rect.size.width - newSize.width)/2
            y = (rect.size.height - newSize.height)/2
            
        case .right, .rightSpan:
            x = rect.size.width - newSize.width
            y = (rect.size.height - newSize.height)/2
            
        case .bottomLeft:
            x = 0
            y = rect.size.height - newSize.height
            
        case .bottom, .bottomSpan:
            x = (rect.size.width - newSize.width)/2
            y = rect.size.height - newSize.height
            
        case .bottomRight:
            x = rect.size.width - newSize.width
            y = rect.size.height - newSize.height
            
        }
        
        x = x + rect.origin.x + offset.x
        y = y + rect.origin.y + offset.y
        
        self.frame = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
    }
    

    func layout(size: CGSize? = nil, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        guard let superview = self.superview else { return }
        layout(inRect: superview.bounds, size: size, alignment: alignment, offset: offset)
    }
    
    
    
    /// Layout Between
    
    func layoutBetween(leftView: UIView?, rightView: UIView?, size: CGSize?, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        guard let superview = self.superview else { return }
        
        let x = leftView?.rightX ?? 0
        let w = (rightView?.originX ?? superview.sizeWidth) - x
        let y = lowest(value1: leftView?.originY, value2: rightView?.originY, valueDefault: 0)
        let h = highest(value1:leftView?.bottomY, value2: rightView?.bottomY, valueDefault: superview.sizeHeight) - y
        
        guard w > 0 else { return }
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        layout(inRect: rect, size: size ?? self.frame.size, alignment: alignment, offset: offset)
    }
    
    func layoutBetween(topView: UIView?, bottomView: UIView?, size: CGSize?, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        guard let superview = self.superview else { return }
        
        let x = lowest(value1: topView?.originX, value2: bottomView?.originX, valueDefault: 0)
        let w = highest(value1: topView?.rightX, value2: bottomView?.rightX, valueDefault: superview.sizeWidth) - x
        let y = topView?.bottomY ?? 0
        let h = (bottomView?.originY ?? superview.sizeHeight) - y
        
        guard h > 0 else { return }
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        layout(inRect: rect, size: size ?? self.frame.size, alignment: alignment, offset: offset)
    }
    
    
    
    /// Layout Above, Below
    
    
    func layoutAbove(view: UIView?, size: CGSize? = nil, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        layoutBetween(topView: nil, bottomView: view, size: size, alignment: alignment, offset: offset)
    }
    
    func layoutAbove(view: UIView?, size: CGSize? = nil, alignment: LayoutAlignment, pointsAbove: CGFloat) {
        let offset = CGPoint(x: 0, y: -pointsAbove)
        layoutBetween(topView: nil, bottomView: view, size: size, alignment: alignment, offset: offset)
    }
    
    func layoutBelow(view: UIView?, size: CGSize? = nil, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        layoutBetween(topView: view, bottomView: nil, size: size, alignment: alignment, offset: offset)
    }
    
    func layoutBelow(view: UIView?, size: CGSize? = nil, pointsBelow: CGFloat) {
        let offset = CGPoint(x: 0, y: pointsBelow)
        layoutBetween(topView: view, bottomView: nil, size: size, alignment: .top, offset: offset)
    }

    
    /// Edges
    
    func layoutTopEdge(size: CGSize? = nil, pointsBelow: CGFloat = 0) {
        layoutBelow(view: nil, pointsBelow: pointsBelow)
    }
    
    func layoutBottomEdge(size: CGSize? = nil, pointsAbove: CGFloat = 0) {
        layoutAbove(view: nil, alignment: .bottom, pointsAbove: pointsAbove)
    }
    
    func layoutTopEdgeSpan(size: CGSize? = nil, pointsBelow: CGFloat = 0) {
        layoutBelow(view: nil, size: size, alignment: .topSpan, offset: CGPoint(x: 0, y: pointsBelow))
    }
    
    
    /// Layout Left, Right
    
    func layoutLeft(view: UIView, size: CGSize? = nil, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        layoutBetween(leftView: nil, rightView: view, size: size, alignment: alignment, offset: offset)
    }
    
    func layoutLeft(view: UIView, size: CGSize? = nil, pointsLeft: CGFloat) {
        let offset = CGPoint(x: -pointsLeft, y: 0)
        layoutBetween(leftView: nil, rightView: view, size: size, alignment: .right, offset: offset)
    }
    
    func layoutRight(view: UIView, size: CGSize? = nil, alignment: LayoutAlignment, offset: CGPoint = CGPoint.zero) {
        layoutBetween(leftView: view, rightView: nil, size: size, alignment: alignment, offset: offset)
    }
    
    func layoutRight(view: UIView, size: CGSize? = nil, pointsRight: CGFloat) {
        let offset = CGPoint(x: pointsRight, y: 0)
        layoutBetween(leftView: view, rightView: nil, size: size, alignment: .left, offset: offset)
    }
    

    
    /// lowest, highest
    
    private func lowest(value1: CGFloat?, value2: CGFloat?, valueDefault: CGFloat) -> CGFloat {
        if value1 == nil && value2 == nil {
            return valueDefault
        }
        return min(value1 ?? CGFloat.greatestFiniteMagnitude, value2 ?? CGFloat.greatestFiniteMagnitude)
    }
    
    private func highest(value1: CGFloat?, value2: CGFloat?, valueDefault: CGFloat) -> CGFloat {
        if value1 == nil && value2 == nil {
            return valueDefault
        }
        return max(value1 ?? -CGFloat.greatestFiniteMagnitude, value2 ?? -CGFloat.greatestFiniteMagnitude)
    }
    
}












