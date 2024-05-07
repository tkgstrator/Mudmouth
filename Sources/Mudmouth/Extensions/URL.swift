//
//  URL.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation

extension URL {
    init(unsafeString: String) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: unsafeString)!
    }
}
