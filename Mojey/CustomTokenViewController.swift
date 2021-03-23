//
//  CustomTokenViewController.swift
//  Mojey
//
//  Created by Todd Bowden on 11/9/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class CustomTokenViewController: UIViewController, CreateCustomTokenViewControllerDelegate {


    var tokens = [TokenQuantity]()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let add = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        add.center = CGPoint(x: self.view.frame.size.width/2, y: 100)
        add.setTitle("+", for: .normal)
        add.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        add.addTarget(self, action: #selector(tapAdd), for: .touchUpInside)
        self.view.addSubview(add)


        if let tks = try? MojeyStore.default.getExistingTokenQuantities() {
            tokens = tks
        }




        let tokenGrid = TokenGrid(tokens: tokens) {
            self.presentCreateToken()
        }
        let hostingController = UIHostingController(rootView: tokenGrid)
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.view.frame = self.view.bounds

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MojeyStore.default.printMojeyStore()
    }

    @objc func tapAdd() {
        print("+")
        presentCreateToken()
    }

    func presentCreateToken() {
        let createCustomTokenViewController = CreateCustomTokenViewController()
        createCustomTokenViewController.delegate = self
        self.present(createCustomTokenViewController, animated: true, completion: nil)
    }


    func createCustomTokenViewControllerDidFinish(customToken: CustomToken) {
        print("finish")
        print(customToken)
        self.dismiss(animated: true, completion: nil)
    }

    func createCustomTokenViewControllerDidFinish(error: SCError) {
        print("error")
        print(error.reason)
        self.dismiss(animated: true, completion: nil)
    }

}



struct TokenGrid: View {



    var tokens: [TokenQuantity]
    var create: ()->Void

    var columns: [GridItem] {
        return
            [
                GridItem(.fixed(100), spacing: 16),
                GridItem(.fixed(100), spacing: 16),
                GridItem(.fixed(100), spacing: 16)
            ]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                Section(header: Text("")) {
                    Text("H")
                    BadgedMojey(mojeyQuantity: MojeyQuantity(mojey: "😊", quantity: 10))
                    ForEach(0..<tokens.count, id: \.self) { i in
                        BadgedToken(tokenQuantity: tokens[i])
                    }
                }
            }
        }


    }

}
