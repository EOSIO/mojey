//
//  SCError.swift
//
//  Created by Todd Bowden on 7/22/19.
//  Copyright © 2020. All rights reserved.
//


import Foundation

open class SCError: Error, CustomStringConvertible, Codable {

    /// The reason for the error as a human-readable string.
    public var reason: String
    /// The original error.
    public var originalError: NSError?

    enum CodingKeys: String, CodingKey {
        case reason
    }



    /// Descriptions for the various `EosioErrorCode` members.
    public var description: String {
        return reason
    }

    public init (reason: String, originalError: NSError? = nil) {
        self.reason = reason
        self.originalError = originalError
    }
}


public extension Error {

    /// Returns an `EosioError` unexpected error for the given Error.
    var scError: SCError {

        if let scError = self as? SCError {
            return scError
        }

        return SCError(reason: self.localizedDescription)
    }

}

