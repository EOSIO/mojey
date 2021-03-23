//
//  URL+Dictionary.swift
//
//  Created by Todd Bowden on 8/7/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension URL {
    
    var dictionaryFromQueryItems: [String:String]? {
        var dict = [String:String]()
        guard let urlComponents = NSURLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        for queryItem in queryItems {
            dict[queryItem.name] = queryItem.value
        }
        return dict
    }

}
