//
//  MedicationDetailView.swift
//  StayOnMID
//
//  Created by Aryam on 27/02/2026.
//
import SwiftUI

struct MedicationDetailView: View {

    let med: Medication
    @ObservedObject var vm: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false

    @State private var tempName: String = ""
    @State private var tempTime: Date = .now
    @State private var tempFrequency: Int = 1
    @State private var tempRepeatDays: Set<Int> = []

    // 🔥 Hide edit/delete if selected date is in the past
    private var isPastDate: Bool {
        let cal = Calendar.current
        let selected = cal.startOfDay(for: vm.selectedDate)
        let today = cal.startOfDay(for: Date())
        return selected < today
    }

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color.black,
                    Color(hex: "0D0B1C"),
                    Color(hex: "120F2A"),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 130, height: 130)

                    Image(systemName: "pills.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.85))
                }

                Text(med.name)
                    .font(.custom("GolosText", size: 30))
                    .bold()
                    .foregroundStyle(.white)

                VStack(spacing: 18) {

                    detailRow(icon: "clock.fill",
                              title: "Time",
                              value: formattedTime)

                    detailRow(icon: "repeat",
                              title: "Frequency",
                              value: "\(med.frequency)x per day")

                    detailRow(icon: "calendar",
                              title: "Repeat",
                              value: med.repeatDays.isEmpty ? "—" : formattedRepeatDays)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 50)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            if !isPastDate {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        prefill()
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }

        .alert("Delete Medication?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                vm.deleteMedication(med)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }

        .sheet(isPresented: $showEditSheet) {
            EditMedicationSheet(
                vm: vm,
                original: med,
                name: $tempName,
                time: $tempTime,
                frequency: $tempFrequency,
                repeatDays: $tempRepeatDays
            )
        }
    }

    private func prefill() {
        tempName = med.name
        tempTime = med.time
        tempFrequency = med.frequency
        tempRepeatDays = Set(med.repeatDays)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {

            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Abel-Regular", size: 14))
                    .foregroundStyle(.white.opacity(0.6))

                Text(value)
                    .font(.custom("GolosText", size: 18))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08))
        )
        .cornerRadius(18)
    }

    private var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: med.time)
    }

    private var formattedRepeatDays: String {
        let formatter = DateFormatter()
        let symbols = formatter.shortWeekdaySymbols ?? []
        return med.repeatDays.sorted().compactMap {
            let index = $0 - 1
            return index >= 0 && index < symbols.count ? symbols[index] : nil
        }.joined(separator: ", ")
    }
}

// MARK: - Edit Sheet

private struct EditMedicationSheet: View {

    @ObservedObject var vm: ViewModel
    let original: Medication

    @Binding var name: String
    @Binding var time: Date
    @Binding var frequency: Int
    @Binding var repeatDays: Set<Int>

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(hex: "0D0B1C"),
                        Color(hex: "120F2A"),
                        .black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {

                    // NAME FIELD
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.custom("Abel-Regular", size: 14))
                            .foregroundStyle(.white.opacity(0.6))

                        TextField("Medication name", text: $name)
                            .font(.custom("GolosText", size: 18))
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.1))
                            )
                            .cornerRadius(14)
                    }

                    // TIME
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time")
                            .font(.custom("Abel-Regular", size: 14))
                            .foregroundStyle(.white.opacity(0.6))

                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(vm.accent)
                    }

                    // FREQUENCY CIRCLES
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Frequency")
                            .font(.custom("Abel-Regular", size: 14))
                            .foregroundStyle(.white.opacity(0.6))

                        HStack(spacing: 14) {
                            ForEach(1...6, id: \.self) { number in
                                CircleOption(
                                    title: "\(number)",
                                    isSelected: frequency == number,
                                    accent: vm.accent
                                ) {
                                    frequency = number
                                }
                            }
                        }
                    }

                    // REPEAT DAYS CIRCLES
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Repeat Days")
                            .font(.custom("Abel-Regular", size: 14))
                            .foregroundStyle(.white.opacity(0.6))

                        HStack(spacing: 10) {
                            ForEach(1...7, id: \.self) { day in
                                CircleOption(
                                    title: shortName(day),
                                    isSelected: repeatDays.contains(day),
                                    accent: vm.accent
                                ) {
                                    if repeatDays.contains(day) {
                                        repeatDays.remove(day)
                                    } else {
                                        repeatDays.insert(day)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        var updated = original
        updated.name = name
        updated.time = time
        updated.frequency = frequency
        updated.repeatDays = repeatDays.sorted()
        vm.updateMedication(updated)
        dismiss()
    }

    private func shortName(_ day: Int) -> String {
        let formatter = DateFormatter()
        let symbols = formatter.shortWeekdaySymbols ?? []
        let index = day - 1
        return index >= 0 && index < symbols.count ? symbols[index] : ""
    }
}

private struct CircleOption: View {

    let title: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? accent : Color.white.opacity(0.08))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(isSelected ? 0 : 0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
