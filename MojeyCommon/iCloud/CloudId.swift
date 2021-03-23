//
//  CloudId.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 8/27/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CloudKit


private struct UbiquityIdentityCloudId: Codable {

    var ubiquityIdentityTokenHash: Int
    var cloudId: String

    init(ubiquityIdentityTokenHash: Int, cloudId: String) {
        self.ubiquityIdentityTokenHash = ubiquityIdentityTokenHash
        self.cloudId = cloudId
    }
}

class CloudId {

    static let shared = CloudId()

    static func cloudId() throws -> String {
        if let cid = CloudId.shared.cloudId {
            return cid
        } else {
            throw SCError(reason: CloudId.shared.accountStatusError ?? "CloudId is not available")
        }
    }

    private var container = CKContainer.default()

    private(set) var cloudId: String?
    private(set) var accountStatus: CKAccountStatus?
    private(set) var accountStatusError: String?

    func cloudId(completion: @escaping (String?, Error?)->Void) {
        if let cloudId = cloudId {
            completion(cloudId, nil)
        } else {
            refreshCloudId(completion: completion)
        }
    }

    private let sharedFileContainer = SharedFileContainer(directory: "CloudId")

    private func getUbiquityIdentityCloudId() throws -> UbiquityIdentityCloudId {
        let data = try sharedFileContainer.read(file: "UbiquityIdentityCloudId")
        let decoder = JSONDecoder()
        return try decoder.decode(UbiquityIdentityCloudId.self, from: data)
    }

    private func save(ubiquityIdentityTokenHash: Int, cloudId: String) throws {
        let ubiquityIdentityCloudId = UbiquityIdentityCloudId(ubiquityIdentityTokenHash: ubiquityIdentityTokenHash, cloudId: cloudId)
        print("ubiquityIdentityCloudId = \(ubiquityIdentityCloudId)")
        let encoder = JSONEncoder()
        let data = try encoder.encode(ubiquityIdentityCloudId)
        print("archived data \(data)")
        try sharedFileContainer.write(file: "UbiquityIdentityCloudId", data: data)
    }


    private func refreshCloudId(completion: @escaping (String?, Error?)->Void) {
        print("begin refreshCloudId")
        container = CKContainer.default()
        container.fetchUserRecordID { (recordID, error) in
            guard let recordID = recordID else {
                print(error ?? "")
                return completion(nil, error)
            }
            let cloudId = recordID.recordName
            print("iCloudId = \(cloudId)")
            self.cloudId = cloudId
            if let ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken {
                print("ubiquityIdentityTokenHash = \(ubiquityIdentityToken.hash)")
                print("ubiquityIdentityToken = \(ubiquityIdentityToken)")
                try? self.save(ubiquityIdentityTokenHash: ubiquityIdentityToken.hash, cloudId: cloudId)
            }
            completion(cloudId, nil)
        }
    }


    func listenForCloudIdChanges() {
        NotificationCenter.default.addObserver(forName: Notification.Name.CKAccountChanged, object: nil, queue: nil) { (notification) in
            print(notification)
            self.cloudId = nil
            self.refreshCloudId(completion: { (cid, error) in

            })
        }
    }


    func tryReadingSavedCloudId() {
        // if the account status is available and the stored ubiquityIdentityToken == the current one, use the stored cloudId, otherwise refresh
        CKContainer.default().accountStatus { (accountStatus, error) in
            self.accountStatus = accountStatus
            self.accountStatusError = error?.localizedDescription

            guard accountStatus == .available else { return }

            if let ubiquityIdentityCloudId = try? self.getUbiquityIdentityCloudId(),
                let ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken,
                ubiquityIdentityCloudId.ubiquityIdentityTokenHash == ubiquityIdentityToken.hash {
                print("ubiquityIdentityToken verified. cloudId = \(ubiquityIdentityCloudId.cloudId)" )
                self.cloudId = ubiquityIdentityCloudId.cloudId
            } else {
                self.refreshCloudId(completion: { (cid, error) in

                })
            }
        }
    }


    private init() {
        tryReadingSavedCloudId()
    }










}
