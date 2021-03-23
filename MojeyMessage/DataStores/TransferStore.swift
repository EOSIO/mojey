//
//  TransferStore.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/3/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation

struct TransferStatus: Codable {
    var success: Bool = false
    var error: String?

}


class TransferStore {

    static let `default` = TransferStore()

    private let keychainStore = KeychainStore.default
    private let service = "TransferStore"


    func getTransferStatus(id: String) throws -> TransferStatus {
        return try keychainStore.get(name: id, service: service)
    }

    func setSuccess(id: String) throws {
        var transferStatus = TransferStatus()
        transferStatus.success = true
        try save(transferStatus: transferStatus, id: id)
    }

    func setError(_ error: String, id: String) throws {
        var transferStatus = TransferStatus()
        transferStatus.success = false
        transferStatus.error = error
        try save(transferStatus: transferStatus, id: id)
    }

    private func save(transferStatus: TransferStatus, id: String) throws {
        try keychainStore.save(name: id, object: transferStatus, service: service)
    }



}
