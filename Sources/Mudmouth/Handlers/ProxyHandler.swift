//
//  ProxyHandler.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import DequeModule
import Foundation
import Gzip
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import OSLog

internal final class ProxyHandler: NotificationHandler, ChannelDuplexHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias InboundOut = HTTPClientRequestPart
    typealias OutboundIn = HTTPClientResponsePart
    typealias OutboundOut = HTTPServerResponsePart

    private let url: URL = .init(unsafeString: "https://api.lp1.av5ja.srv.nintendo.net/api/bullet_tokens")
    private var requests: Deque<HTTP.Request> = []
    private let decoder: JSONDecoder = .init()

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let httpData = unwrapInboundIn(data)
        switch httpData {
        case .head(let head):
            if head.uri == url.path {
                requests.append(.init(head: head))
            }
            context.fireChannelRead(wrapInboundOut(.head(head)))
        case .body(let body):
            context.fireChannelRead(wrapInboundOut(.body(.byteBuffer(body))))
        case .end:
            context.fireChannelRead(wrapInboundOut(.end(nil)))
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let httpData = unwrapOutboundIn(data)
        switch httpData {
        case .head(let head):
            context.write(wrapOutboundOut(.head(head)), promise: promise)
        case .body(let body):
            if let request: HTTP.Request = requests.first {
                request.add(body)
            }
            context.write(wrapOutboundOut(.body(.byteBuffer(body))), promise: promise)
        case .end:
            if let request: HTTP.Request = requests.popFirst() {
                Task(
                    priority: .background,
                    operation: {
                        try await requestNotification(request: request)
                    })
            }
            context.write(wrapOutboundOut(.end(nil)), promise: promise)
        }
    }

    func channelInactive(context: ChannelHandlerContext) {
    }
}
