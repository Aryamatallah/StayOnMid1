//
//  bourding.swift
//  APP1
//
//  Created by Aryam on 26/02/2026.
//import SwiftUI

import SwiftUI
import UIKit
import UserNotifications

struct bourding: View {

    private let accent = Color(hex: "575FEB")

    private let titleFontName = "GolosText"
    private let bodyFontName  = "Abel-Regular"

    private let ringOffsetY: CGFloat = -40
    private let iconOffsetX: CGFloat = 0
    private let iconOffsetY: CGFloat = 55

    private let iconSizePage1: CGFloat = 140
    private let iconSizePage2: CGFloat = 155
    private let iconSizePage3: CGFloat = 175

    private let page1TextExtraDown: CGFloat = 28
    private let page3TextExtraDown: CGFloat = 85
    private let dotsSpacing: CGFloat = 10

    @State private var page: Int = 0
    @State private var transitionDirection: Edge = .trailing
    @State private var goToMain = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ZStack {
                if page == 0 {
                    page1.transition(pageTransition)
                } else if page == 1 {
                    page2.transition(pageTransition)
                } else {
                    page3.transition(pageTransition)
                }
            }
            .animation(.smooth(duration: 0.45), value: page)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 18)
                    .onEnded { value in
                        let dx = value.translation.width
                        if dx < -70 { goNext(direction: .trailing) }
                        else if dx > 70 { goBack(direction: .leading) }
                    }
            )
        }
        .fullScreenCover(isPresented: $goToMain) {
            Main()
        }
    }

    // MARK: Page Transition
    private var pageTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: transitionDirection).combined(with: .opacity),
            removal: .move(edge: opposite(transitionDirection)).combined(with: .opacity)
        )
    }

    // MARK: Pages

    private var page1: some View {
        standardPage(
            icon: "pencil.and.list.clipboard",
            iconSize: iconSizePage1,
            title: "Stay on Track.\nStay in Control.",
            subtitle: "Never miss a dose again. Simple reminders made just for you.",
            activeDotIndex: 0,
            textExtraDown: page1TextExtraDown,
            showSkip: true
        )
    }

    private var page2: some View {
        standardPage(
            icon: "cross.vial",
            iconSize: iconSizePage2,
            title: "Your health\ndeserves\nconsistency.",
            subtitle: "Small daily actions make a big difference\nover time.",
            activeDotIndex: 1,
            textExtraDown: 0,
            showSkip: true
        )
    }

    private var page3: some View {
        VStack(spacing: 0) {

            HStack { Spacer() }
                .padding(.top, 18)
                .padding(.trailing, 22)

            Spacer().frame(height: 30)

            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.92)
                    .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(90))
                    .padding(.top, 80)
                    .offset(y: ringOffsetY)

                Image(systemName: "clock.badge.fill")
                    .font(.system(size: iconSizePage3))
                    .foregroundStyle(accent)
                    .offset(x: iconOffsetX, y: iconOffsetY)
            }

            Spacer().frame(height: 50)

            VStack(alignment: .leading, spacing: 12) {
                (
                    Text("Right on time\n")
                        .font(customFont(titleFontName, size: 40, weight: .bold))
                    +
                    Text("Clear progress")
                        .font(customFont(titleFontName, size: 40, weight: .regular))
                )
                .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, page3TextExtraDown)

            Spacer()

            ZStack {

                HStack(spacing: dotsSpacing) {
                    dot(isActive: false)
                    dot(isActive: false)
                    dot(isActive: true)
                }

                HStack {
                    Spacer()
                    Button {
                        finishOnboarding()
                    } label: {
                        Text("Get start")
                            .font(customFont(bodyFontName, size: 18, weight: .regular))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 22)
                            .frame(height: 46)
                            .background(accent)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
        }
    }

    // MARK: Shared Page Layout

    private func standardPage(
        icon: String,
        iconSize: CGFloat,
        title: String,
        subtitle: String,
        activeDotIndex: Int,
        textExtraDown: CGFloat,
        showSkip: Bool
    ) -> some View {

        VStack(spacing: 0) {

            HStack {
                Spacer()
                if showSkip {
                    Button("Skip") { goToLastFromSkip() }
                        .foregroundStyle(.white)
                        .font(customFont(bodyFontName, size: 18, weight: .regular))
                        .padding(.top, 18)
                        .padding(.trailing, 22)
                }
            }

            Spacer().frame(height: 30)

            ZStack {
                Circle()
                    .trim(from: 0.06, to: 0.94)
                    .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(90))
                    .padding(.top, 80)
                    .offset(y: ringOffsetY)

                Image(systemName: icon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(accent)
                    .offset(x: iconOffsetX, y: iconOffsetY)
            }

            Spacer().frame(height: 50)

            VStack(alignment: .leading, spacing: 12) {

                Text(title)
                    .font(customFont(titleFontName, size: 40, weight: .regular))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(customFont(bodyFontName, size: 17, weight: .regular))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, textExtraDown)

            Spacer()

            ZStack {
                HStack(spacing: dotsSpacing) {
                    dot(isActive: activeDotIndex == 0)
                    dot(isActive: activeDotIndex == 1)
                    dot(isActive: activeDotIndex == 2)
                }

                HStack {
                    Spacer()
                    Button {
                        goNext(direction: .trailing)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 58, height: 58)
                            .background(accent)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
        }
    }

    // MARK: Navigation

    private func goNext(direction: Edge) {
        guard page < 2 else { return }
        transitionDirection = direction
        page += 1
    }

    private func goBack(direction: Edge) {
        guard page > 0 else { return }
        transitionDirection = direction
        page -= 1
    }

    private func goToLastFromSkip() {
        transitionDirection = .trailing
        page = 2
    }

    private func opposite(_ edge: Edge) -> Edge {
        edge == .trailing ? .leading : .trailing
    }

    // 🔥 FINAL FIX
    private func finishOnboarding() {

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in

            DispatchQueue.main.async {

                // 👇 نحفظ إن المستخدم خلص البوردينق
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

                goToMain = true
            }
        }
    }

    // MARK: UI Helpers

    private func dot(isActive: Bool) -> some View {
        Circle()
            .fill(isActive ? Color.white : Color.white.opacity(0.35))
            .frame(width: 7, height: 7)
    }

    private func customFont(_ name: String, size: CGFloat, weight: UIFont.Weight) -> Font {
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        } else {
            let w: Font.Weight = (weight == .bold) ? .bold : .regular
            return .system(size: size, weight: w)
        }
    }
}

#Preview {
    bourding()
}
