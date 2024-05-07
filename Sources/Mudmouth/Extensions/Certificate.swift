//
//  Certificate.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import CryptoKit
import Foundation
import X509

public extension Certificate {
    var derRepresentation: Data {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes.data
    }

    var pemRepresentation: String {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().pemString
    }

    ///
    var derBytes: [UInt8] {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes
    }

    func verify(privateKey key: Certificate.PrivateKey) -> Bool {
        key.publicKey == publicKey
    }

    func verify(publicKey key: Certificate.PublicKey) -> Bool {
        key == publicKey
    }
}

public extension Certificate.PrivateKey {
    var pemRepresentation: String {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().pemString
    }

    var derBytes: [UInt8] {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes
    }

    var derRepresentation: Data {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes.data
    }

    static var `default`: Certificate.PrivateKey {
        .init(P256.Signing.PrivateKey())
    }

    init(pemRepresentation: String) throws {
        self.init(try P256.Signing.PrivateKey(pemRepresentation: pemRepresentation))
    }
}

public extension Certificate.PublicKey {
    var pemRepresentation: String {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().pemString
    }

    var derBytes: [UInt8] {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes
    }

    var derRepresentation: Data {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes.data
    }
}
