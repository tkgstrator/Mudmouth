//
//  RequestManager.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import DequeModule
import Foundation
import NetworkExtension
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import OSLog
import SwiftUI
import UserNotifications

internal final class RequestManager: CertificateManager {
    // swiftlint:disable:next force_unwrapping
    private let bundleIdentifier: String = "\(Bundle.main.bundleIdentifier!).packetTunnel"
    
    override init() {
        super.init()
    }
    
    @MainActor
    func saveToPreferences() async throws {
        let granted: Bool = try await requestAuthorization()
        if !granted {
            throw MMError.NotGranted
        }
        let manager: NETunnelProviderManager = .init()
        manager.localizedDescription = "@Salmonia3JP"
        let proto: NETunnelProviderProtocol = .init()
        proto.providerBundleIdentifier = bundleIdentifier
        proto.serverAddress = "Salmonia3"
        manager.protocolConfiguration = proto
        manager.isEnabled = true
        // 被っているものがあればコピーしない
        let managers: [NETunnelProviderManager] = try await NETunnelProviderManager.loadAllFromPreferences()
        if !managers.contains(where: { $0.protocolConfiguration?.serverAddress == "Salmonia3" }) {
            try await manager.saveToPreferences()
        }
    }

    @MainActor
    func loadAllFromPreferences() async throws -> NETunnelProviderManager? {
        try await NETunnelProviderManager.loadAllFromPreferences().first
    }

    /// VPNサーバー起動
    /// - Parameters:
    ///   - provider: <#provider description#>
    ///   - configuration: <#configuration description#>
    ///   - completion: <#completion description#>
    @MainActor
    func startVPNTunnel() async throws {
        guard let provider: NETunnelProviderManager = try await loadAllFromPreferences()
        else {
            try await saveToPreferences()
            return
        }
        let encoder: JSONEncoder = .init()
        provider.isEnabled = true
        try await provider.saveToPreferences()
        let data: Data = try encoder.encode(configuration.generate())
        try provider.connection.startVPNTunnel(options: [
            NEVPNConnectionStartOptionPassword: data as NSObject
        ])
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        await UIApplication.shared.open(.init(unsafeString: "com.nintendo.znca://znca/game/4834290508791808"))
    }

    /// VPNサーバー停止
    @MainActor
    func stopVPNTunnel() async throws {
        guard let provider: NETunnelProviderManager = try await loadAllFromPreferences()
        else {
            throw MMError.NotFound
        }
        provider.connection.stopVPNTunnel()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
    }
}
