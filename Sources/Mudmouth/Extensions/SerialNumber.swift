//
//  SerialNumber.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import X509

extension Certificate.SerialNumber {
    static var `default`: Certificate.SerialNumber {
        .init()
    }
}
