//
//  FileStore.swift
//  Mojey
//
//  Created by Todd Bowden on 8/26/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

class FileStore {

    enum Location {
        case appGroup
        case documents
    }



    private let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.accessGroup)
    private let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private let directoryUrl: URL?


    init(_ location: Location, directory: String) {
        if location == .appGroup {
            directoryUrl = appGroupUrl?.appendingPathComponent(directory)
        }  else {
            directoryUrl = documentsUrl?.appendingPathComponent(directory)
        }

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


