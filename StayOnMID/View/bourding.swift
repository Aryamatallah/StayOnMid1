//
//  bourding.swift
//  APP1
//
//  Created by Aryam on 26/02/2026.
//import SwiftUI

import SwiftUI
import UIKit



struct bourding: View {

    private let accent = Color(hex: "575FEB")

    private let titleFontName = "GolosText"
    private let bodyFontName  = "Abel-Regular"

    private let ringOffsetY: CGFloat = -40

    private let iconSizePage1: CGFloat = 140
    private let iconSizePage2: CGFloat = 155

    private let iconOffsetX: CGFloat = 0
    private let iconOffsetY: CGFloat = 60

    private let page1TextExtraDown: CGFloat = 28
    private let page3TextExtraDown: CGFloat = 500

    @State private var page: Int = 0
    @State private var transitionDirection: Edge = .trailing

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
    }

    private var pageTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: transitionDirection).combined(with: .opacity),
            removal: .move(edge: opposite(transitionDirection)).combined(with: .opacity)
        )
    }

    // MARK: Pages

    private var page1: some View {
        pageLayout(
            icon: "pencil.and.list.clipboard",
            iconSize: iconSizePage1,
            title: "Stay on Track.\nStay in Control.",
            subtitle: "Never miss a dose again. Simple reminders made just for you.",
            activeDotIndex: 0,
            isLastPage: false,
            textExtraDown: page1TextExtraDown,
            showSkip: true
        )
    }

    private var page2: some View {
        pageLayout(
            icon: "cross.vial",
            iconSize: iconSizePage2,
            title: "Your health\ndeserves\nconsistency.",
            subtitle: "Small daily actions make a big difference\nover time.",
            activeDotIndex: 1,
            isLastPage: false,
            textExtraDown: 0,
            showSkip: true
        )
    }

    private var page3: some View {
        pageLayout(
            icon: nil,                     // ✅ ما فيه أيقونة
            iconSize: 0,
            title: "Right on time\nClear progress",
            subtitle: "",
            activeDotIndex: 2,
            isLastPage: true,
            textExtraDown: page3TextExtraDown,
            showSkip: false
        )
    }

    // MARK: Layout

    @ViewBuilder
    private func pageLayout(
        icon: String?,
        iconSize: CGFloat,
        title: String,
        subtitle: String,
        activeDotIndex: Int,
        isLastPage: Bool,
        textExtraDown: CGFloat,
        showSkip: Bool
    ) -> some View {

        VStack(spacing: 0) {

            // Skip
            HStack {
                Spacer()
                if showSkip {
                    Button("Skep") {
                        goToLastFromSkip()
                    }
                    .foregroundStyle(.white)
                    .font(customFont(bodyFontName, size: 18))
                    .padding(.top, 18)
                    .padding(.trailing, 22)
                }
            }

            Spacer().frame(height: 30)

            // ✅ فقط إذا مو الصفحة الأخيرة نعرض الدائرة والأيقونة
            if !isLastPage {
                ZStack {
                    Circle()
                        .trim(from: 0.06, to: 0.94)
                        .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(90))
                        .padding(.top, 80)
                        .offset(y: ringOffsetY)

                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: iconSize))
                            .foregroundStyle(accent)
                            .offset(x: iconOffsetX, y: iconOffsetY)
                    }
                }

                Spacer().frame(height: 50)
            }

            // Text
            VStack(alignment: .leading, spacing: 12) {

                Text(title)
                    .font(customFont(titleFontName, size: 40))
                    .foregroundStyle(.white)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(customFont(bodyFontName, size: 17))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, textExtraDown)

            Spacer()

            // Bottom
            ZStack {

                HStack(spacing: 10) {
                    dot(isActive: activeDotIndex == 0)
                    dot(isActive: activeDotIndex == 1)
                    dot(isActive: activeDotIndex == 2)
                }

                HStack {
                    Spacer()
                    if isLastPage {
                        Button {
                            finishOnboarding()
                        } label: {
                            Text("Get start")
                                .font(customFont(bodyFontName, size: 18))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 22)
                                .frame(height: 46)
                                .background(accent)
                                .clipShape(Capsule())
                        }
                    } else {
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
        guard page < 2 else { return }
        transitionDirection = .trailing
        withAnimation(.smooth(duration: 0.45)) {
            page = 2
        }
    }

    private func opposite(_ edge: Edge) -> Edge {
        edge == .trailing ? .leading : .trailing
    }

    private func finishOnboarding() {
        print("Finish onboarding")
    }

    private func dot(isActive: Bool) -> some View {
        Circle()
            .fill(isActive ? Color.white : Color.white.opacity(0.35))
            .frame(width: 7, height: 7)
    }

    private func customFont(_ name: String, size: CGFloat) -> Font {
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        } else {
            return .system(size: size)
        }
    }
}

#Preview {
    bourding()
}
