//
//  NearbyDevicesManager.swift
//  Mojey
//
//  Created by Todd Bowden on 7/16/20.
//  Copyright © 2020 Mojey. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

protocol NearbyDevicesManagerDelegate: class {
    func nearbyDevicesManager(_ nearbyDevicesManager: NearbyDevicesManager, didUpdate nearbyDevices: [NearbyDevice])
}

class NearbyDevicesManager: BluetoothControllerDelegate {

    static let shared = NearbyDevicesManager()

    weak var delegate: NearbyDevicesManagerDelegate?

    struct Device: Codable {
        var name: String
        var model: String
    }

    //private let tokenTransferMeanger = TokenTransferManager.defaut

    private(set) var nearbyDevices = [NearbyDevice]()

    func nearbyDevice(key: Data) -> NearbyDevice? {
        return nearbyDevices.first { (nd) -> Bool in
            nd.key == key
        }
    }
    
    let bluetoothContoller: BluetoothController

    init() {
        let cryptographyProvider = BluetoothControllerCryptographyProvider()
        var config = BluetoothController.Config(cryptographyProvider: cryptographyProvider)
        let name = UIDevice.current.name
        let device = Device(name: name, model: UIDevice.current.modelIdentifier)
        let data = (try? device.toJsonData()) ?? Data()
        config.serviceID = "020B2962-68A9-44A8-BE1D-5987FD799B8E"
        config.readID = "BF96D772-F300-4ADA-8C75-37D51B4C5089"
        config.writeID = "DDA0F642-8D80-4D6C-AC0B-2116006C3A93"
        config.readData = data

        bluetoothContoller = try! BluetoothController(config: config)
        bluetoothContoller.delegate = self

        try! bluetoothContoller.startAdvertisingAndScanning()

    }


    func send(message: Data, targetDeviceKey: Data) {
        try? bluetoothContoller.send(data: message, targetDeviceKey: targetDeviceKey)
    }


    func sendTestMessage() {
        print("send Test message")
        var data = "Hello World!".data(using: .utf8)!
        for _ in 0...300 {
            data = data + [0x01]
        }
        let key = try! Data(hex: "04bb1a5115e851c7c41e507e633bd153f6a1f5ea380eefc878b3b2c60f446e2755fbc0d165c21b0829daf184277f112ba79c1544f6fd59b28510fe37a7e0e6d484")
        try! bluetoothContoller.send(data: data, targetDeviceKey: key)
    }


    func addOrUpdate(device: Device, deviceKey: Data) {
        if let nbDevice = nearbyDevice(key: deviceKey) {
            nbDevice.date = Date()
        } else {
            let nbDevice = NearbyDevice(name: device.name, type: device.model, key: deviceKey)
            nearbyDevices.append(nbDevice)
        }
        delegate?.nearbyDevicesManager(self, didUpdate: nearbyDevices)
    }


    func bluetoothController(bluetoothController: BluetoothController, didRead data: Data, from deviceKey: Data) {
        let decoder = JSONDecoder()
        guard let device = try? decoder.decode(Device.self, from: data) else { return }
        //print("--------------------------")
        //print(deviceKey.hex)
        //print(device)
        //print("---------------------------")
        addOrUpdate(device: device, deviceKey: deviceKey)
    }

    func bluetoothController(bluetoothController: BluetoothController, didReceive data: Data, from deviceKey: Data) {
        //print("----didReceive----------------------")
        //print(deviceKey.hex)
        //print(data.hex)
        let s = String(data: data, encoding: .utf8)!
        //print(s)
        //print("---------------------------")
        try? processIncoming(message: data) { (error) in
            print(error)
        }
    }

    func bluetoothController(bluetoothController: BluetoothController, didUpdateState state: CBManagerState) {
        print(state.string)
    }



    private func processIncoming(message: Data, completion: @escaping (Error?)->Void) throws {
        var message = message
        guard message.count > 2 else { return }
        let first = message.removeFirst()
        guard let type = Message.MessageType(rawValue: first) else { return }
        let tokenTransferManager = TokenTransferManager.defaut
        print("~~~Incoming type = \(type.rawValue)")
        switch type {
        case .connectionRequest:
            let connectionRequest = try Message.ConnectionRequest.decode(data: message)
            tokenTransferManager.processIncoming(connectionKeysRequest: connectionRequest, completion: completion)
        case .connectionResponse:
            let connectionKeysResponse = try Message.ConnectionResponse.decode(data: message)
            tokenTransferManager.processIncoming(connectionResponse: connectionKeysResponse, completion: completion)
        case .attestationRequest:
            ()
            //let attestationRequest = try Message.AttestationRequest.decode(data: message)
            //tokenTransferManager.processIncoming(attestationRequest: attestationRequest, completion: completion)
        case .attestationResponse:
            ()
            //let attestationResponse = try Message.AttestationResponse.decode(data: message)
            //tokenTransferManager.processIncoming(attestationResponse: attestationResponse, completion: completion)
        case .tokenTransfer:
            let tokenTransfer = try Message.TokenTransfer.decode(data: message)
            tokenTransferManager.processIncoming(tokenTransfer: tokenTransfer, completion: completion)
        case .tokenTransferReceipt:
            let tokenTransferReceipt = try Message.TokenTransferReceipt.decode(data: message)
            try tokenTransferManager.processIncoming(tokenTransferReceipt: tokenTransferReceipt)
        }

    }






}
