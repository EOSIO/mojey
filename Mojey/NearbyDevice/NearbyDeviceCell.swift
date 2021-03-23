//
//  NearbyDeviceCell.swift
//  Keys
//
//  Created by Todd Bowden on 5/12/18.
//  Copyright © 2018 Todd. All rights reserved.
//

import Foundation
import UIKit

class NearbyDeviceCell: UICollectionViewCell {
    
    var nearbyDevice: NearbyDevice?
    var themeColor = UIColor.black
    
    private let iconView = UIImageView()
    private let typeLabel = UILabel()
    private let nameLabel = UILabel()
    private let keyLabel = UILabel()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(iconView)
        self.addSubview(typeLabel)
        self.addSubview(nameLabel)
        self.addSubview(keyLabel)
        iconView.contentMode = .scaleAspectFit
        backgroundView = UIView()
        backgroundView?.layer.cornerRadius = 4
        backgroundView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        backgroundView?.clipsToBounds = true
        //print(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nearbyDevice = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let nearbyDevice = nearbyDevice else { return }
        //print("Cell: \(nearbyDevice.key)")
        backgroundView?.frame = self.bounds
        
        let inset = round(self.frame.size.height * 0.1)
        let availableHeight = self.frame.size.height - inset*2
        iconView.frame = CGRect(x: inset, y: inset, width: round(availableHeight*0.75), height: availableHeight)
        iconView.image = nearbyDevice.icon
        let typeHeight = availableHeight * 0.20
        let nameHeight = availableHeight * 0.4
        let keyHeight = availableHeight * 0.4
        let labelX = iconView.frame.origin.x + iconView.frame.size.width + inset
        let labelWidth = self.frame.size.width - labelX - inset
        typeLabel.frame = CGRect(x: labelX, y: inset, width: labelWidth, height: typeHeight)
        nameLabel.frame = CGRect(x: labelX, y: inset+typeHeight, width: labelWidth, height: nameHeight)
        keyLabel.frame = CGRect(x: labelX, y: inset+typeHeight+nameHeight, width: labelWidth, height: keyHeight)
        
        typeLabel.textColor = themeColor
        typeLabel.text = nearbyDevice.type
        typeLabel.font = UIFont.systemFont(ofSize: typeHeight*0.8, weight: .regular)
        
        nameLabel.textColor = .black
        nameLabel.text = nearbyDevice.name
        nameLabel.font = UIFont.systemFont(ofSize: nameHeight*0.8, weight: .light)
        
        keyLabel.textColor = .lightGray
        //keyLabel.text = nearbyDevice.key
        keyLabel.font = UIFont.systemFont(ofSize: keyHeight*0.4, weight: .regular)
        keyLabel.numberOfLines = 2
        
    }
    
}
