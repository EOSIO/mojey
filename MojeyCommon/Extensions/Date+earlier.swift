//
//  Date+earlier.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 9/1/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

extension Date {

    static func earlier(date1: Date, date2: Date) -> Date {
        if date1 < date2 {
            return date1
        } else {
            return date2
        }
    }
}
