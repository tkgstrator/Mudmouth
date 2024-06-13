//
//  NEVPNStatus.swift
//  Starlight
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import NetworkExtension

extension NEVPNStatus {
    var isProcessing: Bool {
        self == .connecting || self == .disconnecting
    }
}

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid:
            return "Invalid"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .reasserting:
            return "Reasserting"
        case .disconnecting:
            return "Disconnecting"
        @unknown default:
            fatalError("Unknown value")
        }
    }

    var action: String {
        switch self {
        case .invalid, .disconnected:
            return "Connect"
        case .connected:
            return "Disconnect"
        default:
            return description
        }
    }
}
