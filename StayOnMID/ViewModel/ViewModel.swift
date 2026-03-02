//
//  ViewModel.swift
//  APP1
//
//  Created by Aryam on 26/02/2026.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class ViewModel: ObservableObject {

    let accent = Color(hex: "575FEB")

    @Published var weekOffset: Int = 0
    @Published var selectedDate: Date = Date()

    @Published var meds: [Medication] = []
    @Published var checked: Set<UUID> = []

    @Published var showAddSheet = false
    @Published var now: Date = Date()

    private let saveKey = "SavedMeds"

    init() {
        load()
    }

    // MARK: Calendar

    var weekDays: [Date] {
        let cal = Calendar.current
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let start = cal.date(byAdding: .day, value: weekOffset * 7, to: startOfWeek) ?? startOfWeek

        return (0..<7).compactMap {
            cal.date(byAdding: .day, value: $0, to: start)
        }
    }

    var todaysMeds: [Medication] {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)

        return meds
            .filter {
                Calendar.current.isDate($0.time, inSameDayAs: selectedDate)
                || $0.repeatDays.contains(weekday)
            }
            .sorted { $0.time < $1.time }
    }

    // MARK: Next Dose

    var nextDose: Medication? {
        todaysMeds
            .sorted { $0.time < $1.time }
            .first { $0.time.addingTimeInterval(120) > now }
    }

    var nextDoseRemainingText: String {
        guard let m = nextDose else { return "--:--:--" }

        let diff = Int(m.time.timeIntervalSince(now))

        if diff <= 0 && diff >= -120 {
            return "Now"
        }

        if diff < -120 {
            return "--:--:--"
        }

        return format(diff)
    }

    // MARK: Actions

    func tick(_ date: Date) {
        now = date
    }

    func selectDay(_ date: Date) {
        selectedDate = date
    }

    func tapMedication(_ med: Medication) {
        guard let index = meds.firstIndex(where: { $0.id == med.id }) else { return }

        if meds[index].frequency == 1 {

            if checked.contains(med.id) {
                checked.remove(med.id)
            } else {
                checked.insert(med.id)
            }

            return
        }

        if meds[index].remaining > 1 {
            meds[index].remaining -= 1
        } else {
            meds[index].remaining = 0
            checked.insert(med.id)
        }

        save()
    }

    // 🔥 UPDATED: Add + Schedule Notification
    func addMedication(_ med: Medication) {

        var newMed = med

        let cal = Calendar.current
        if let updatedDate = cal.date(
            bySettingHour: cal.component(.hour, from: med.time),
            minute: cal.component(.minute, from: med.time),
            second: 0,
            of: selectedDate
        ) {
            newMed.time = updatedDate
        }

        meds.append(newMed)

        // 🔔 Schedule Notification
        NotificationManager.shared.scheduleNotification(for: newMed)

        save()
    }

    // 🔥 UPDATED: Delete + Cancel Notification
    func deleteMedication(_ med: Medication) {

        NotificationManager.shared.cancelNotification(for: med)

        meds.removeAll { $0.id == med.id }
        checked.remove(med.id)

        save()
    }

    // ✅ NEW: Update + Reschedule Notification
    func updateMedication(_ updated: Medication) {

        guard let index = meds.firstIndex(where: { $0.id == updated.id }) else { return }

        // ❗️Cancel old notification before updating
        NotificationManager.shared.cancelNotification(for: meds[index])

        meds[index] = updated

        // 🔔 Schedule new notification with updated values
        NotificationManager.shared.scheduleNotification(for: updated)

        save()
    }

    // MARK: Persistence

    private func save() {
        if let encoded = try? JSONEncoder().encode(meds) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Medication].self, from: data)
        else { return }

        meds = decoded
    }

    // MARK: Helpers

    private func format(_ total: Int) -> String {
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%d:%02d:%02d", h, m, s)
    }

    func amPmIcon(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        return hour < 12 ? "sun.max" : "moon"
    }
}
