//
//  Sheet.swift
//  StayOnMID
//
//  Created by Aryam on 26/02/2026.
//

import SwiftUI

struct Sheet: View {

    let accent: Color
    var onSave: (Medication) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @FocusState private var focusName: Bool

    @State private var time: Date = Date()
    @State private var frequency: Int = 1
    @State private var repeatDays: Set<Int> = []

    private let days: [(Int, String)] = [
        (1,"S"), (2,"M"), (3,"T"),
        (4,"W"), (5,"T"), (6,"F"), (7,"S")
    ]

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Add Medication")
                .font(.custom("GolosText", size: 22))
                .bold()
                .foregroundColor(.white)
                .padding(.top, 10)

            // MARK: Name
            VStack(alignment: .leading, spacing: 6) {

                Text("Medication Name")
                    .font(.custom("Abel-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.85))

                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 50)
                    .overlay(
                        TextField("Name", text: $name)
                            .font(.custom("GolosText", size: 17))
                            .foregroundColor(.white)
                            .tint(.white)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .focused($focusName)
                            .padding(.horizontal, 14)
                    )
            }

            // MARK: Frequency + Time
            HStack(spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {

                    Text("Frequency")
                        .font(.custom("Abel-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.85))

                    HStack(spacing: 10) {
                        freqChip("1x", 1)
                        freqChip("2x", 2)
                        freqChip("3x", 3)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {

                    Text("Time")
                        .font(.custom("Abel-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.85))

                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    )
                }
            }

            // MARK: Repeat
            VStack(alignment: .leading, spacing: 8) {

                Text("Repeat (optional)")
                    .font(.custom("Abel-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.85))

                HStack(spacing: 10) {
                    ForEach(days, id: \.0) { d in
                        dayChip(d.1, d.0)
                    }
                }
            }

            Spacer()

            // MARK: ADD
            HStack {
                Spacer()

                Button {

                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

                    let med = Medication(
                        name: trimmed,
                        time: time,
                        frequency: frequency,
                        repeatDays: Array(repeatDays).sorted()
                    )

                    onSave(med)
                    dismiss()

                } label: {
                    Text("ADD")
                        .font(.custom("GolosText", size: 17))
                        .foregroundColor(.white)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(addEnabled ? accent : Color.gray.opacity(0.35))
                        )
                }
                .disabled(!addEnabled)

                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "0B0A16"),
                    Color(hex: "141446")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            focusName = true

            // يخلي time menu داكن
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .first?
                .overrideUserInterfaceStyle = .dark
        }
        .onTapGesture {
            focusName = false
        }
    }

    // MARK: Helpers

    private var addEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func freqChip(_ title: String, _ value: Int) -> some View {
        let selected = (frequency == value)

        return Text(title)
            .font(.custom("GolosText", size: 15))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selected ? accent.opacity(0.6) : Color.white.opacity(0.08))
            )
            .onTapGesture {
                frequency = value
            }
    }

    private func dayChip(_ title: String, _ day: Int) -> some View {

        let selected = repeatDays.contains(day)

        return Text(title)
            .font(.custom("GolosText", size: 14))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(selected ? accent.opacity(0.6) : Color.white.opacity(0.08))
            )
            .onTapGesture {
                if selected {
                    repeatDays.remove(day)
                } else {
                    repeatDays.insert(day)
                }
            }
    }
}
