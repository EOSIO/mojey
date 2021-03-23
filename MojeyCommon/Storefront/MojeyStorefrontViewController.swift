//
//  MojeyStorefrontViewController.swift
//  MojeyMessage
//
//  Created by Todd Bowden on 11/1/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import StoreKit


class MojeyStorefrontPurchasingSelection: ObservableObject {
    @Published var productIdentifier: String? = nil
}

protocol MojeyStorefrontViewControllerDelegate: class {
    func mojeyStorefrontViewControllerDidFinish()
}

class MojeyStorefrontViewController: UIViewController, StoreManagerDelegate {



    weak var delegate: MojeyStorefrontViewControllerDelegate?

    private let storeManager = StoreManager.shared
    private var purchasingSelection = MojeyStorefrontPurchasingSelection()
    private var hostingController = UIViewController()



    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addChild(hostingController)
        //self.view.addSubview(hostingController.view)
        storeManager.delegate = self
        storeManager.requestProducts(for: MojeyPackProvider.default.allCurrentProductIdentifiers)

        //let packs = MojeyPackProvider.default.allCurrentPacks
        //showStorefrontView(packs: packs)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hostingController.view.frame = self.view.bounds
    }


    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func showStorefrontView(packs: [MojeyPack]) {

        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
        for child in self.children {
            child.removeFromParent()
        }

        let subscriber = Subscribers.Sink<String?, Never>(
           receiveCompletion: { completion in
         }) { value in
            self.didSelect(productIdentifier: value)
        }

        DispatchQueue.main.async {
            let mojeyStorefrontView =  MojeyStorefrontView(packs: packs).environmentObject(self.purchasingSelection)
            self.hostingController = UIHostingController(rootView: mojeyStorefrontView)

            self.purchasingSelection.$productIdentifier.subscribe(subscriber)

            self.addChild(self.hostingController)
            self.view.addSubview(self.hostingController.view)
        }
    }

    func addPrices(packs: [MojeyPack]) -> [MojeyPack] {
        return packs.map { (pack) -> MojeyPack in
            var updatePack = pack
            updatePack.price = storeManager.localizedPriceForProductID(productIdentifier: pack.productIdentifier) ?? ""
            return updatePack
        }
    }

    func didSelect(productIdentifier: String?) {
        print(productIdentifier ?? "")
        if let productIdentifier = productIdentifier {
            let _ = storeManager.purchaseProductIdentifier(productIdentifier: productIdentifier)
        }
    }

    func storeManager(storeManger: StoreManager, purchasing productIdentifier: String) {
        print("purchasing... \(productIdentifier)")
    }

    func storeManager(storeManger: StoreManager, purchased productIdentifier: String) {
//        try? MojeyPurchaseManager.default.processPurchase(productIdentifier: productIdentifier)
//        DispatchQueue.main.async {
//            self.delegate?.mojeyStorefrontViewControllerDidFinish()
//        }
    }

    func storeManager(storeManger: StoreManager, purchased transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.delegate?.mojeyStorefrontViewControllerDidFinish()
        }
        do {
            try MojeyPurchaseManager.default.processPurchase(transaction: transaction)
        } catch {
            print("$$$$$$$PURCHASE ERROR")
            print(error.scError.reason)
        }
    }

    func storeManager(storeManger: StoreManager, purchaseFailed productIdentifier: String) {
        
    }

    func storeManager(storeManger: StoreManager, didUpdateProducts productIdentifiers: [String]) {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        for pid in productIdentifiers {
            let price = storeManger.localizedPriceForProductID(productIdentifier: pid)!
            print("\(pid) \(price)")
        }
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        var packs = MojeyPackProvider.default.packs(productIdentifiers: productIdentifiers)
        packs = addPrices(packs: packs)
        showStorefrontView(packs: packs)
    }
    


}
