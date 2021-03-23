//
//  BluetoothController.swift
//
//  Created by Todd Bowden.
//  Copyright (c) 2020 All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


// MARK: BluetoothControllerCryptographyProviderProtocol

protocol BluetoothControllerCryptographyProviderProtocol {
    func devicePublicKey() throws -> Data
    func sign(data: Data) throws -> Data
    func verify(publicKey: Data, data: Data, signature: Data) throws -> Bool
    func encrypt(key: Data, data: Data) throws -> Data
    func decrypt(data: Data) throws -> Data
    func sha256(data: Data) -> Data
    func randomBytes() -> Data?
}

// MARK: BluetoothControllerDelegate

protocol BluetoothControllerDelegate {
    func bluetoothController(bluetoothController:BluetoothController, didRead data: Data, from deviceKey: Data)
    func bluetoothController(bluetoothController:BluetoothController, didReceive data: Data, from deviceKey: Data)
    func bluetoothController(bluetoothController:BluetoothController, didUpdateState state: CBManagerState)
}


class BluetoothController:NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate   {

    // MARK: enums
    enum BluetoothControllerState {
        case Unknown
        case Resetting
        case Unsupported
        case Unauthorized
        case PoweredOff
        case PoweredOn

        var string:String {
            switch self {
            case .Unknown: return "Unknown"
            case .Resetting: return "Resetting"
            case .Unsupported: return "Unsupported"
            case .Unauthorized: return "Unauthorized"
            case .PoweredOff: return "PoweredOff"
            case .PoweredOn: return "PoweredOn"
            }
        }
    }

    enum MessageHeader: UInt8 {
        case v1 = 1
    }

    enum MessageEncryption: UInt8 {
        case none = 0
        case publicKey = 1
    }

    enum MessageType: UInt8 {
        case completeMessage = 10
        case messageReceipt = 11
        case messageResendRequest = 12
        case packet = 20
        case packetResendRequest = 21
    }


    // MARK: classes and structs


    private class PeripheralPeer  {
        var peripheral: CBPeripheral
        var readResponse: ReadResponse?
        var deviceKey: Data? {
            return readResponse?.deviceKey
        }
        var data: Data? {
            return readResponse?.data
        }
        var readCharacteristic: CBCharacteristic?
        var writeCharacteristic: CBCharacteristic?

        var lastEncountered = Date(timeIntervalSince1970: 0)
        var lastRead = Date(timeIntervalSince1970: 0)

        init(peripheral:CBPeripheral) {
            self.peripheral = peripheral
        }

    }


    private class CentralPeer {
        var central:CBCentral
        var userID:String? {
            didSet {
                lastEncountered = NSDate()
            }
        }
        var lastEncountered:NSDate


        init(central:CBCentral) {
            self.central = central
            lastEncountered = NSDate()
        }
    }


/*
    struct WritePacket {
        var header: UInt8 = 3
        var version: UInt8 = 1
        var messageid: Data
        var packet: UInt8
        var numPackets: UInt8
        var data: Data
    }

    struct WriteMessage {
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var signature: Data
        var data: Data

        var concat: Data {
            return [version] + senderDeviceKey + data
        }

        private func countData(data: Data) -> Data {
            return [UInt8(data.count)] + data
        }

        func encoded() -> Data  {
            return [version] + countData(data: senderDeviceKey) + countData(data: signature) + data
        }

        func packets(maxBytes: Int) -> [WritePacket] {
            var packets = [WritePacket]()
            let uuid = UUID().uuid
            let messageid = Data([uuid.0] + [uuid.2] + [uuid.4] + [uuid.6] + [uuid.8] + [uuid.10] + [uuid.12] + [uuid.14])
            let dataPerPacket = maxBytes - messageid.count - 6
            var numPackets = data.count / dataPerPacket
            if data.count % dataPerPacket > 0 {
                numPackets += 1
            }
            var encodedData = self.encoded()
            for i in 1...numPackets {
                let pData = encodedData.prefix(dataPerPacket)
                encodedData.removeFirst(dataPerPacket)
                let packet = WritePacket(header: 3, version: 1, messageid: messageid, packet: UInt8(i), numPackets: UInt8(numPackets), data: pData)
                packets.append(packet)
            }
            return packets
        }

        init(senderDeviceKey: Data, data: Data) {
            self.senderDeviceKey = senderDeviceKey
            self.data = data
            self.signature = Data()
        }

        init?(encodedData: Data?) {
            guard var encodedData = encodedData else { return nil }
            guard encodedData.count > 8 else { return nil }
            version = encodedData.removeFirst()
            guard version == 1 else { return nil }

            var len = Int(encodedData.removeFirst())
            guard encodedData.count >= len else { return nil }
            senderDeviceKey = encodedData.prefix(len)
            encodedData.removeFirst(len)

            len = Int(encodedData.removeFirst())
            guard encodedData.count >= len else { return nil }
            signature = encodedData.prefix(len)
            encodedData.removeFirst(len)

            data = encodedData
        }
    }
    */
    
    struct ReadResponse: Codable {
        var version: UInt8 = 1
        var deviceKey: Data
        var data: Data


        private func countData(data: Data) -> Data {
            return [UInt8(data.count)] + data
        }

        func encoded() -> Data  {
            return [version] + countData(data: deviceKey) + data
        }

        init(deviceKey: Data, data: Data) {
            self.deviceKey = deviceKey
            self.data = data
        }

        init?(encodedData: Data?) {
            guard var encodedData = encodedData else { return nil }
            guard encodedData.count > 8 else { return nil }
            version = encodedData.removeFirst()
            guard version == 1 else { return nil }

            let len = Int(encodedData.removeFirst())
            guard encodedData.count >= len else { return nil }
            deviceKey = encodedData.prefix(len)
            encodedData.removeFirst(len)

            data = encodedData
        }
    }//

    class SendQueue {
        var queue = [Data:[Data]]()

        func add(message: Data, deviceKey: Data) {
            var messages = queue[deviceKey] ?? [Data]()
            messages.append(message)
            queue[deviceKey] = messages
        }

        func remove(message: Data, deviceKey: Data) {
            var messages = queue[deviceKey] ?? [Data]()
            messages = messages.filter { (data) -> Bool in
                data != message
            }
            queue[deviceKey] = messages
        }
    }



    struct Message {
        var messageType = MessageType.completeMessage
        var version: UInt8 = 1
        var messageID: Data
        var senderDeviceKey:  Data
        var signature = Data()
        var data = Data()

        var signable: Data {
            return messageType.rawValue.data + version.data + messageID.varData + senderDeviceKey.varData + data
        }

        var encoded: Data {
            return messageType.rawValue.data + version.data + messageID.varData + senderDeviceKey.varData + signature.varData + data
        }

        init(messageID: Data, senderDeviceKey: Data) {
            self.messageID = messageID
            self.senderDeviceKey = senderDeviceKey
        }

        init(encodedData: Data) {
            var data = encodedData
            messageType = MessageType(rawValue: data.removeFirst()) ?? MessageType.completeMessage
            version = data.removeUInt8()
            messageID = data.removeVarData()
            senderDeviceKey = data.removeVarData()
            signature = data.removeVarData()
            self.data = data
        }
    }


    struct MessageReceipt {
        var messageType = MessageType.messageReceipt
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var messageID: Data
        var signature = Data()

        var signable: Data {
            return version.data + senderDeviceKey.varData + messageID.varData
        }

        var encoded: Data {
            return version.data + senderDeviceKey.varData + messageID.varData + signature
        }

        init(messageID: Data, senderDeviceKey: Data) {
            self.messageID = messageID
            self.senderDeviceKey = senderDeviceKey
        }

        init(encodedData: Data) {
            var data = encodedData
            messageType = MessageType(rawValue: data.removeFirst()) ?? MessageType.messageReceipt
            version = data.removeUInt8()
            senderDeviceKey = data.removeVarData()
            messageID = data.removeVarData()
            signature = data
        }
    }


    struct MessageResendRequest {
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var messageID: Data
        var signature: Data

        var encoded: Data {
            return version.data + senderDeviceKey.varData + messageID.varData + signature
        }

        init(encodedData: Data) {
            var data = encodedData
            version = data.removeUInt8()
            senderDeviceKey = data.removeVarData()
            messageID = data.removeVarData()
            signature = data
        }
    }


    struct PacketResendRequest {
        var version: UInt8 = 1
        var senderDeviceKey: Data
        var messageID: Data
        var bytesPerPacketNumber: UInt8 = 1
        var packetNumbers: Data

        var encoded: Data {
            return version.data + senderDeviceKey.varData + messageID.varData + bytesPerPacketNumber.data + packetNumbers
        }

        //init()

        init(encodedData: Data) {
            var data = encodedData
            version = data.removeUInt8()
            senderDeviceKey = data.removeVarData()
            messageID = data.removeVarData()
            bytesPerPacketNumber = data.removeUInt8()
            packetNumbers = data
        }
    }


    struct Packet {
        enum Status {
            case none
            case created
            case sent
            case placeholder
            case validated
            case invalid
        }

        var messageType = MessageType.packet
        var version: UInt8 = 1
        var messageID = Data()
        var packetNumber: UInt16 = 0
        var numberOfPackets: UInt16 = 0
        var checkhash = Data()
        var data = Data()

        var dateReceived: Date?
        var status: Status = .none

        var encoded: Data {
            return messageType.rawValue.data + version.data + messageID.varData + packetNumber.data + numberOfPackets.data + checkhash.varData + data
        }

        private var hashable: Data {
            return messageType.rawValue.data + version.data + messageID.varData + packetNumber.data + numberOfPackets.data + data
        }

        mutating func computeCheckhash() {
            checkhash = hashable.sha256.prefix(4)
        }

        var isValid: Bool {
            //print("\(checkhash.hex) ?= \(hashable.sha256.prefix(4).hex)")
            return checkhash == hashable.sha256.prefix(4)
        }

        mutating func validate() {
            status = isValid ? .validated : .invalid
        }

        init() { }

        init(encodedData: Data) {
            var data = encodedData
            messageType = MessageType(rawValue: data.removeUInt8()) ?? messageType
            version = data.removeUInt8()
            messageID = data.removeVarData()
            packetNumber = data.removeUInt16()
            numberOfPackets = data.removeUInt16()
            checkhash = data.removeVarData()
            self.data = data
            status = .none
        }
    }


    class PacketSet {
        var messageID = Data()
        var packets = [Int:Packet]()
        var numberOfPackets = 0

        var isComplete: Bool {
            //print("count = \(packets.count) numberOfPackets = \(numberOfPackets)")
            return packets.count == numberOfPackets && numberOfPackets > 0
        }

        var completeData: Data? {
            guard isComplete else { return nil }
            var data = Data()
            for i in 0..<numberOfPackets {
                guard let packet = packets[i] else { return nil }
                data += packet.data
            }
            return data
        }

        func add(packet: Packet) {
            //print("---add-packet----")
            //print(packet.numberOfPackets)
            var packet = packet
            //print(packet.numberOfPackets)
            //print("-------------------")
            if packets.count == 0 {
                messageID = packet.messageID
                //print("aaa")
                numberOfPackets = Int(packet.numberOfPackets)
                //print("aanumberOfPackets = \(numberOfPackets) \(packet.numberOfPackets)")
            }
            //print("add1")
            guard packet.messageID == messageID else { return }
            //print("add2 packets.count = \(packets.count) numberOfPackets = \(numberOfPackets)")
            //print("add3")
            packet.validate()
            //print("After validate = \(packet.status)")
            guard packet.isValid else { return }
            packets[Int(packet.packetNumber)] = packet

        }

    }


    // MARK: Instance Vars



    private(set) var cryptographyProvider: BluetoothControllerCryptographyProviderProtocol
    let myDeviceKey: Data

	private var shouldAdvertiseAndScan: Bool
	var delegate: BluetoothControllerDelegate?

    // Services
    private var serviceCBUUID: CBUUID
	private var restoredServices = [CBMutableService]()
    private var readData: Data
	
	// Characteristics
    private let readCharacteristicCBUUID: CBUUID
    private let writeCharacteristicCBUUID: CBUUID
	
	// Managers
	private var centralManager: CBCentralManager!
	private var peripheralManager: CBPeripheralManager!

	// Lookup Dictionaries
	private var peripheralPeerDictionary = [CBPeripheral:PeripheralPeer]()
	private var centralPeerDictionary = [CBCentral:CentralPeer]()
	private var deviceKeyPeripheralPeerDictionary = [Data:PeripheralPeer]()
	private var deviceKeyCentralPeerDictionary = [Data:CentralPeer]()

    private var sendQueue = SendQueue()
    var packetSets = [Data:PacketSet]() 
	
	// State
	var isPoweredOff:Bool {
        return peripheralManager.state == .poweredOff || centralManager.state == .poweredOff
	}
	var isUnsupported:Bool {
        return peripheralManager.state == .unsupported || centralManager.state == .unsupported
	}
	var isUnauthorized:Bool {
        return peripheralManager.state == .unauthorized || centralManager.state == .unauthorized
	}
    var state: CBManagerState {
        return centralManager.state
	}
	

    struct Config {
        var cryptographyProvider: BluetoothControllerCryptographyProviderProtocol
        var serviceID = ""
        var readID = ""
        var readData = Data()
        var writeID = ""
    }
	
	// MARK: Init
	
    init(config: Config) throws {

        cryptographyProvider = config.cryptographyProvider
		shouldAdvertiseAndScan = true
        myDeviceKey = try cryptographyProvider.devicePublicKey()

        serviceCBUUID = CBUUID(string: config.serviceID)
        readCharacteristicCBUUID = CBUUID(string: config.readID)
        writeCharacteristicCBUUID = CBUUID(string: config.writeID)
        self.readData = config.readData
		
		
		super.init()

		centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:"CentralManager"])
		centralManager.delegate = self
		peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionRestoreIdentifierKey:"PeripheralManager"])
		peripheralManager.delegate = self
		
		//NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "refreshCentralManager", userInfo: nil, repeats: true)

        print("#####################################################")
        let d = "1234567890".data(using: .utf8)!
        print(d.hex)
        let e = try! cryptographyProvider.encrypt(key: myDeviceKey, data: d)
        print(e.hex)
        print("#####################################################")
		
	}
	
	// MARK: Advertising and Scanning
	
	
//	func refreshCentralManager() {
//		widgetDebugLog.append("refreshCentralManager")
//		centralManager.stopScan()
//		centralManager = nil
//		centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:"CentralManager"])
//		centralManager.delegate = self
//		startScanning()
//	}



	
	func stopAdvertisingAndScanning() {
		shouldAdvertiseAndScan = false
		peripheralManager.stopAdvertising()
		centralManager.stopScan()
	}

	
	func startAdvertisingAndScanning() throws {
		shouldAdvertiseAndScan = true
		try startAdvertising()
		startScanning()
	}
	

	
	
	func isRestoredService(service:CBMutableService) -> Bool {
		for rs in restoredServices {
            if service.uuid == rs.uuid {
				return true
			}
		}
		return false
	}
	
	private func startAdvertising() throws {
        guard shouldAdvertiseAndScan && peripheralManager.state == .poweredOn else { return }
        let service = CBMutableService(type: serviceCBUUID, primary: true)
        let readCharacteristic = CBMutableCharacteristic(type: readCharacteristicCBUUID, properties: .read, value: nil, permissions: .readable)
        let writeCharacteristic = CBMutableCharacteristic(type: writeCharacteristicCBUUID, properties: .write, value: nil, permissions: .writeable)
        service.characteristics = [readCharacteristic, writeCharacteristic]

        print("SERVICE: \(service)")

        //peripheralManager
        if isRestoredService(service: service) {
            print("Service restored: \(service.uuid)" )
        }
        else {
            peripheralManager.removeAllServices()
            peripheralManager.add(service)
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[serviceCBUUID]])
        }

        restoredServices.removeAll(keepingCapacity: false)
        //widgetDebugLog.append("startAdvertising")
	}
	
	private func startScanning() {
        guard shouldAdvertiseAndScan && centralManager.state == .poweredOn else { return }
        print(serviceCBUUID.uuidString)
        centralManager.scanForPeripherals(withServices: [serviceCBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        //widgetDebugLog.append("startScanning")
	}

	
	

	
	
	func addNewCentralPeerIfNewCentral(central:CBCentral) {
		if centralPeerDictionary[central] == nil {
			let centralPeer = CentralPeer(central: central)
			centralPeerDictionary[central] = centralPeer
		}
	}
	
	/*
	private func removeOtherVersionsOfPeripheralPeer(peripheralPeer:PeripheralPeer) -> Int {
		if let userID = peripheralPeer.userID {
			var numRemoved = 0
			for peer in peripheralPeerDictionary.values {
				if let peerUserID = peer.userID {
					if peerUserID == userID && peer.peripheral != peripheralPeer.peripheral {
						peripheralPeerDictionary[peer.peripheral] = nil
						numRemoved++
					}
				}
			}
			return numRemoved
		}
		else {
			return 0
		}
	}
	*/

	
	// MARK: Central Manager Delegate

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("will restore state \(dict)")
		//widgetDebugLog.append("Central Will Restore State")
	}
	
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
		//widgetDebugLog.append("Did Update State: \(centralManager.state.string)")
        if shouldAdvertiseAndScan && centralManager.state == .poweredOn {
			startScanning()
		}
        self.delegate?.bluetoothController(bluetoothController: self, didUpdateState: centralManager.state)
	}

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("\(Date()) did discover \(peripheral)")
        if let peripheralPeer = peripheralPeerDictionary[peripheral] {
            //print("already known")
            guard -peripheralPeer.lastEncountered.timeIntervalSinceNow > 5 else { return }
            //print("DID DISCOVER \(peripheral)")
            //print("recheck \(peripheral) \(peripheralPeer.readResponse)")
            peripheralPeer.lastEncountered = Date()
            if peripheralPeer.readResponse == nil || -peripheralPeer.lastRead.timeIntervalSinceNow > 30 {
                //print("read response \(peripheralPeer.readResponse)")
                peripheralPeer.lastRead = Date()
                if peripheral.state == .connected {
                    //print("DISCOVER SERVICES \(peripheral)")
                    peripheral.discoverServices([serviceCBUUID])
                } else {
                    peripheral.delegate = self
                    central.connect(peripheral, options: nil)
                }
            } else {
                //print("-------------------------------------")
                //print("already have read response")
                //print(peripheral.identifier)
                //print(peripheralPeer.readResponse!.deviceKey.hex)
                //print(peripheralPeer.readResponse!.data)
                //print(advertisementData)
                //print("-------------------------------------")
            }

        } else {
			//widgetDebugLog.append("discovered new peripheral \(peripheral.identifier)")
			let peripheralPeer = PeripheralPeer(peripheral: peripheral)
            peripheralPeer.lastEncountered = Date()
			peripheralPeerDictionary[peripheral] = peripheralPeer
			//widgetDebugLog.append("num peripheralPeers: \(peripheralPeerDictionary.count)")
			peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
	}
	
	
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		//widgetDebugLog.append("Did connect peripheral \(peripheral.identifier)")
        print("Did connect peripheral \(peripheral)")
		peripheral.discoverServices([serviceCBUUID])
	}
	

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Did FAIL connect \(peripheral) \(error)")
		// retry after x sec y times?
		//widgetDebugLog.append("Did fail to connect peripheral \(peripheral.identifier)")
	}
	
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		if let peripheralPeer = peripheralPeerDictionary[peripheral] {
			//widgetDebugLog.append("Did disconnect peripheral userID: \(peripheralPeer.userID)")
            print("Did Disconnect \(peripheralPeer.peripheral)")
		}
		else {
			//widgetDebugLog.append("Did disconnect peripheral")
		}
		
	}
	
	
	// MARK:  Peripheral Delegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //print("disover services \(peripheral)")
		//widgetDebugLog.append("Did discover services of peripheral \(peripheral.identifier)")
        //guard let service = peripheral.services?.first else { return }
        guard let services = peripheral.services else { return }
        for service in services {
            //print("service \(service.uuid.uuidString) num services = \(services.count)")
            if service.uuid == serviceCBUUID {
                peripheral.discoverCharacteristics([readCharacteristicCBUUID,writeCharacteristicCBUUID], for: service as CBService)
            }
        }
	}
    
	
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //print("didDiscoverCharacteristics1 \(peripheral)")
        guard let peripheralPeer = peripheralPeerDictionary[peripheral] else {
            // this should never happen
            //widgetDebugLog.append("disc char: peer not found")
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        //print("didDiscoverCharacteristics2 \(peripheral)")
        //widgetDebugLog.append("didDiscoverCharacteristics \(peripheral.identifier)")
        //print(service.characteristics?.count)
        //print(service.characteristics)
        //print(service.characteristics![0].uuid.uuidString)
        peripheralPeer.readCharacteristic = service.characteristicWithUUID(readCharacteristicCBUUID)
        //print(peripheralPeer.readCharacteristic)
        peripheralPeer.writeCharacteristic = service.characteristicWithUUID(writeCharacteristicCBUUID)
        guard let readCharacteristic = peripheralPeer.readCharacteristic else { return }
        //print("didDiscoverCharacteristics3 \(peripheral)")
        peripheral.readValue(for: readCharacteristic)
    }

	
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("did didUpdateValueFor characteristic \(characteristic)")
        guard let peripheralPeer = peripheralPeerDictionary[peripheral] else {
            // this should never happen
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        guard error == nil else {
            //print("didUpdateValue ERROR")
            //print(error)
            return
        }

        if characteristic.uuid == peripheralPeer.readCharacteristic?.uuid {
            //print("QQQQQQ")
            //print(characteristic.uuid)

            //print("====DID UPDATE VALUE=========================================================================")
            //print(characteristic.value!.hex)
            //print("=============================================================================")
            //print("---update value ----------------------------")
            //print(characteristic.value!.hex)
            //print("-------------------------------")
            guard let readResponse = ReadResponse(encodedData: characteristic.value) else { return }
            // validate signature
            //print("Q1")
            //print("====DID UPDATE VALUE=========================================================================")
            //print(characteristic.value!.hex)
            //print("=============================================================================")
            //print(readResponse.deviceKey.hex)
            //print(readResponse.concat.hex)
            //print(readResponse.signature.hex)
            //print(String(data: readResponse.data, encoding: .utf8)!)
            //print("=============================================================================")
            //try! cryptographyProvider.verify(publicKey: readResponse.deviceKey, data: readResponse.concat, signature: readResponse.signature)
            //guard (try? cryptographyProvider.verify(publicKey: readResponse.deviceKey, data: readResponse.concat, signature: readResponse.signature)) ?? false else { return }
            // be sure the signature is different to avoid a replay attack
            //print("Q2")
            //guard peripheralPeer.readResponse?.signature != readResponse.signature else { return }
            // set or update the deviceKey peripheralPeer
            //print("Q3")
            peripheralPeer.readResponse = readResponse
            deviceKeyPeripheralPeerDictionary[readResponse.deviceKey] = peripheralPeer
            delegate?.bluetoothController(bluetoothController: self, didRead: readResponse.data, from: readResponse.deviceKey)
        }
	}
	
	
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("---didWriteValue---to peripheral---------------")
        //print(peripheral)
        //print(characteristic.value)
        //print("---didWriteValue------------------")
	}
	
	
	// MARK: Peripheral Manager Delegate

	
	func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("*********************************************")
        print("*********************************************")
        print("*********************************************")
		print("peripheralManager willRestoreState \(dict)")

		
		if let services = dict[CBPeripheralManagerRestoredStateServicesKey] as? [CBMutableService] {
			restoredServices += services
			print("restored services \(restoredServices)")
		}

        print("*********************************************")
        print("*********************************************")
        print("*********************************************")
		
		let note = UILocalNotification()
		note.alertBody = "peripheralManager willRestoreState"
        UIApplication.shared.scheduleLocalNotification(note)
		
	}
	
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		//println("peripheralManager peripheralManagerDidUpdateState \(peripheral.state)")
		//var note = UILocalNotification()
		//note.alertBody = "peripheralManagerDidUpdateState"
		//UIApplication.sharedApplication().scheduleLocalNotification(note)
		
        if shouldAdvertiseAndScan && peripheralManager.state == .poweredOn {
			try? startAdvertising()
		}
	}
	
	
	func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
		print("peripheralManager didAddService \(service)")
	}
	

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
		print("peripheralManagerDidStartAdvertising")
	}
	
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
		
	}
	
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
		
	}
	
	
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        //print("\(Date()) didReceiveRead request")
		if request.characteristic.uuid == readCharacteristicCBUUID {
			//widgetDebugLog.append("didReceiveReadUserIDRequest")
            var readResponse = ReadResponse(deviceKey: myDeviceKey, data: readData)
            //readResponse.nonce = cryptographyProvider.randomBytes() ?? Data()
            //readResponse.nonce = "aa".data(using: .utf8)!
            //guard let sig = try? cryptographyProvider.sign(data: readResponse.concat) else {
            //    peripheralManager.respond(to: request, withResult: CBATTError.insufficientEncryption)
            //    return
            //}
            //readResponse.signature = sig
            /*
            try! cryptographyProvider.verify(publicKey: readResponse.deviceKey, data: readResponse.concat, signature: readResponse.signature)
            print("====didReceiveRead=========================================================================")
            print(readResponse.deviceKey.hex)
            print(readResponse.concat.hex)
            print(readResponse.signature.hex)
            print("=============================================================================")
            let encodedResponse = readResponse.encoded()


            let decodedResponse = ReadResponse(encodedData: encodedResponse)!
            print("====decodedResponse =========================================================================")
            print(decodedResponse.deviceKey.hex)
            print(decodedResponse.concat.hex)
            print(decodedResponse.signature.hex)
            print(String(data: decodedResponse.data, encoding: .utf8)!)
            print("=============================================================================")

            let numB = UInt8(encodedResponse.count % 256)
            print("=====encodedResponse========================================================================")
            print("num bytes mod 256 = \(numB)")
            print(encodedResponse.hex)
            print("====offset=========================================================================")
            print(request.offset)
            print("========t=========================================================================")
            //request.value = [numB] + encodedResponse
            //request.value = "aa".data(using: .utf8)!
            */

            //let hex0 = "014104a26570b08c86258db65b3976c9b3dcb11697792e8c15ff8aa88d2944250b8719ba97b8171a29aa4d7adbc6246343573ac187a317a82be6fbd3dad08bd656"
            //let hex1 = "014104a26570b08c86258db65b3976c9b3dcb11697792e8c15ff8aa88d2944250b8719ba97b8171a29aa4d7adbc6246343573ac187a317a82be6fbd3dad08bd6560ea7026161473045022100b04a6bf9c5e171d50fac554d5f8425ec8d7e2d894730f6b24795d5e0bf3795ef"
            //let hex2 = "014104a26570b08c86258db65b3976c9b3dcb11697792e8c15ff8aa88d2944250b8719ba97b8171a29aa4d7adbc6246343573ac187a317a82be6fbd3dad08bd6560ea7026161473045022100b04a6bf9c5e171d50fac554d5f8425ec8d7e2d894730f6b24795d5e0bf3795ef02200bf2e2e72dab281478be30ce6143b415a612926b769b571df7f26e30b3f56aba7b226d6f64656c223a226950686f6e6531322c35222c226e616d65223a22546f6464e2809973206950686f6e652031312050726f204d6178227d"

            //let hex = String(hex2.prefix(400))
            //print("====HEX=========")
            //print(hex)
            //print(request.offset)
            //print("================")

            //var d = try! Data(hex: "014104a26570b08c86258db65b3976c9b3dcb11697792e8c15ff8aa88d2944250b8719ba97b8171a29aa4d7adbc6246343573ac187a317a82be6fbd3dad08bd6560ea7026161473045022100b04a6bf9c5e171d50fac554d5f8425ec8d7e2d894730f6b24795d5e0bf3795ef02200bf2e2e72dab281478be30ce6143b415a612926b769b571df7f26e30b3f56aba7b226d6f64656c223a226950686f6e6531322c35222c226e616d65223a22546f6464e2809973206950686f6e652031312050726f204d6178227d")

            //var d = try! Data(hex: hex)
            //for i in 0...255 {
            //    d = d + [UInt8(i)]
            //}
            request.value = readResponse.encoded()
            peripheralManager.respond(to: request, withResult: CBATTError.success)
		}
	}
	
	
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
		// this should never happen, just being defensive
        //print("w0")
        guard requests.count > 0  else { return }
        let firstRequest = requests[0] as CBATTRequest
        var result = CBATTError.success

        for request in requests as [CBATTRequest] {

            //print("w1")
            guard let value = request.value else { continue }
            try? processIncomming(data: value)
            /*
            print("w2")
            var message = value
            print(message.hex)
            print("w3")
            guard message.count > 8 else { continue }
            print("w4")
            let version = message.removeFirst()
            guard version == 1 else { continue }
            print("w5")
            guard let decryptedMessage = try? cryptographyProvider.decrypt(data: message) else { continue }
            print("w6")
            guard let message = Message(encodedData: decryptedMessage)
            print("w7")
            guard (try? cryptographyProvider.verify(publicKey: message.senderDeviceKey, data: writeMessage.concat, signature: writeMessage.signature)) ?? false else { continue }
            print("w8")
            delegate?.bluetoothController(bluetoothController: self, didReceive: message.data, from: writeMessage.senderDeviceKey)
            */
        }

        peripheralManager.respond(to: firstRequest, withResult: result)


		//widgetDebugLog.append("didReceiveWriteRequests")

        /*
		let firstRequest = requests[0] as CBATTRequest
        var result = CBATTError.success

		for request in requests as [CBATTRequest] {
            if let message = WriteMessage(encodedData: request.value)  {
                delegate?.bluetoothController(bluetoothController: self, didReceive: message.data, from: message.senderDeviceKey)
            } else {
                result = .writeNotPermitted
            }

		}
		print("FIRSTREQUEST: \(firstRequest)")
        peripheralManager.respond(to: firstRequest, withResult: result)
        */
	}
	
	


    // MARK: Processing Messages

    func newMessageID() -> Data {
        let u = UUID().uuid
        let uuidData = Data([u.0] + [u.1] + [u.2] + [u.3] + [u.4] + [u.5] + [u.6] + [u.7] + [u.8] + [u.9] + [u.10] + [u.11] + [u.12] + [u.13] + [u.14] + [u.15])
        return uuidData.sha256.prefix(6)
    }

    func processIncomming(data: Data) throws {
        guard data.count > 4 else { return }
        var data = data
        // check header and decrypt
        let header = data.removeFirst()
        guard header == MessageHeader.v1.rawValue else { return }
        let encryption = data.removeFirst()
        if encryption == MessageEncryption.publicKey.rawValue {
            data = try cryptographyProvider.decrypt(data: data)
        }
        //print("+++processIncomming++++++++++++")
        //print(data.hex)
        //print("++++++++++++++++++++++++++++++++")
        guard let mt = data.first else { return }
        let messageType = MessageType(rawValue: mt)
        switch messageType {
        case .completeMessage:
            let message = Message(encodedData: data)
            try processIncomming(message: message)
        case .packet:
            let packet = Packet(encodedData: data)
            try processIncomming(packet: packet)
        default:
            ()

        }
    }


    func processIncomming(message: Message) throws {
        // validate signature
        let validSignature = try cryptographyProvider.verify(publicKey: message.senderDeviceKey, data: message.signable, signature: message.signature)
        guard validSignature else {
            throw SCError(reason: "Invalid signature")
        }
        delegate?.bluetoothController(bluetoothController: self, didReceive: message.data, from: message.senderDeviceKey)
    }


    func processIncomming(packet: Packet) throws {
        var packet = packet
        packet.validate()
        if packet.isValid {
            // add to packet set
            let packetSet = packetSets[packet.messageID] ?? PacketSet()
            packetSet.add(packet: packet)
            packetSets[packet.messageID] = packetSet
            //print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            //print("add packet \(packet.packetNumber)")
            //print("is valid = \(packet.isValid)")
            //print("is complete = \(packetSet.isComplete)")
            //print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            if let completeData = packetSet.completeData {
                packetSets[packet.messageID] = nil
                try processIncomming(data: completeData)
            }
        } else {
            // request resend
            //let resendRequest = PacketResendRequest
        }
    }


    func send(data: Data, targetDeviceKey:Data) throws {
        //print("\n~~~SEND DATA \(data.prefix(20).hex)\n")
        var message = Message(messageID: newMessageID(), senderDeviceKey: myDeviceKey)
        message.data = data
        message.signature = try cryptographyProvider.sign(data: message.signable)
        let encodedMessage = try encodeAndEncrypt(message: message, encryptionKey: targetDeviceKey)
       // print("\n~~~ \(encodedMessage.prefix(20).hex)\n")
        if let peer = deviceKeyPeripheralPeerDictionary[targetDeviceKey], let writeCharacteristic = peer.writeCharacteristic  {
            //print("~~~~!!!")
            let maxWrite = peer.peripheral.maximumWriteValueLength(for: .withoutResponse)
            // if short enough send message
            if maxWrite > encodedMessage.count {
                // add to message queue
                try write(data: encodedMessage, targetDeviceKey: targetDeviceKey)
            } else {
                let packets = createPackets(encodedMessage: encodedMessage, messageID: message.messageID, writeSize: maxWrite)
                //print("NUMBER OF PACKETS = \(packets.count)")
                for packet in packets {
                    let encodedPacket = encode(packet: packet)
                    try write(data: encodedPacket, targetDeviceKey: targetDeviceKey)
                }
            }
        }
    }



    private func encodeAndEncrypt(message: Message, encryptionKey: Data) throws -> Data {
        let encryptedEncodedMessage = try cryptographyProvider.encrypt(key: encryptionKey, data: message.encoded)
        return [MessageHeader.v1.rawValue] + [MessageEncryption.publicKey.rawValue] + encryptedEncodedMessage
    }

    private func encode(packet: Packet) -> Data {
        return [MessageHeader.v1.rawValue] + [MessageEncryption.none.rawValue] + packet.encoded
    }


    private func createPackets(encodedMessage: Data, messageID: Data, writeSize: Int) -> [Packet] {
        var encodedMessage = encodedMessage
        let dataPerPacket = writeSize - messageID.count - 16
        var numPackets = encodedMessage.count / dataPerPacket
        if encodedMessage.count % dataPerPacket > 0 {
            numPackets += 1
        }
        var packets = [Packet]()
        //print("NUMBER OF PACKETS = \(numPackets)")
        for i in 0..<numPackets {
            var packet = Packet()
            packet.messageID = messageID
            packet.packetNumber = UInt16(i)
            packet.numberOfPackets = UInt16(numPackets)
            packet.data = encodedMessage.prefix(dataPerPacket)
            //print("^^^^^^^^^^^^^^^^^^^")
            //print(i)
            //print(encodedMessage.hex)
            //print(encodedMessage.count)
            //print(dataPerPacket)
            //print("^^^^^^^^^^^^^^^^^^^")
            if encodedMessage.count > dataPerPacket {
                encodedMessage.removeFirst(dataPerPacket)
            } else {
                encodedMessage.removeAll()
            }

            packet.computeCheckhash()
            packets.append(packet)
        }
        return packets
    }



    private func write(data: Data, targetDeviceKey:Data) throws  {
        if let peripheralPeer = deviceKeyPeripheralPeerDictionary[targetDeviceKey],
           let writeCharacteristic = peripheralPeer.writeCharacteristic,
           peripheralPeer.peripheral.state == .connected {
                peripheralPeer.peripheral.writeValue(data, for: writeCharacteristic, type: .withResponse)
            //print("&&&&&&&&&&&&&&&&&&&&&&&&did attempt write")
        } else {

        }
    }
	
	
}



extension CBService {
    func characteristicWithUUID(_ uuid: CBUUID) -> CBCharacteristic? {
        guard let characteristics = characteristics else { return nil }
        for c in characteristics {
            if c.uuid == uuid {
                return c
            }
        }
        return nil
    }
}


extension CBManagerState {
    var string:String {
        switch self {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "PoweredOff"
        case .poweredOn: return "PoweredOn"
        default: return ""
        }
    }
}


extension Data {

    mutating func removeUInt8() -> UInt8 {
        return self.removeFirst()
    }

    mutating func removeUInt16() -> UInt16 {
        var d = self.prefix(2)
        guard d.count == 2 else { return 0 }
        self.removeFirst(2)
        let b1 = d.removeFirst()
        let b2 = d.first!
        return (UInt16(b1) * 256) + UInt16(b2)
    }

    mutating func removeVarData() -> Data {
        guard self.count > 1 else { return Data() }
        let c = Int(self.removeFirst())
        let data = prefix(c)
        self.removeFirst(c)
        return data
    }

    mutating func appendUInt8(_ int: UInt8) {
        self.append(int)
    }

    mutating func appendUInt16(_ int: UInt16) {
        self.append(UInt8(int / 256))
        self.append(UInt8(int % 256))
    }

    mutating func appendVarData(_ data: Data) {
        self.append(UInt8(data.count))
        self.append(data)
    }

    var varData: Data {
        return [UInt8(self.count)] + self
    }

}

extension UInt16 {
    var data: Data {
        return Data([UInt8(self / 256)] + [UInt8(self % 256)])
    }
}

extension UInt8 {
    var data: Data {
        return Data([self])
    }
}








