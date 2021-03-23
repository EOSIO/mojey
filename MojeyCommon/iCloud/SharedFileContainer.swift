//
//  SharedFileContainer.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/27/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class SharedFileContainer {

    private let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.accessGroup)
    private let directoryUrl: URL?


    init(directory: String) {
        directoryUrl = appGroupUrl?.appendingPathComponent(directory)
        if let directoryUrl = directoryUrl {
            try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }
    }


    private func getUrl(file: String) throws -> URL {
        if let url = directoryUrl?.appendingPathComponent(file)  {
            return url
        } else {
            throw SCError(reason: "Cannot create url for \(file)")
        }
    }

    func write(file: String, data: Data) throws {
        let url = try getUrl(file: file)
        try data.write(to: url)
    }

    func read(file: String) throws -> Data {
        let url = try getUrl(file: file)
        return try Data(contentsOf: url)
    }


}

