//
//  MudmouthDemoApp.swift
//  MudmouthDemo
//
//  Created by devonly on 2024/05/07.
//

import SwiftUI
import Mudmouth
import OSLog

@main
struct MudmouthDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.colorScheme, .dark)
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            UNUserNotificationCenter.current().delegate = self
            return true
        }
    }
}

extension MudmouthDemoApp.AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse)
        async
    {
        if let bulletToken: String = response.bulletToken,
           let gameWebToken: String = response.gameWebToken,
           let version: String = response.version
        {
            Logger.debug(bulletToken)
            Logger.debug(gameWebToken)
            Logger.debug(version)
        }
    }
}
