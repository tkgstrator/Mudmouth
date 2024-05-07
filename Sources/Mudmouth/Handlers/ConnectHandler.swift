//
//  ConnectHandler.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import DequeModule
import Foundation
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import OSLog

internal final class ConnectHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private enum State {
        case idle
        case awaitingEnd
        case established
    }

    private var state: State = .idle
    private var host: String?
    private var port: Int?

    // swiftlint:disable:next function_body_length
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        switch state {
        case .idle:
            let httpData = unwrapInboundIn(data)
            guard case .head(let head) = httpData else {
                return
            }
            guard head.method == .CONNECT else {
                // Send 405 to downstream.
                let headers = HTTPHeaders([("Content-Length", "0")])
                let head = HTTPResponseHead(
                    version: .init(major: 1, minor: 1), status: .methodNotAllowed, headers: headers)
                context.write(self.wrapOutboundOut(.head(head)), promise: nil)
                context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                return
            }
            let components = head.uri.split(separator: ":")
            host = String(components[0])
            // swiftlint:disable:next force_unwrapping
            port = Int(components[1])!
            state = .awaitingEnd
        case .awaitingEnd:
            let httpData = unwrapInboundIn(data)
            if case .end = httpData {
                // Upgrade to TLS server.
                // swiftlint:disable:next closure_body_length
                context.pipeline.context(handlerType: ByteToMessageHandler<HTTPRequestDecoder>.self)
                    // swiftlint:disable:next closure_body_length
                    .whenSuccess { handler in
                        context.pipeline.removeHandler(context: handler, promise: nil)
                        ClientBootstrap(group: context.eventLoop)
                            .channelInitializer { channel in
                                let clientConfiguration = TLSConfiguration.makeClientConfiguration()
                                // swiftlint:disable:next force_try
                                let sslClientContext = try! NIOSSLContext(configuration: clientConfiguration)
                                return channel.pipeline.addHandler(
                                    // swiftlint:disable:next force_unwrapping force_try
                                    try! NIOSSLClientHandler(context: sslClientContext, serverHostname: self.host!)
                                )
                                .flatMap { _ in
                                    channel.pipeline.addHandler(HTTPRequestEncoder())
                                }
                                .flatMap { _ in
                                    channel.pipeline.addHandler(
                                        ByteToMessageHandler(HTTPResponseDecoder(leftOverBytesStrategy: .forwardBytes)))
                                }
                            }
                            // swiftlint:disable:next force_unwrapping
                            .connect(host: self.host!, port: self.port!)
                            .whenComplete { result in
                                switch result {
                                case .success(let client):
                                    // Send 200 to downstream.
                                    let headers = HTTPHeaders([("Content-Length", "0")])
                                    let head = HTTPResponseHead(
                                        version: .init(major: 1, minor: 1), status: .ok, headers: headers)
                                    context.write(self.wrapOutboundOut(.head(head)), promise: nil)
                                    context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                                    context.pipeline.context(handlerType: HTTPResponseEncoder.self).whenSuccess { handler in
                                        context.pipeline.removeHandler(context: handler, promise: nil)
                                        let (localGlue, remoteGlue) = GlueHandler.matchedPair()
                                        context.pipeline.addHandler(localGlue)
                                            .and(client.pipeline.addHandler(remoteGlue))
                                            .whenComplete { result in
                                                switch result {
                                                case .success:
                                                    self.state = .established
                                                case .failure(let failure):
                                                    Logger.error(failure.localizedDescription)
                                                    context.close(promise: nil)
                                                }
                                            }
                                    }
                                case .failure(let failure):
                                    Logger.error(failure.localizedDescription)
                                    // Send 404 to downstream.
                                    let headers = HTTPHeaders([("Content-Length", "0")])
                                    let head = HTTPResponseHead(
                                        version: .init(major: 1, minor: 1), status: .notFound, headers: headers)
                                    context.write(self.wrapOutboundOut(.head(head)), promise: nil)
                                    context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                                }
                            }
                    }
            }
        case .established:
            // Forward data to the next channel.
            context.fireChannelRead(data)
        }
    }
}
