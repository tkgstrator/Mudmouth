//
//  Data.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation

extension Data {
    init(buffer: [UInt8]) {
        var tmp: [UInt8] = buffer
        // swiftlint:disable:next legacy_objc_type
        self.init(referencing: NSData(bytes: &tmp, length: tmp.count))
    }

    var bytes: [UInt8] {
        [UInt8](self)
    }

    var hexString: String {
        map({ String(format: "%02X", $0) }).joined()
    }
}
