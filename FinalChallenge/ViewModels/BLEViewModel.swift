//
//  BLEViewModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import Foundation
import CoreBluetooth
import Combine

enum PairState { case idle, scanning, list, connecting, connected, failed(String) }

@MainActor
final class BLEViewModel: ObservableObject {
    @Published var state: PairState = .idle
    @Published var devices: [CBPeripheral] = []
    @Published var rssiMap: [UUID: NSNumber] = [:]
    @Published var connectedName: String = "-"
    @Published var incomingText: String = ""
    @Published var outText: String = ""
    @Published var streakCount: Int = 0

    private let mgr = BLEManager()
    private let streakManager = StreakManager()
    private let goalVM: GoalViewModel
    private var lastBalance: Int64 = 0

    init(goalVM: GoalViewModel? = nil) {
        self.goalVM = goalVM ?? GoalViewModel()
        setupCallbacks()
        streakCount = streakManager.currentStreak
        dailyCheck()
    }

    private func setupCallbacks() {
        mgr.onStateChange = { [weak self] s in
            guard let self else { return }
            if s == .poweredOn, case .scanning = self.state { self.mgr.startScan() }
        }

        mgr.onDiscover = { [weak self] p, rssi in
            guard let self else { return }
            if !self.devices.contains(where: { $0.identifier == p.identifier }) {
                self.devices.append(p)
            }
            self.rssiMap[p.identifier] = rssi
            self.state = .list
        }

        mgr.onConnect = { [weak self] p in
            guard let self else { return }
            self.connectedName = p.name ?? "Unknown"
            self.state = .connected
        }

        mgr.onFail = { [weak self] err in
            self?.state = .failed(err?.localizedDescription ?? "Failed")
        }

        mgr.onDisconnect = { [weak self] _ in
            self?.state = .failed("Disconnected")
        }

        mgr.onValueUpdate = { [weak self] data in
            self?.handleIncoming(data: data)
        }
    }

    // MARK: Handle data from device
    private func handleIncoming(data: Data) {
        if data.count == MemoryLayout<UInt32>.size {
            let newBalanceRaw = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            let newBalance = UInt32(littleEndian: newBalanceRaw)
            print("Saldo baru dari device:", newBalance)
            
            if Int64(newBalance) > lastBalance {
                print("Saldo naik dari \(lastBalance) ke \(newBalance) - trigger streak")
                let days = self.goalVM.savingDaysArray
                self.streakManager.recordSaving(for: days)
                DispatchQueue.main.async {
                    self.streakCount = self.streakManager.currentStreak
                }
            }
            
            lastBalance = Int64(newBalance)
            return
        }
        if let s = String(data: data, encoding: .utf8), !s.isEmpty {
            self.incomingText = s
            print("Notified UTF8:", s)
        } else {
            let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            self.incomingText = hex
            print("Notified HEX:", hex)
        }
    }

    // MARK: - Intent
    func startScan() {
        devices.removeAll()
        state = .scanning
        mgr.startScan()
        print("📡 Start scanning...")
    }

    func stopScan() { mgr.stopScan(); if case .scanning = state { state = .idle } }

    func connect(_ p: CBPeripheral) { state = .connecting; mgr.stopScan(); mgr.connect(p) }

    func disconnect() { mgr.disconnect() }

    func read() { mgr.readValue() }

    func write() {
        let text = outText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        mgr.writeString(text)
    }
    
    // MARK: Function daily check streak
    func dailyCheck() {
        streakManager.evaluateMissedDay(for: goalVM.savingDaysArray)
        streakCount = streakManager.currentStreak
        print("STREAK SEKARANG", streakCount)
    }
}

