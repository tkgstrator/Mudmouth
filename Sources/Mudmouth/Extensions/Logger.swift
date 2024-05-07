//
//  Logger.swift
//  Mudmouth
//
//  Created by devonly on 2023/12/30
//  Copyright © 2023 Magi Corporation. All rights reserved.
//

import Foundation
import OSLog

public extension Logger {
    static let level: OSLogType = .info
    static let current: Logger = .init()

    init(label: String) {
        self.init(subsystem: "", category: label)
    }

    static func trace(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .debug, "[TRACE][\(file):\(function):\(line)] \(message)")
    }

    static func debug(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .debug, "[DEBUG][\(file):\(function):\(line)] \(message)")
    }

    static func info(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .info, "[INFO][\(file):\(function):\(line)] \(message)")
    }

    static func notice(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .debug, "[NOTICE][\(file):\(function):\(line)] \(message)")
    }

    static func warning(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .error, "[WARNING][\(file):\(function):\(line)] \(message)")
    }

    static func error(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .error, "[ERROR][\(file):\(function):\(line)] \(message)")
    }

    static func critical(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .fault, "[CRITICAL][\(file):\(function):\(line)] \(message)")
    }

    static func fault(
        _ message: String = "",
        function: String = #function,
        line: Int = #line,
        file: String = #fileID
    ) {
        current.log(level: .fault, "[FAULT][\(file):\(function):\(line)] \(message)")
    }
}
