//
//  StoreManager.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 10/31/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import StoreKit


protocol StoreManagerDelegate {
    func storeManager(storeManger: StoreManager, purchasing productIdentifier: String)
    //func storeManager(storeManger: StoreManager, purchased productIdentifier: String)
    func storeManager(storeManger: StoreManager, purchased transaction: SKPaymentTransaction)
    func storeManager(storeManger: StoreManager, purchaseFailed productIdentifier: String)
    //func storeManager(storeManger: StoreManager, purchaseRestored productIdentifier: String)
    func storeManager(storeManger: StoreManager, didUpdateProducts productIdentifiers: [String])
}

class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = StoreManager()
    
    private let userDefaults = UserDefaults.standard
    
    private var products = [String:SKProduct]()
    
    var delegate: StoreManagerDelegate?
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        //requestAllProducts()
    }
    

    func requestProducts(for identifiers: [String]) {
        print(identifiers)
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        request.start()
    }
    

    
    // general purchcase function
    // returns true if added to the queue, otherwise false
    func purchaseProductIdentifier(productIdentifier: String?) -> Bool {
        print("purchaseProductIdentifier \(productIdentifier)")
        guard let productIdentifier = productIdentifier else { return false }
        guard SKPaymentQueue.canMakePayments() else { return false }
        guard let product = products[productIdentifier] else { return false }
        
        // create an SKPayment add add to the payment queue
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        return true
    }
    
    
    func localizedPriceForProductID(productIdentifier: String?) -> String? {
        guard let productIdentifier = productIdentifier else { return nil }
        guard let product = products[productIdentifier] else { return nil }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = product.priceLocale
        if let price = currencyFormatter.string(from: product.price) {
            return price
        } else {
            return ""
        }
    }


    func receipt() -> Data? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: receiptUrl)
    }
    
    
    /// StoreKit delegate method called with SKProducts in response to a products request
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        print(response.products)
        //print("\(response.productIdentifiers)")
        print("invalid = \(response.invalidProductIdentifiers)")
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        for product in response.products {
            // add product to the products dictionary
            products[product.productIdentifier] = product
            print(product)
        }
        delegate?.storeManager(storeManger: self, didUpdateProducts: Array(products.keys))
    }
    
    
    /// This method is called when the payment state is updated
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("queue")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("purchasing")
                delegate?.storeManager(storeManger: self, purchasing: transaction.payment.productIdentifier)
                
            case .purchased:
                print("purchased")
                processPurchasedTransaction(transaction: transaction)
                
            case .deferred:
                print("deferred")
                ()
                
            case .failed:
                print("********FAILED")
                SKPaymentQueue.default().finishTransaction(transaction)
                delegate?.storeManager(storeManger: self, purchaseFailed: transaction.payment.productIdentifier)
                
            case .restored:
                continue

            default:
                continue
            }
            
        }
        
    }

    
    private func processPurchasedTransaction(transaction: SKPaymentTransaction) {
        print("processPurchasedTransaction \(transaction.transactionIdentifier ?? "")")
        if let r = receipt() {
            print("receipt bytes = \(r.count)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        if let r = receipt() {
            print("receipt bytes = \(r.count)")
            print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
            print(r.hex)
            print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")

        }
        //let validator = ReceiptValidator()
        //let receipt = try! validator.getReceipt()
        //try! validator.validate(receipt: receipt)
        //delegate?.storeManager(storeManger: self, purchased: transaction.payment.productIdentifier)
        delegate?.storeManager(storeManger: self, purchased: transaction)
    }

    
}

