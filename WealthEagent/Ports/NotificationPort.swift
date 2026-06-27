// NotificationPort.swift
// Ports — Swift protocol. Imports Domain + Foundation only.

import Foundation

protocol NotificationPort: Sendable {
    func scheduleExpiryReminder(for contract: Contract) async
    func cancelReminder(for contractId: UUID) async
    func requestPermission() async -> Bool
}
