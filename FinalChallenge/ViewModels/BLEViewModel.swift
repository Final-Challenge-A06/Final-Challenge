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
    @Published var connectedName: String = "-"
    @Published var incomingText: String = ""
    @Published var outText: String = ""
    @Published var streakCount: Int = 0
    @Published var lastBalance: Int64 = 0
    
    @Published var amount: Int64 = 0
    @Published var firstMoneyReceived: Bool = false
    @Published var streakManager: StreakManager?
    
    var onShowFindDevice: ((Bool) -> Void)?
    
    private let mgr = BLEManager()
    private var isActionBusy = false
    private var pendingPeripheral: CBPeripheral?
    private let targetKeyword = "Billo"
    private var isReconnectFlow = false
    //    var streakManager: StreakManager?
    private var balanceModel: BalanceModel?
    private var context: ModelContext?
    private let goalVM: GoalViewModel
    private var didBootstrap = false
    
    init(goalVM: GoalViewModel? = nil) {
        self.goalVM = goalVM ?? GoalViewModel()
        setupCallbacks()
        self.streakCount = self.streakManager?.currentStreak ?? 0
    }
    
    // Set context dari View
    func setContext(_ context: ModelContext) {
        guard !didBootstrap else { return }
        didBootstrap = true
        
        self.context = context
        
        if var all = try? context.fetch(FetchDescriptor<BalanceModel>()), !all.isEmpty {
            let first = all.removeFirst()
            // (opsional) merge duplikat kalau ada
            for extra in all { first.balance = max(first.balance, extra.balance); context.delete(extra) }
            balanceModel = first
            lastBalance = first.balance
        } else {
            let m = BalanceModel(balance: 0)
            context.insert(m)
            try? context.save()
            balanceModel = m
            lastBalance = 0
        }
        
        self.streakManager = StreakManager(context: context)
        streakCount = streakManager?.currentStreak ?? 0
        dailyCheck()
    }
    
    private func norm(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: "'", with: "'")
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
            
            self.mgr.stopScan()
            
            if self.isReconnectFlow {
                // Setting modal flow
                self.isReconnectFlow = false // reset flag
                self.state = .connecting // update state
                self.mgr.connect(p) // connect
            } else {
                // Onboarding flow
                self.pendingPeripheral = p
                self.connectedName = name
                self.onShowFindDevice?(true)
            }
            
//            self.mgr.stopScan()
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
    
    func startScan(isReconnect: Bool = false) {
        self.isReconnectFlow = isReconnect
        
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
    
    private func persistBalance() {
        guard let ctx = context, let balanceModel else { return }
        balanceModel.balance = lastBalance
        do {
            try ctx.save()
            print("✅ Saved balance:", lastBalance)
        } catch {
            print("❌ SwiftData save error:", error.localizedDescription)
        }
    }
    
    func restorePersistedBalance() {
        guard let ctx = context else { return }
        if let stored = try? ctx.fetch(FetchDescriptor<BalanceModel>()).first {
            if lastBalance != stored.balance {
                lastBalance = stored.balance
                goalVM.updateLastBalance(lastBalance, context: ctx)
            }
        }
    }
    
    // MARK: - Handle data from device
    func handleIncoming(data: Data) {
        if data.count == MemoryLayout<UInt32>.size {
            let raw = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            let incoming = Int64(UInt32(littleEndian: raw))
            handleIncomingBalance(incoming)
            return
        }

        if let s = String(data: data, encoding: .utf8) {
            incomingText = s
            print("📩 Received text: \(s)")

            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if let numeric = Int64(trimmed) {
                handleIncomingBalance(numeric)
            } else {
                print("⛔️ Text is non-numeric, ignore for balance")
            }
            return
        }

        incomingText = data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private func handleIncomingBalance(_ incoming: Int64) {
        if incoming == 0 && lastBalance > 0 {
            print("⛔️ Ignore boot-zero from device")
            return
        }
        if incoming < lastBalance {
            print("⛔️ Ignore lower reading \(incoming) < \(lastBalance)")
            return
        }

        if incoming > lastBalance {
            let days = goalVM.savingDaysArray
            streakManager?.recordSaving(for: days)
            streakCount = streakManager?.currentStreak ?? 0
        }

        amount = incoming - lastBalance
        lastBalance = incoming           
        persistBalance()
        if let ctx = context {
            goalVM.updateLastBalance(lastBalance, context: ctx)
        }

        print("💰 Updated balance from device:", incoming,
              " (delta:", amount, ")")
    }
    
    // MARK: - Daily check streak
    func dailyCheck() {
        streakManager?.evaluateMissedDay(for: goalVM.savingDaysArray)
        streakCount = streakManager?.currentStreak ?? streakCount
        print("STREAK SEKARANG", streakCount)
        streakCount = streakManager?.currentStreak ?? 0
        print("🔥 STREAK SEKARANG:", streakCount)
    }
    
    // MARK: - Reset progress device
    func sendResetToDevice() {
        outText = "reset"
        mgr.writeString("reset")
        lastBalance = 0
        persistBalance()
        print("🔄 Send reset to device, local balance cleared")
    }
}
