//
//  AmountStepperView.swift
//
//  Created by Todd Bowden on 9/1/18.
//  Copyright © 2018 Todd Bowden. All rights reserved.
//

import Foundation
import UIKit

protocol AmountStepperDelegate: class {
    func amountStepper(_ stepper: AmountStepper, didUpdateAmount amount: Decimal)
    func amountStepperDidTapAmount(_ stepper: AmountStepper)
    func amountStepperDidTapToken(_ stepper: AmountStepper)
}

class AmountStepper: UIView {
    
    weak var delegate: AmountStepperDelegate?

    var color = UIColor.gray
    
    private var backgroundView = UIView()
    private var amountLabel = UILabel()
    private var tokenLabel = UILabel()
    
    private var minusButton = CircleButton()
    private var plusButton = CircleButton()
    
    var maxAmount: Decimal = Decimal.greatestFiniteMagnitude
    var maxDigits = 5
    private(set) var amount: Decimal = 0
    private(set) var amountText = ""
    private(set) var amountNumDigits = 0
    var token = ""
    //var amountHorizontalSpan: CGFloat = 0.55
 
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundView)
        addSubview(amountLabel)
        addSubview(tokenLabel)
        addSubview(minusButton)
        addSubview(plusButton)
        amountLabel.textAlignment = .right
        minusButton.text = "－"
        plusButton.text = "＋"
        plusButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
        amountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAmount)))
        tokenLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToken)))
        amountLabel.isUserInteractionEnabled = true
        tokenLabel.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshLayout()
    }
    
    func refreshLayout() {
   
        let backgroundWidth = self.sizeWidth * 0.88
        let backgroundX = (self.sizeWidth - backgroundWidth) / 2
        backgroundView.frame = CGRect(x: backgroundX, y: 0, width: backgroundWidth, height: self.sizeHeight)
        backgroundView.layer.cornerRadius = self.frame.size.height * 0.4
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.05
        backgroundView.clipsToBounds = true
    
        var amountFontSize = self.sizeHeight * 0.618
        if amountNumDigits > 3 {
            amountFontSize = amountFontSize - CGFloat((amountNumDigits - 3)) * (self.sizeHeight * 0.06)
        }
        let amountFont = UIFont.monospacedDigitSystemFont(ofSize: amountFontSize, weight: .regular)
        let amountSize = amountText.boundingSize(font: amountFont, constrainedToSize: self.frame.size)
        print("\(amountNumDigits): fontsize:\(amountFontSize) width:\(amountSize.width)")
        //let amountWidth = self.sizeWidth * amountHorizontalSpan
        amountLabel.font = amountFont
        
        let space: CGFloat = 0
        
        var tokenFontSize = self.sizeHeight * 0.45
        let tokenNumChars = token.count
        if tokenNumChars > 4 {
            tokenFontSize = tokenFontSize - CGFloat((tokenNumChars - 4)) * (self.sizeHeight * 0.05)
        }
        let tokenFont = UIFont.systemFont(ofSize: tokenFontSize, weight: .thin)
        let tokenSize = token.boundingSize(font: tokenFont, constrainedToSize: self.frame.size)
        print("\(token) token width = \(tokenSize.width)")
        tokenLabel.font = tokenFont
        tokenLabel.text = token
        tokenLabel.alpha = 0.8
        
        let totalTextWidth = amountSize.width + space + tokenSize.width
        let sideSpace = (self.frame.size.width - totalTextWidth) / 2
        amountLabel.frame = CGRect(x: 0, y: 0, width: sideSpace + amountSize.width, height: self.sizeHeight)
        tokenLabel.frame = CGRect(x: amountLabel.rightX + space, y: 0, width: tokenSize.width + sideSpace, height: self.sizeHeight)
        //amountLabel.backgroundColor = .yellow
        //tokenLabel.backgroundColor = .brown
        
        let buttonDiameter = self.sizeHeight * 0.618
        let buttonY = (self.sizeHeight - buttonDiameter) / 2
        minusButton.color = color
        plusButton.color = color
        minusButton.textColor = .white
        plusButton.textColor = .white
        minusButton.frame = CGRect(x: 0, y: buttonY, width: buttonDiameter, height: buttonDiameter)
        plusButton.frame = CGRect(x: self.sizeWidth-buttonDiameter, y: buttonY, width: buttonDiameter, height: buttonDiameter)
        
    
    }
    
    func setAmount(_ newAmount: Decimal) {
        var newAmount = newAmount
        guard amount != newAmount else { return }
        guard newAmount <= maxAmount else { return }
        if newAmount < 0 {
            newAmount = 0
        }
        let newAmountText = "\(newAmount)"
        let newNumDigits = newAmountText.replacingOccurrences(of: ".", with: "").count
        guard newNumDigits <= maxDigits else { return }
        
        amount = newAmount
        amountText = newAmountText
        amountLabel.text = newAmountText
        let oldNumDigits = amountNumDigits
        amountNumDigits = newNumDigits
        
        if oldNumDigits != newNumDigits {
            refreshLayout()
        }
        delegate?.amountStepper(self, didUpdateAmount: amount)
    }
    
    @objc func didTapAmount() {
        delegate?.amountStepperDidTapAmount(self)
        print("TAP AMOUNT")
    }
    
    @objc func didTapToken() {
        delegate?.amountStepperDidTapToken(self)
        print("TAP TOKEN")
    }
    
    
    
    @objc func didTapAdd() {
        let addAmount: Decimal = 1
        setAmount(amount + addAmount)
    }
    
    @objc func didTapMinus() {
        setAmount(amount - 1)
    }
}





