//
//  MITMServer.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import CryptoKit
import DequeModule
import Foundation
import KeychainAccess
import NetworkExtension
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import OSLog

public func startMITMServer(configuration: Configuration) async throws {
    // Process packets in the tunnel.
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    return try await withCheckedThrowingContinuation({ continuation in
        ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandlers(
                    [
                        ByteToMessageHandler(HTTPRequestDecoder(leftOverBytesStrategy: .forwardBytes)),
                        HTTPResponseEncoder(),
                        ConnectHandler(),
                        NIOSSLServerHandler(context: configuration.context),
                        ByteToMessageHandler(HTTPRequestDecoder(leftOverBytesStrategy: .forwardBytes)),
                        HTTPResponseEncoder(),
                        ProxyHandler()
                    ], position: .last)
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .bind(host: "127.0.0.1", port: 6_836)
            .whenComplete { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let failure):
                    Logger.error(failure.localizedDescription)
                    continuation.resume(throwing: failure)
                }
            }
    })
}
