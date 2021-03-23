//
//  CustomToken.swift
//  Mojey
//
//  Created by Todd Bowden on 10/8/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct CustomToken: Codable, Equatable {
    static func == (lhs: CustomToken, rhs: CustomToken) -> Bool {
        do {
            return try lhs.concat() == rhs.concat()
        } catch {
            return false
        }
    }

    var version: Int = 1
    var tokenKey = Data()
    var name = ""
    var issurerName = ""
    var issueDate = Date()
    var imageHash = Data()
    var symbol = ""
    var backgroundColor = ""
    var primaryColor = ""
    var description = ""
    var supply: UInt64 = 0

    var signature = Data() // signed by tokenKey

    struct Assertion: Codable {
        var attestedKey = Data()
        var attestedKeyClientHash = Data()
        var signature = Data()
        var counter = Data()
    }
    var assertion = Assertion()

    func concat() throws -> Data {
        return try
            "\(version)".toUtf8Data() +
            tokenKey +
            name.toUtf8Data() +
            issurerName.toUtf8Data() +
            "\(issueDate.timeIntervalSince1970)".toUtf8Data() +
            imageHash +
            symbol.toUtf8Data() +
            backgroundColor.toUtf8Data() +
            primaryColor.toUtf8Data() +
            description.toUtf8Data() +
            "\(supply)".toUtf8Data()
    }

    init() { }
    
    init(tokenKey: Data) {
        self.tokenKey = tokenKey
    }

}
