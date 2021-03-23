//
//  CGSize.swift
//  Converse
//
//  Created by Todd Bowden on 1/8/17.
//  Copyright © 2017 Todd Bowden. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    
    func centeredFrame(parentSize: CGSize) -> CGRect {
        let x = round((parentSize.width - self.width) / 2)
        let y = round((parentSize.height - self.height) / 2)
        return CGRect(x: x, y: y, width: self.width, height: self.height)
    }
}
