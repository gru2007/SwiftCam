//
//  SwiftCamApp.swift
//  SwiftCam
//
//  Created by Руслан Артемьев on 19.06.2025.
//

import SwiftUI
import MijickCamera

@main
struct SwiftCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Делегат приложения для блокировки ориентации камеры
final class AppDelegate: NSObject, UIApplicationDelegate, MApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.orientationLock
    }
}
