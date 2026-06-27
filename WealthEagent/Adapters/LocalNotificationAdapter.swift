// LocalNotificationAdapter.swift
// Adapters — UNUserNotificationCenter implementation of NotificationPort.
// Schedules local reminders 30 days before contract end date.

import Foundation
import UserNotifications

final class LocalNotificationAdapter: NotificationPort {

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func scheduleExpiryReminder(for contract: Contract) async {
        guard let endDate = contract.endDate else { return }
        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -30, to: endDate),
              reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Vertrag läuft bald aus"
        content.body = "\(contract.provider) endet am \(formatted(endDate)). Prüfe ob eine Verlängerung sinnvoll ist."
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationId(for: contract.id),
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for contractId: UUID) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationId(for: contractId)])
    }

    private func notificationId(for contractId: UUID) -> String {
        "expiry_\(contractId.uuidString)"
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}
