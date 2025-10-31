//
//  NetworkData.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/30/25.
//

import Foundation
import CoreWLAN
import Network
import SystemConfiguration

struct NetworkData: Identifiable, Hashable {
    static func == (lhs: NetworkData, rhs: NetworkData) -> Bool {
        return lhs.serviceIP == rhs.serviceIP &&
        lhs.serviceName == rhs.serviceName
    }
    
    var id = UUID()
    var serviceName: String = ""
    var serviceIP: String = ""
    var bsdName: String = ""
    var speed: String?
    var SSID: String?
    var BSSID: String?
    var channel: Int?
    var band: CWChannelBand?
    var width: CWChannelWidth?
    
    init(serviceName: String, serviceIP: String,bsdName: String, speed: String? = nil, SSID: String? = nil, BSSID: String? = nil, channel: Int? = nil, band: CWChannelBand? = nil, width: CWChannelWidth? = nil) {
        self.serviceName = serviceName
        self.serviceIP = serviceIP
        self.bsdName = bsdName
        self.speed = speed
        self.SSID = SSID
        self.BSSID = BSSID
        self.channel = channel
        self.band = band
        self.width = width
    }
}

struct WifiData: Hashable {
    var ssid: String
    var bssid: String
    var channel: Int
    var band: CWChannelBand
    var width: CWChannelWidth
    
    init(ssid: String, bssid: String, channel: Int, band: CWChannelBand, width: CWChannelWidth) {
        self.ssid = ssid
        self.bssid = bssid
        self.channel = channel
        self.band = band
        self.width = width
    }
}

struct ntppoolJSON: Codable {
    var DNS: String
    var EDNS: String
    var HTTP: String
}

extension CWChannelBand: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .band2GHz: return "2.4GHz"
        case .band5GHz: return "5GHz"
        case .band6GHz: return "6GHz"
        case .bandUnknown: return "Unknown"
        default: return "Unknown"
        }
    }
}

extension CWChannelWidth: @retroactive CustomStringConvertible {
    public var description: String {
        switch  self {
        case .width160MHz: return "160MHz"
        case .width20MHz: return "20MHz"
        case .width40MHz: return "40MHz"
        case .width80MHz: return "80MHz"
        case .widthUnknown: return "Unknown"
        default: return "Unknown"
        }
    }
}
