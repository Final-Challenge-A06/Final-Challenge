//
//  BLEManager.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import Foundation
import CoreBluetooth

// MARK: - BLE Constants (ganti sesuai LightBlue mu)
enum BLEConst {
    static let service        = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    static let characteristic = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
}

// MARK: - BLEManager (low-level)
final class BLEManager: NSObject {
    private(set) var central: CBCentralManager!
    private(set) var peripheral: CBPeripheral?
    private var targetCharacteristic: CBCharacteristic?

    // Callbacks ke VM
    var onStateChange: ((CBManagerState) -> Void)?
    var onDiscover: ((CBPeripheral, NSNumber) -> Void)?
    var onConnect: ((CBPeripheral) -> Void)?
    var onFail: ((Error?) -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onValueUpdate: ((Data) -> Void)?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: Scan / Connect
    func startScan() {
        guard central.state == .poweredOn else { return }
        central.scanForPeripherals(withServices: nil,
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
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

    // MARK: Read/Write
    func readValue() {
        guard let c = targetCharacteristic else { return }
        peripheral?.readValue(for: c)
    }

    func writeString(_ text: String) {
        guard let c = targetCharacteristic,
              let data = text.data(using: .utf8) else { return }
        peripheral?.writeValue(data, for: c, type: .withResponse)
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onStateChange?(central.state)
        // Auto-resume jika sudah disuruh scan sebelumnya
        if central.state == .poweredOn { /* optional */ }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        onDiscover?(peripheral, RSSI)
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

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { onFail?(error); return }
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([BLEConst.characteristic], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard error == nil else { onFail?(error); return }
        service.characteristics?.forEach { c in
            if c.uuid == BLEConst.characteristic {
                targetCharacteristic = c
                if c.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: c)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        onValueUpdate?(data)
    }
}
