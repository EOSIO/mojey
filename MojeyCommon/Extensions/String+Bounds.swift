//
//  String+Bounds.swift
//  Converse
//
//  Created by Todd Bowden on 1/8/17.
//  Copyright © 2017 Todd Bowden. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func boundingSize(font: UIFont, constrainedToSize size: CGSize, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGSize {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = lineBreakMode
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: style]
        let frame = self.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: attributes, context: nil)
        return CGSize(width: ceil(frame.size.width), height: ceil(frame.size.height))
    }
    
    
    
}
