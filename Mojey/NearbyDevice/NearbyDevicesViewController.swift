//
//  NearbyDevicesViewController.swift
//  Keys
//
//  Created by Todd Bowden on 5/9/18.
//  Copyright © 2018 Todd. All rights reserved.
//

import Foundation
import UIKit

class NearbyDevicesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NearbyDevicesManagerDelegate {
    
    private var nearbyDevices = [NearbyDevice]()
   
    let collectionView: UICollectionView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(nibName: "NearbyDevicesViewController", bundle: nil)
        self.title = "Nearby Devices"
        self.tabBarItem = UITabBarItem(title: "Nearby Devices", image: UIImage(named: "tab-devices"), tag: 1)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(collectionView, at: 0)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(NearbyDeviceCell.self, forCellWithReuseIdentifier: "DeviceCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        NearbyDevicesManager.shared.delegate = self
        refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = self.view.bounds
    }

    
    func refresh() {
        DispatchQueue.main.async {
            self.collectionView.reloadSections([0])
        }
    }
    

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("num devices = \(nearbyDevices.count)")
        return nearbyDevices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: self.view.frame.size.width * 0.45, height: 100)
        } else {
            return CGSize(width: self.view.frame.size.width * 0.9, height: 100)
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = self.view.frame.size.width * 0.04
        return UIEdgeInsets(top: 100, left: inset, bottom: 0, right: inset)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as! NearbyDeviceCell
        guard indexPath.item < nearbyDevices.count else { return cell }
        cell.nearbyDevice = nearbyDevices[indexPath.item]
        //cell.themeColor = UIColor.theme
        //print("\(indexPath.item): \(nearbyDevices[indexPath.item].key)")
        return cell
    }


    func nearbyDevicesManager(_ nearbyDevicesManager: NearbyDevicesManager, didUpdate nearbyDevices: [NearbyDevice]) {
        self.nearbyDevices = nearbyDevices
        //print(nearbyDevices)
        refresh()
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = nearbyDevices[indexPath.item]
        let key = cell.key
        print("DID SELECT \(key.hex)")

        let data = "04a72beff95df4ff44f0b0633f9bf67ff23b877665fdb66771b42481c4589517b0d1ae3ff1debe1c5c22e5f1fa033c5df284b34a851a5e74150f1dd18d3795a26f:9".data(using: .utf8)!
        TokenTransferManager.defaut.initiateTransfer(targetDeviceKey: key, tokens: data) { (error) in
            print("\n---- init Transfer result -----------------------------------")
            print("Error: \(error)")
            print("-------------------------------------------------------\n")
        }

        /*
        let transfer = TokenTransferManager.defaut.createTestTransfer(targetDeviceKey: key) { (transfer, error) in
            guard let transfer = transfer else { return }
            guard let encodedTransfer = try? transfer.toJsonData() else { return }
            print(try! encodedTransfer.toJsonString())
            NearbyDevicesManager.shared.send(message: encodedTransfer, deviceKey: key)
        }
        */
    }
    
}
