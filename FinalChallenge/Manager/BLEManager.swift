//
//  BLEManager.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import Foundation
import CoreBluetooth

enum BLEConst {
    static let service        = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    static let characteristic = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
}

final class BLEManager: NSObject {
    private(set) var central: CBCentralManager!
    private(set) var peripheral: CBPeripheral?
    private var targetCharacteristic: CBCharacteristic?
    
    var onStateChange: ((CBManagerState) -> Void)?
    var onDiscover: ((CBPeripheral, NSNumber, String) -> Void)?
    var onConnect: ((CBPeripheral) -> Void)?
    var onFail: ((Error?) -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onValueUpdate: ((Data) -> Void)?
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }
    
    func startScan() {
        guard central.state == .poweredOn else { return }
        print("📡 startScan (NO FILTER)")
        central.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    func stopScan() { central.stopScan() }
    
    func connect(_ p: CBPeripheral) {
        stopScan()
        peripheral = p
        p.delegate = self
        central.connect(p, options: nil)
    }
    
    func disconnect() {
        guard let p = peripheral else { return }
        central.cancelPeripheralConnection(p)
    }
    
    func readValue() {
        guard let c = targetCharacteristic else { return }
        peripheral?.readValue(for: c)
    }
    
    func writeString(_ text: String) {
        guard let c = targetCharacteristic,
              let data = text.data(using: .utf8) else { return }
        peripheral?.writeValue(data, for: c, type: .withResponse)
    }
    
    func retrievePeripherals(with ids: [UUID]) -> [CBPeripheral] {
        central.retrievePeripherals(withIdentifiers: ids)
    }
    
    func retrieveConnected(with services: [CBUUID]) -> [CBPeripheral] {
        central.retrieveConnectedPeripherals(withServices: services)
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onStateChange?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover p: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        guard RSSI.intValue > -90 else { return }
        
        let localName = (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
                        ?? p.name
                        ?? "Unknown"
        let advServices = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
        let servicesStr = advServices.isEmpty ? "—" : advServices.map { $0.uuidString }.joined(separator: ",")
        print("📣 ADV name=\(localName) rssi=\(RSSI) id=\(p.identifier)  services=\(servicesStr)")
        
        onDiscover?(p, RSSI, localName)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        onConnect?(peripheral)
        peripheral.discoverServices([BLEConst.service])
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        onFail?(error)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        onDisconnect?(error)
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { onFail?(error); return }
        guard let services = peripheral.services, !services.isEmpty else {
            onFail?(NSError(domain: "BLE", code: -2,
                            userInfo: [NSLocalizedDescriptionKey: "No services found"]))
            return
        }
        services.forEach {
            peripheral.discoverCharacteristics([BLEConst.characteristic], for: $0)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard error == nil else { onFail?(error); return }
        for c in service.characteristics ?? [] {
            if c.uuid == BLEConst.characteristic {
                targetCharacteristic = c
                if c.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: c)
                }
            }
        }
        if let last = peripheral.services?.last, service == last, targetCharacteristic == nil {
            onFail?(NSError(domain: "BLE", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Target service/characteristic not found"]))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        onValueUpdate?(data)
    }
}
