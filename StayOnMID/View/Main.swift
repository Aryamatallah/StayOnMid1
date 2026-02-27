//
//  Main.swift
//  APP1
//
//  Created by Aryam on 26/02/2026.
//
import SwiftUI
import Combine

struct Main: View {

    @StateObject private var vm = ViewModel()
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {

        let todayStart = Calendar.current.startOfDay(for: Date())
        let selectedStart = Calendar.current.startOfDay(for: vm.selectedDate)
        let isPast = selectedStart < todayStart

        return ZStack {

            background

            VStack(spacing: 18) {

                calendarCard

                VStack(alignment: .leading, spacing: 10) {
                    Text("Next Dose")
                        .font(.custom("GolosText", size: 22))
                        .bold()
                        .foregroundStyle(.white)

                    nextDoseCard
                }
                .padding(.horizontal, 18)

                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        Text("Today's Medications List")
                            .font(.custom("GolosText", size: 22))
                            .bold()
                            .foregroundStyle(.white)

                        Spacer()

                        Button {
                            if !isPast {
                                vm.showAddSheet = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundStyle(isPast ? .gray : vm.accent)
                        }
                        .disabled(isPast)
                    }

                    medsCard(isPast: isPast)
                }
                .padding(.horizontal, 18)

                Spacer()
            }
            .padding(.top, 14)
        }
        .onReceive(ticker) { vm.tick($0) }

        .sheet(isPresented: $vm.showAddSheet) {
            Sheet(accent: vm.accent) {
                vm.addMedication($0)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private var background: some View {
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
    }

    private var calendarCard: some View {
        VStack(spacing: 10) {

            HStack {
                Text(monthTitle(vm.weekDays.first ?? Date()))
                    .font(.custom("GolosText", size: 18))
                    .foregroundStyle(.white)

                Spacer()

                Button { vm.weekOffset -= 1 } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(vm.accent)
                }

                Button { vm.weekOffset += 1 } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(vm.accent)
                }
            }

            HStack(spacing: 18) {
                ForEach(vm.weekDays, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
    }

    private func dayCell(_ date: Date) -> some View {

        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isSelected = cal.isDate(date, inSameDayAs: vm.selectedDate)

        return VStack(spacing: 6) {

            Text(weekdayShort(date))
                .font(.custom("Abel-Regular", size: 12))
                .foregroundStyle(.white.opacity(0.6))

            Text(dayNumber(date))
                .font(.custom("Abel-Regular", size: 15))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(isToday ? vm.accent : .clear)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected && !isToday ? vm.accent : .clear, lineWidth: 1.5)
                )
        }
        .onTapGesture {
            vm.selectDay(date)
        }
    }

    private var nextDoseCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08))
                )

            HStack {

                Text(vm.nextDose?.name ?? "—")
                    .font(.custom("GolosText", size: 20))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "clock")
                    .foregroundStyle(.white.opacity(0.7))

                Text(vm.nextDoseRemainingText)
                    .font(.custom("Abel-Regular", size: 18))
                    .foregroundStyle(
                        vm.nextDoseRemainingText == "Now"
                        ? vm.accent
                        : .white
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(height: 75)
    }

    private func medsCard(isPast: Bool) -> some View {

        let todayStart = Calendar.current.startOfDay(for: Date())
        let selectedStart = Calendar.current.startOfDay(for: vm.selectedDate)
        let isToday = selectedStart == todayStart
        let isFuture = selectedStart > todayStart

        return ZStack {

            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(vm.accent.opacity(0.35), lineWidth: 1)
                )

            if vm.todaysMeds.isEmpty {

                VStack(spacing: 12) {

                    Image(systemName: "pills")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.4))

                    if isToday {
                        Text("No medications for today")
                            .font(.custom("GolosText", size: 16))
                            .foregroundStyle(.white.opacity(0.75))

                        Text("Tap + to add your first medication")
                            .font(.custom("Abel-Regular", size: 14))
                            .foregroundStyle(vm.accent.opacity(0.9))

                    } else if isFuture {
                        Text("No medications scheduled")
                            .font(.custom("GolosText", size: 16))
                            .foregroundStyle(.white.opacity(0.75))

                    } else {
                        Text("No medications")
                            .font(.custom("GolosText", size: 16))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

            } else {

                List {
                    ForEach(vm.todaysMeds) { med in
                        medRow(med, isPast: isPast)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if !isPast {
                                    Button {
                                        vm.deleteMedication(med)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red.opacity(0.8))
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .frame(minHeight: 220)
    }

    private func medRow(_ med: Medication, isPast: Bool) -> some View {

        let isDone = vm.checked.contains(med.id)

        return HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(isDone ? vm.accent.opacity(0.3) : .clear)
                    .overlay(
                        Circle()
                            .stroke(isPast ? Color.gray : vm.accent, lineWidth: 1.5)
                    )
                    .frame(width: 32, height: 32)

                if med.frequency == 1 {
                    if isDone {
                        Image(systemName: "checkmark")
                            .foregroundStyle(isPast ? .gray : vm.accent)
                    }
                } else {
                    if isDone {
                        Image(systemName: "checkmark")
                            .foregroundStyle(isPast ? .gray : vm.accent)
                    } else {
                        Text("\(med.remaining)")
                            .foregroundStyle(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }

            Text(med.name)
                .font(.custom("GolosText", size: 16))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: vm.amPmIcon(for: med.time))
                .foregroundStyle(.white.opacity(0.7))

            Text(timeString(med.time))
                .font(.custom("Abel-Regular", size: 16))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            if isPast { return }
            vm.tapMedication(med)
        }
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: date)
    }

    private func weekdayShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

#Preview {
    Main()
}
