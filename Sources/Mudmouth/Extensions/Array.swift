//
//  Array.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation

extension Array where Element == UInt8 {
    var hexString: String {
        map({ String(format: "%02X", $0) }).joined()
    }

    var data: Data {
        .init(buffer: self)
    }
}
