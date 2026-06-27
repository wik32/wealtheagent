// MockNotificationPort.swift
// Test mock — implements NotificationPort without UNUserNotificationCenter.

import Foundation
@testable import WealthEagent

final class MockNotificationPort: NotificationPort, @unchecked Sendable {
    var scheduledContracts: [UUID] = []
    var cancelledIds: [UUID] = []
    var permissionGranted: Bool = true

    func scheduleExpiryReminder(for contract: Contract) async {
        scheduledContracts.append(contract.id)
    }

    func cancelReminder(for contractId: UUID) async {
        cancelledIds.append(contractId)
    }

    func requestPermission() async -> Bool {
        permissionGranted
    }
}
