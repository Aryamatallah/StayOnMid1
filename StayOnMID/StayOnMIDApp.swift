//
//  Untitled.swift
//  StayOnMID
//
//  Created by Aryam on 26/02/2026.
//
import SwiftUI

@main
struct StayOnMIDApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
