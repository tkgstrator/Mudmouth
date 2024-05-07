//
//  Configuration.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Crypto
import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import OSLog
import SwiftASN1
import X509

public struct Configuration: Codable {
    let certificate: Certificate
    let privateKey: Certificate.PrivateKey

    enum CodingKeys: String, CodingKey {
        case certificate
        case privateKey
    }

    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.certificate = try .init(
                derEncoded: try container.decode(Data.self, forKey: .certificate).bytes)
            self.privateKey = .init(
                try P256.Signing.PrivateKey(
                    derRepresentation: try container.decode(Data.self, forKey: .privateKey)))
        } catch {
            Logger.error(error.localizedDescription)
            throw error
        }
    }

    public func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(certificate.derRepresentation, forKey: .certificate)
            try container.encode(privateKey.derRepresentation, forKey: .privateKey)
        } catch {
            Logger.error(error.localizedDescription)
            throw error
        }
    }

    private init() {
        let privateKey: Certificate.PrivateKey = .default
        let currentTime: Date = .default
        // swiftlint:disable:next force_try
        let name: DistinguishedName = try! DistinguishedName {
            CommonName("Mudmouth")
            OrganizationName("@Salmonia3JP")
        }
        // swiftlint:disable:next force_try
        let extensions: Certificate.Extensions = try! .init([
            .init(BasicConstraints.isCertificateAuthority(maxPathLength: nil), critical: true),
            .init(KeyUsage(digitalSignature: true, keyCertSign: true), critical: true),
        ])
        // swiftlint:disable:next force_try
        let certificate: Certificate = try! .init(
            version: .v3,
            serialNumber: .default,
            publicKey: privateKey.publicKey,
            notValidBefore: currentTime,
            notValidAfter: currentTime.addingTimeInterval(60 * 60 * 24 * 365 * 5),
            issuer: name,
            subject: name,
            signatureAlgorithm: .ecdsaWithSHA256,
            extensions: extensions,
            issuerPrivateKey: privateKey
        )
        self.privateKey = privateKey
        self.certificate = certificate
    }

    init(certificate: Certificate, privateKey: P256.Signing.PrivateKey) {
        self.certificate = certificate
        self.privateKey = .init(privateKey)
    }

    init(certificate: Certificate, privateKey: Certificate.PrivateKey) {
        self.certificate = certificate
        self.privateKey = privateKey
    }

    var issuer: String {
        certificate.issuer.first(where: { $0.description.starts(with: "O=") })?
            .description
            .replacingOccurrences(of: "O=", with: "") ?? ""
    }

    var subject: String {
        certificate.subject.first(where: { $0.description.starts(with: "CN=") })?
            .description
            .replacingOccurrences(of: "CN=", with: "") ?? ""
    }

    var notValidBefore: Date {
        certificate.notValidBefore
    }

    var notValidAfter: Date {
        certificate.notValidAfter
    }

    var algorithm: Certificate.Signature {
        certificate.signature
    }

    var KeyString: String {
        privateKey.publicKey.derBytes.hexString
    }

    var privateKeyString: String {
        privateKey.derBytes.hexString
    }

    var isValid: Bool {
        certificate.publicKey == privateKey.publicKey
    }

    var context: NIOSSLContext {
        // swiftlint:disable:next force_try
        try! .init(
            configuration: TLSConfiguration.makeServerConfiguration(
                certificateChain: [
                    .certificate(try NIOSSLCertificate(bytes: certificate.derBytes, format: .der))
                ],
                privateKey: .privateKey(NIOSSLPrivateKey(bytes: privateKey.derBytes, format: .der))
            )
        )
    }

    /// CA証明書
    func generate() -> Configuration {
        let url: URL = .init(unsafeString: "https://api.lp1.av5ja.srv.nintendo.net/api/bullet_tokens")
        let caPrivateKey: Certificate.PrivateKey = .default
        let currentTime: Date = .default
        // swiftlint:disable:next force_try
        let subject: DistinguishedName = try! DistinguishedName {
            CommonName("Salmonia3 Signed")
            OrganizationName("@Salmonia3JP")
        }
        // swiftlint:disable:next force_try
        let extensions: Certificate.Extensions = try! Certificate.Extensions {
            Critical(
                BasicConstraints.notCertificateAuthority
            )
            Critical(
                KeyUsage(digitalSignature: true)
            )
            // swiftlint:disable:next force_try
            try! ExtendedKeyUsage([ExtendedKeyUsage.Usage.serverAuth, ExtendedKeyUsage.Usage.ocspSigning])
            SubjectKeyIdentifier(hash: caPrivateKey.publicKey)
            // swiftlint:disable:next force_unwrapping
            SubjectAlternativeNames([.dnsName(url.host!)])
        }
        let configuration: Configuration = .init(
            // swiftlint:disable:next force_try
            certificate: try! .init(
                version: .v3,
                serialNumber: .default,
                publicKey: caPrivateKey.publicKey,
                notValidBefore: currentTime,
                notValidAfter: currentTime.addingTimeInterval(60 * 60 * 24 * 365),
                issuer: certificate.issuer,
                subject: subject,
                signatureAlgorithm: .ecdsaWithSHA256,
                extensions: extensions,
                issuerPrivateKey: privateKey
            ),
            privateKey: caPrivateKey
        )
        return configuration
    }
}

extension Configuration {
    static var `default`: Configuration {
        .init()
    }
}
