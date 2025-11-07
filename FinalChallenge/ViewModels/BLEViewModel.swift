//
//  BLEViewModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import Foundation
import CoreBluetooth
import Combine
import SwiftData

enum PairState: Equatable {
    case idle
    case scanning
    case connecting
    case connected
    case failed(String)
}

@MainActor
final class BLEViewModel: ObservableObject {
    @Published var state: PairState = .idle
    //    @Published var devices: [CBPeripheral] = []
    //    @Published var rssiMap: [UUID: NSNumber] = [:]
    @Published var connectedName: String = "-"
    @Published var incomingText: String = ""
    @Published var outText: String = ""
    @Published var streakCount: Int = 0
    @Published var lastBalance: Int64 = 0
    
    var onShowFindDevice: ((Bool) -> Void)?
    
    private let mgr = BLEManager()
    private var isActionBusy = false
    private var pendingPeripheral: CBPeripheral?
    private let targetKeyword = "esp32"
    var streakManager: StreakManager?
    private let goalVM: GoalViewModel
    
    func setContext(_ context: ModelContext) {
        if streakManager == nil { streakManager = StreakManager() }
    }
    
    init(goalVM: GoalViewModel? = nil) {
        self.goalVM = goalVM ?? GoalViewModel()
        setupCallbacks()
        self.streakCount = self.streakManager?.currentStreak ?? 0
        dailyCheck()
    }
    
    private func norm(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private func isRoboo(_ name: String) -> Bool {
        norm(name).contains(norm(targetKeyword))
    }
    
    private enum StoreKey {
        static let lastPeripheralID = "lastPeripheralID"
        static let hasPairedOnce = "hasPairedOnce"
    }
    
    var hasPairedOnce: Bool {
        UserDefaults.standard.bool(forKey: StoreKey.hasPairedOnce)
    }
    
    private func setupCallbacks() {
        mgr.onStateChange = { [weak self] st in
            guard let self else { return }
            if st == .poweredOn, case .idle = self.state {
            }
        }
        
        mgr.onDiscover = { [weak self] p, _, name in
            guard let self else { return }
            guard case .scanning = self.state, !self.isActionBusy else { return }
            guard self.isRoboo(name) else { return }
            guard self.pendingPeripheral == nil else { return }
            
            self.pendingPeripheral = p
            self.connectedName = name
            self.mgr.stopScan()
            self.onShowFindDevice?(true)
        }
        
        mgr.onConnect = { [weak self] p in
            guard let self else { return }
            self.connectedName = p.name ?? self.connectedName
            self.state = .connected
            self.isActionBusy = false
            self.pendingPeripheral = nil
            
            self.saveLastPeripheralID(p.identifier)
            UserDefaults.standard.set(true, forKey: StoreKey.hasPairedOnce)
        }
        
        mgr.onFail = { [weak self] err in
            guard let self else { return }
            self.state = .failed(err?.localizedDescription ?? "Failed")
            self.isActionBusy = false
            self.onShowFindDevice?(false)
            self.pendingPeripheral = nil
        }
        
        mgr.onDisconnect = { [weak self] _ in
            guard let self else { return }
            self.state = .failed("Disconnected")
            self.isActionBusy = false
            self.onShowFindDevice?(false)
            self.pendingPeripheral = nil
        }
        
        mgr.onValueUpdate = { [weak self] data in
            guard let self else { return }
            self.handleIncoming(data: data)
        }
    }
    
    // MARK: - Intent
    func tapSetup() {
        guard let p = pendingPeripheral, !isActionBusy else { return }
        isActionBusy = true
        state = .connecting
        mgr.connect(p)
    }
    
    func startScan() {
        state = .scanning
        isActionBusy = false
        pendingPeripheral = nil
        mgr.startScan()
    }
    
    func stopScan() {
        mgr.stopScan()
        if case .scanning = state { state = .idle }
    }
    
    func disconnect() { mgr.disconnect() }
    
    func read()  { if case .connected = state { mgr.readValue() } }
    
    func write() {
        guard case .connected = state else { return }
        let text = outText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        mgr.writeString(text)
    }
    
    func tryReconnectOnLaunch() {
        if let id = loadLastPeripheralID(),
           let found = mgr.retrievePeripherals(with: [id]).first {
            state = .connecting
            onShowFindDevice?(true)
            mgr.connect(found)
            return
        }
        if let found = mgr.retrieveConnected(with: [BLEConst.service]).first {
            state = .connecting
            onShowFindDevice?(true)
            mgr.connect(found)
            return
        }
        startScan()
    }
    
    private func saveLastPeripheralID(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: StoreKey.lastPeripheralID)
    }
    
    private func loadLastPeripheralID() -> UUID? {
        guard let s = UserDefaults.standard.string(forKey: StoreKey.lastPeripheralID) else { return nil }
        return UUID(uuidString: s)
    }
    
    // MARK: Handle data from device
    private func handleIncoming(data: Data) {
        if data.count == MemoryLayout<UInt32>.size {
            let newBalanceRaw = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            let newBalance = UInt32(littleEndian: newBalanceRaw)
            print("Saldo baru dari device:", newBalance)
            
            if Int64(newBalance) > lastBalance {
                print("Saldo naik dari \(lastBalance) ke \(newBalance) - trigger streak")
                let days = goalVM.savingDaysArray
                streakManager?.recordSaving(for: days)
                streakCount = streakManager?.currentStreak ?? streakCount
            }
            
            lastBalance = Int64(newBalance)
            return
        }
        else {
            if let s = String(data: data, encoding: .utf8) {
                incomingText = s
                print("Received text: \(s)")
            } else {
                incomingText = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            }
        }
    }
    
    // MARK: Function daily check streak
    func dailyCheck() {
        streakManager?.evaluateMissedDay(for: goalVM.savingDaysArray)
        streakCount = streakManager?.currentStreak ?? streakCount
        print("STREAK SEKARANG", streakCount)
    }
}
