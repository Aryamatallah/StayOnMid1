//
//  Splash.swift
//  StayOnMID
//
//  Created by Aryam on 26/02/2026.
//
import SwiftUI



struct SplashView: View {

    @State private var logoOpacity: Double = 0
    @State private var circleScale: CGFloat = 0.7
    @State private var circleOpacity: Double = 0
    @State private var goToOnboarding = false

    // ✅ نفس لون الثيم
    private let accent = Color(hex: "575FEB")

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // ✅ الدائرة بنفس لون الثيم
            Ellipse()
                .stroke(accent, lineWidth: 2)
                .scaleEffect(circleScale)
                .opacity(circleOpacity)

            Image("Splash")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .opacity(logoOpacity)
        }
        .onAppear {

            // المرحلة 1: تظهر وتكبر
            circleOpacity = 1
            withAnimation(.easeOut(duration: 1.2)) {
                circleScale = 1.6
            }

            withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                logoOpacity = 1
            }

            // المرحلة 2: تختفي بعد ما تكبر
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeIn(duration: 0.6)) {
                    circleOpacity = 0
                }
            }

            // الانتقال للـ Onboarding
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                goToOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $goToOnboarding) {
            bourding()
        }
    }
}
