//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by devonly on 2024/03/30.
//

import CryptoKit
import Foundation
import Mudmouth
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import NetworkExtension
import OSLog

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        // swiftlint:disable:next force_unwrapping
        let url: URL = .init(string: "https://api.lp1.av5ja.srv.nintendo.net/api/bullet_tokens")!
        let proxySettings: NEProxySettings = .init()
        proxySettings.httpsServer = NEProxyServer(address: "127.0.0.1", port: 6_836)
        proxySettings.httpsEnabled = true
        proxySettings.matchDomains = [url.host!]
        let ipv4Settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.255.0"])
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        networkSettings.mtu = 1_500
        networkSettings.proxySettings = proxySettings
        networkSettings.ipv4Settings = ipv4Settings
        try await setTunnelNetworkSettings(networkSettings)
        let decoder: JSONDecoder = .init()
        guard let options: [String: NSObject] = options,
            let data: Data = options[NEVPNConnectionStartOptionPassword] as? Data
        else { return }
        let configuration: Configuration = try decoder.decode(Configuration.self, from: data)
        try await startMITMServer(configuration: configuration)
    }
}
