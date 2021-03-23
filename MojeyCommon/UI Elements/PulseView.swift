//
//  PulseView.swift
//
//  Created by Todd Bowden on 4/2/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit

class PulseView: UIView {
    
    var duration:Double = 0.25
    var color = UIColor.black
    private var timer: Timer?
    private var startTime: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func pulse() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (t) in
            self.setNeedsDisplay()
        }
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    override func draw(_ rect: CGRect) {
        let halfWidth = rect.width/2
        let halfHeight = rect.height/2
        let quarterWidth = halfWidth/2
        let quarterHeight = halfHeight/2
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let startTime = startTime else { return }
        
        context.clear(rect)
        
        var p = CGFloat(-startTime.timeIntervalSinceNow / duration)
        if p > 1 {
            p = 1
        }
        let ip = 1 - p
        
        let fillColor = color.withAlphaComponent(ip * 0.7).cgColor
        context.setFillColor(fillColor)
        let rect = CGRect(x: quarterWidth*ip,y: quarterHeight*ip, width: halfWidth*p+halfWidth, height:halfHeight*p+halfHeight)

        context.fillEllipse(in: rect)
        if p == 1 {
            stop()
        }
    
    }
    
    
}
