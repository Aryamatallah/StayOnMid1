//
//  NotificationManager.swift
//  StayOnMID
//
//  Created by Aryam on 27/02/2026.
//
import UserNotifications
import Foundation

final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permission
    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {

            case .authorized, .provisional, .ephemeral:
                completion(true)

            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }

            case .denied:
                completion(false)

            @unknown default:
                completion(false)
            }
        }
    }

    // MARK: - Schedule
    func scheduleNotification(for medication: Medication) {

        requestPermissionIfNeeded { granted in
            guard granted else {
                print("❌ Notifications denied/not allowed.")
                return
            }

            let content = UNMutableNotificationContent()

            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: medication.time)
            let minute = calendar.component(.minute, from: medication.time)

            // ✨ رسالة لطيفة حسب الوقت
            if hour < 12 {
                content.title = "Good morning ☀️"
                content.body = "Start your day right. Take your \(medication.name)."
            } else if hour < 18 {
                content.title = "A gentle reminder 🤍"
                content.body = "It’s time for your \(medication.name)."
            } else {
                content.title = "Evening care 🌙"
                content.body = "Before you rest, don’t forget your \(medication.name)."
            }

            content.sound = .default
            content.badge = 1

            content.userInfo = [
                "medID": medication.id.uuidString,
                "medName": medication.name
            ]

            // ✅ بدون تكرار
            if medication.repeatDays.isEmpty {

                var components = calendar.dateComponents([.year, .month, .day], from: medication.time)
                components.hour = hour
                components.minute = minute
                components.second = 0

                // ✅ لو الوقت صار ماضي، خلّه بكرة تلقائي
                if let fireDate = calendar.date(from: components), fireDate <= Date(),
                   let tomorrow = calendar.date(byAdding: .day, value: 1, to: fireDate) {

                    components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
                    components.hour = hour
                    components.minute = minute
                    components.second = 0
                }

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                let request = UNNotificationRequest(
                    identifier: medication.id.uuidString,
                    content: content,
                    trigger: trigger
                )

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Add notification error:", error.localizedDescription)
                    } else {
                        print("✅ Scheduled one-time:", components)
                    }
                }

            } else {

                // ✅ مع تكرار
                for day in medication.repeatDays {

                    var components = DateComponents()
                    components.weekday = day
                    components.hour = hour
                    components.minute = minute
                    components.second = 0

                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                    let request = UNNotificationRequest(
                        identifier: "\(medication.id.uuidString)-\(day)",
                        content: content,
                        trigger: trigger
                    )

                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("❌ Repeat add error:", error.localizedDescription)
                        } else {
                            print("✅ Scheduled weekly weekday=\(day) \(hour):\(minute)")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cancel
    func cancelNotification(for medication: Medication) {

        var identifiers: [String] = []

        if medication.repeatDays.isEmpty {
            identifiers.append(medication.id.uuidString)
        } else {
            for day in medication.repeatDays {
                identifiers.append("\(medication.id.uuidString)-\(day)")
            }
        }

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)

        print("🗑️ Cancelled:", identifiers)
    }

    // (اختياري) للتأكد بسرعة وش فيه إشعارات مجدولة
    func debugPrintPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            print("📌 Pending count:", reqs.count)
            reqs.forEach { print("➡️", $0.identifier, String(describing: $0.trigger)) }
        }
    }
}
