//
//  CircleButton.swift
//
//  Created by Todd Bowden on 4/1/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit

class CircleButton: UIButton {
    
    let circleView = UIView()
    let pulseView = PulseView()
    private let label1 = UILabel()
    private let imageView1 = UIImageView()
    private let label2 = UILabel()
    private let imageView2 = UIImageView()
    private var isAnimating = false

    override var isEnabled: Bool {
        didSet {
            alpha = self.isEnabled ? 1 : 0.3
        }
    }
    
    var color = UIColor.black
    var text = ""
    var textColor = UIColor.white
    var fontSize: CGFloat = 32
    var fontWeight = UIFont.Weight.light

    var tap: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pulseView)
        addSubview(circleView)
        circleView.isUserInteractionEnabled = false
        pulseView.isUserInteractionEnabled = false
        circleView.addSubview(label1)
        circleView.addSubview(imageView1)
        circleView.addSubview(label2)
        circleView.clipsToBounds = true
        label2.isHidden = true
        
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchCancel), for: .touchCancel)
        addTarget(self, action: #selector(touchCancel), for: .touchDragExit)
        addTarget(self, action: #selector(touchCancel), for: .touchUpOutside)
        self.isUserInteractionEnabled = true
        
        self.sendActions(for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isAnimating { return }
        fontSize = self.sizeHeight * 0.85
        circleView.frame = self.bounds
        circleView.layer.cornerRadius = circleView.frame.size.width/2
        circleView.backgroundColor = color
        
        label1.frame = self.bounds
        label1.textAlignment = .center
        label1.text = text
        label1.textColor = textColor
        label1.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }
    
    @objc func touchDown() {
        circleView.alpha = 0.8
    }
    
    @objc func touchCancel() {
        circleView.alpha = 1
    }
    
    @objc func touchUpInside() {
        circleView.alpha = 1
        pulse()
        tap?()
    }
    
    func pulse() {
        let d = self.frame.size.width/2
        pulseView.frame = CGRect(x: -d, y: -d, width: d*4, height: d*4)
        pulseView.color = color
        pulseView.pulse()
    }
    
    func spin() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(Double.pi * 2)
        rotateAnimation.duration = 0.3
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    func push(completion: (()->Void)? = nil) {
        label2.frame = CGRect(x: label1.originX, y: label1.bottomY * 1.5, width: label1.sizeWidth, height: label1.sizeHeight)
        label2.text = label1.text
        label2.font = label1.font
        label2.textAlignment = label1.textAlignment
        label2.textColor = label1.textColor
        label2.isHidden = false
        
        isAnimating = true
        UIView.animate(withDuration: 0.3, animations: {
            self.label1.originY = -self.sizeHeight
            self.label2.originY = 0
        }) { (finished) in
            self.label1.originY = 0
            self.label2.isHidden = true
            self.isAnimating = false
            self.setNeedsLayout()
            if let completion = completion { completion() }
        }
    }
    
    
    
}
