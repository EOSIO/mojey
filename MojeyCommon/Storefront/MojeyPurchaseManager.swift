//
//  MojeyPurchaseManager.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/26/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import StoreKit

class MojeyPurchaseManager {

    static let `default` = MojeyPurchaseManager()


    func processPurchase(transaction: SKPaymentTransaction) throws {
        // validate transaction
        let productIdentifier = transaction.payment.productIdentifier

        // get pack from pack provider
        guard let pack = MojeyPackProvider.default.pack(productIdentifier: productIdentifier) else {
            throw SCError(reason: "Unknown pack \(productIdentifier)")
        }

        // validate pack
        let validator = ReceiptValidator()
        let receipt = try validator.getReceipt()
        guard try validator.validate(receipt: receipt, transaction: transaction) == receipt.sha256 else {
            throw SCError(reason: "purchase validation fail")
        }

        print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
        print("PASS VALIDATION \(productIdentifier)")


        // increment mojey store
        let mojeyc = try pack.mojeyCollection()
        let mojeys = try mojeyc.string()
        try MojeyStore.default.increment(mojey: mojeys)
    }


}
