//
//  Dictionary+QueryItems.swift
//
//  Created by Todd Bowden on 8/7/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Dictionary {
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        
        for (key,value) in self {
            if let k = key as? String, let v = value as? String {
                let item = URLQueryItem(name: k, value: v)
                items.append(item)
            }
        }
        return items
    }
    
    var toURL: URL? {
        var components = URLComponents()
        components.queryItems = self.queryItems
        return components.url
    }
    
}
