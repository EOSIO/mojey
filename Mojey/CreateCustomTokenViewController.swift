//
//  CustomTokenView.swift
//  Mojey
//
//  Created by Todd Bowden on 11/2/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import SwiftUI

protocol CreateCustomTokenViewControllerDelegate: class {
    func createCustomTokenViewControllerDidFinish(customToken: CustomToken)
    func createCustomTokenViewControllerDidFinish(error: SCError)
}

class CreateCustomTokenViewController: UIViewController {

    weak var delegate: CreateCustomTokenViewControllerDelegate?

    private let mojeyStore = MojeyStore.default
    private let customTokenDefinitionStore = CustomTokenDefinitionStore.default
    private let keychain = Keychain(accessGroup: Constants.accessGroup)
    private var tokenKey = Data()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let key = try keychain.createEllipticCurveKey(secureEnclave: true, tag: "CT", label: nil, accessFlag: nil)
            tokenKey = key.uncompressedPublicKey
            let hostingController = UIHostingController(rootView: CreateCustomTokenView(tokenKey: tokenKey, create: { (customToken) in
                print(customToken)
                self.handleCreateNew(customToken: customToken)
            }))
            self.addChild(hostingController)
            self.view.addSubview(hostingController.view)
            hostingController.view.frame = self.view.bounds
        } catch {
            try? keychain.deleteKey(publicKey: tokenKey)
            delegate?.createCustomTokenViewControllerDidFinish(error: error.scError)
        }
    }

    func handleCreateNew(customToken: CustomToken) {
        do {
            var customToken = customToken
            let sig = try keychain.sign(publicKey: customToken.tokenKey, data: customToken.concat())
            print(sig.hex)
            try? keychain.deleteKey(publicKey: tokenKey)
            customToken.signature = sig
            print(customToken.signature.hex)

            try customTokenDefinitionStore.save(customToken: customToken)
            try mojeyStore.increment(mojey: "\(customToken.tokenKey.hex):\(customToken.supply)")
            delegate?.createCustomTokenViewControllerDidFinish(customToken: customToken)
        } catch {
            print("catch error")
            print(error.scError.reason)
            try? keychain.deleteKey(publicKey: tokenKey)
            delegate?.createCustomTokenViewControllerDidFinish(error: error.scError)
        }
    }
}

struct CreateCustomTokenView: View {

    let tokenKey: Data
    let create: ((CustomToken)->Void)

    @State private var name = ""
    @State private var issurer = ""
    @State private var description = ""
    @State private var supply = ""

    @State private var backgroundColor = Color.white
    @State private var primaryColor = Color.black

    //@State private var imageHash = Data()
    //@State private var symbol = ""

    private func customToken() -> CustomToken {
        var customToken = CustomToken()
        customToken.tokenKey = tokenKey
        customToken.name = name
        customToken.issurerName = issurer
        customToken.description = description
        customToken.supply = UInt64(supply) ?? 0
        customToken.primaryColor = primaryColor.hex
        customToken.backgroundColor = backgroundColor.hex
        return customToken
    }

    func createToken() {
        create(customToken())
    }



    var body: some View {
        GeometryReader { g in

            VStack(spacing: 10) {
                BadgedToken(tokenQuantity: TokenQuantity(token: customToken()))
                    .frame(width: 100, height: 150, alignment: .center)

                LabeledTextField(title: "Name", text: $name, color: .white, keyboard: .default)
                    .foregroundColor(.gray)
                LabeledTextField(title: "Issurer", text: $issurer, color: .white, keyboard: .default)
                    .foregroundColor(.gray)
                LabeledTextField(title: "Description", text: $description, color: .white, keyboard: .default)
                    .foregroundColor(.gray)
                LabeledTextField(title: "Supply", text: $supply, color: .white, keyboard: .numberPad)
                    .foregroundColor(.gray)
                ColorPicker("Primary Color", selection: $primaryColor)
                    .foregroundColor(.gray)
                ColorPicker("Background Color", selection: $backgroundColor)
                    .foregroundColor(.gray)
                Button("Create") {
                    createToken()
                }
            }.padding(20)
        }
    }


}


private struct LabeledTextField: View {
    let title: String
    let text: Binding<String>
    let color: Color
    let keyboard: UIKeyboardType

    var body: some View {
        HStack() {
            Text(title)
            TextField("", text: text)
                .keyboardType(keyboard)
                .foregroundColor(color)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}







