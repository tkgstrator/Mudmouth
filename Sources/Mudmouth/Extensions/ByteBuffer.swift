//
//  ByteBuffer.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import NIOCore
import NIOHTTP1

extension ByteBuffer {
    var data: Data {
        // swiftlint:disable:next force_unwrapping
        .init(buffer: getBytes(at: readerIndex, length: readableBytes)!)
    }

    var buffer: [UInt8] {
        // swiftlint:disable:next force_unwrapping
        getBytes(at: readerIndex, length: readableBytes)!
    }
}
