//
//  HTTP.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import NIOCore
import NIOHTTP1

internal enum HTTP {
    class Request {
        let path: String
        let headers: SP3Headers
        var data: Data?

        init(head: HTTPRequestHead) {
            self.path = head.uri
            self.headers = head.dictionaryObject
            self.data = nil
        }

        var body: SP3Headers {
            guard let data: Data = try? data?.gunzipped(),
                let objects: [String: Any] = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                return []
            }
            return objects.compactMap({ object in
                guard let value: String = object.value as? String
                else {
                    return nil
                }
                return .init(key: object.key, value: value)
            })
        }

        func add(_ buffer: ByteBuffer) {
            if data == nil {
                self.data = buffer.data
            } else {
                self.data?.append(contentsOf: buffer.data)
            }
        }
    }
}

extension HTTPRequestHead {
    var dictionaryObject: SP3Headers {
        headers.compactMap({ .init(key: $0.name, value: $0.value) })
    }
}
