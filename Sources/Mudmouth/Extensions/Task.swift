//
//  Task.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1_000 * 1_000 * 1_000)
        try await Task.sleep(nanoseconds: delay)
    }

    static func sleep(millisecond duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1_000 * 1_000)
        try await Task.sleep(nanoseconds: delay)
    }

    static func sleep(microseconds duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1_000)
        try await Task.sleep(nanoseconds: delay)
    }
}
