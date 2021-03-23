//
//  CGSize+dimensions.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/24/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {

    var lesserDimension: CGFloat {
        return self.width < self.height ? self.width : self.height
    }

    var greaterDimension: CGFloat {
        return self.width > self.height ? self.width : self.height
    }
    
}
