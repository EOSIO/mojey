//
//  MessagingController.swift
//  Mojey
//
//  Created by Todd Bowden on 7/16/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class NearbyDevicesManager: BluetoothControllerDelegate {


    var nearbyDevices
    let bluetoothContoller: BluetoothController

    init() {
        let cryptographyProvider = BluetoothControllerCryptographyProvider()
        var config = BluetoothController.Config(cryptographyProvider: cryptographyProvider)
        let data = UIDevice.current.name.data(using: .utf8)!
        config.serviceID = "020B2962-68A9-44A8-BE1D-5987FD799B8E"
        config.readID = "BF96D772-F300-4ADA-8C75-37D51B4C5089"
        config.writeID = "DDA0F642-8D80-4D6C-AC0B-2116006C3A93"
        config.readData = data

        bluetoothContoller = try! BluetoothController(config: config)
        bluetoothContoller.delegate = self

        try! bluetoothContoller.startAdvertisingAndScanning()

    }











    func bluetoothController(bluetoothController: BluetoothController, didRead data: Data, from deviceKey: Data) {
        let s = String(data: data, encoding: .utf8)!
        print("did read from \(deviceKey) \(s)")
    }

    func bluetoothController(bluetoothController: BluetoothController, didReceive data: Data, from deviceKey: Data) {

    }

    func bluetoothController(bluetoothController: BluetoothController, didUpdateState state: CBManagerState) {
        print(state.string)
    }






}
