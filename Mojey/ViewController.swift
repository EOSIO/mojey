//
//  ViewController.swift
//  EmojiOne
//
//  Created by Todd Bowden on 8/9/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

import UIKit
import CryptoKit
import BigInt
import CryptoKit

class ViewController: UIViewController {

    var messagingController: NearbyDevicesManager!
    let mainTabViewController = UITabBarController()

    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //StoreManager.shared.requestProducts(for: ["test.pack25"])

        let nearbyDevicesViewController = NearbyDevicesViewController()
        let createCustomTokenViewController = CreateCustomTokenViewController()
        let customTokenViewController = CustomTokenViewController()


        mainTabViewController.setViewControllers([nearbyDevicesViewController, customTokenViewController], animated: false)
        self.addChild(mainTabViewController)
        self.view.addSubview(mainTabViewController.view)

        messagingController = NearbyDevicesManager()


        button.setTitle("Send", for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        //self.view.addSubview(button)

        let d1Hex = "0482011f3182011b3081fc0c02726b3181f5302e0c02776b0428a945b43ca5307839ec35a5150af7450d6b18a18c3350b629fe3fad9feeb9c35081d5fb6bb96ba33430070c02626302010a30480c037075620441048b7097a8d2c866d609786bacdf55c86ca85b7f2a894f3656a65acb076d04c1351bd7c44830c7456b0ff2edaa22c65d31e5b5c873319c5fda8382e48ef84205c330070c026b7602010230070c026b7402010430170c036b696404103777afa4c5d04a9ba88149b888996780300f0c03726b6f0208800000000000000030270c03726b6d0420d29d7e94a6b17491a34b2d929c88363c5eec39cb852f8ddc25e7fd09c30cea57300b0c03626964040450dff459301a0c026564311430120c0361636c310b30090c046461636c010101"

        let d2Hex = "0482011f3182011b3081fc0c02726b3181f5302e0c02776b04285ed8384d32cb0fea894b3f9f835ba94b7585baac6615ed5a1b62260db0007588ac2c7af237017c2f30070c02626302010a30480c037075620441046cad1703f0a9992ef1fc265a1984f8786e9dff6691fbc4763ac079752d6f70c03f00b370e28ca08d8ba2d2a16132f5b0f4e3c230a5c8324fdee55a6a56a3a49430070c026b7602010230070c026b7402010430170c036b69640410c41abba0547640fe83e2302ecae8ed97300f0c03726b6f0208800000000000000030270c03726b6d0420c87e31931e4abc2b4e6e2981913c11384331e9b23c2a9b289818fb119863f4b2300b0c03626964040450dff459301a0c026564311430120c0361636c310b30090c046461636c010101"


        try? InitializeKeys.initializeKeys()
        



        // attestationRequests don't have assertions to prevent endless loop
        let keychain = Keychain(accessGroup: Constants.accessGroup)
        let data = "HelloWorld".data(using: .utf8)!
        let hash = data.sha256
        let digest = SHA256.hash(data: data)

        print("!!?????????????????????????")
        print(hash.hex)
        print(digest.data.hex)
        print("!!?????????????????????????")
        let dk = try! DeviceKey.deviceKey()
        let sig = try! keychain.sign(publicKey:dk.uncompressedPublicKey, hash: hash)

        let senderDeviceKey = try! P256.Signing.PublicKey(x963Representation: dk.uncompressedPublicKey)
        let signature = try! P256.Signing.ECDSASignature(derRepresentation: sig)
        let ckr = senderDeviceKey.isValidSignature(signature, for: digest)

        let kcr = try! keychain.verifyWithEllipticCurvePublicKey(keyData: dk.uncompressedPublicKey, hash: hash, signature: sig)
        print("????????????????????????")
        print(kcr)
        print("????????????????????????")
        print(ckr)
        print("????????????????????????")

        try? AttestedKeyStore.default.clearCompactAttestations()

        let k = try! Data(hex: "0400bb1875f058ed2d5596f3effb9c766554c69ceb33ae8f65f48dd967eb5d917d74f868cd7ab9a3a726af2ea50c0da57f6255810639c378df141bdbd5d583c565")
        if let ca = try? AttestedKeyStore.default.getCompactAttestation(key: k) {
            print(ca)
            let v = AttestedKeyService.default.verifyAttestation(key: k, certificateChain: ca.certificateChain, authData: ca.authData, clientHash: ca.clientHash, teamId: Constants.teamId)
            print(v)
            print("????????????????????????")
        }


    }

    @objc func didTap() {

  

    }


}



