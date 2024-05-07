//
//  UNNotificationResponse.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationResponse {
    var headers: SP3Headers {
        guard let headers: String = notification.request.content.userInfo["headers"] as? String,
            let data = Data(base64Encoded: headers)
        else {
            return []
        }
        let decoder: JSONDecoder = .init()
        // swiftlint:disable:next force_try force_unwrapping
        return try! decoder.decode(SP3Headers.self, from: data)
    }

    var body: SP3Headers {
        guard let body: String = notification.request.content.userInfo["body"] as? String,
            let data = Data(base64Encoded: body)
        else {
            return []
        }
        let decoder: JSONDecoder = .init()
        // swiftlint:disable:next force_try force_unwrapping
        return try! decoder.decode(SP3Headers.self, from: data)
    }
    
    public var bulletToken: String? {
        body.bulletToken
    }
    
    public var gameWebToken: String? {
        headers.gameWebToken
    }
    
    public var version: String? {
        headers.version
    }
}
