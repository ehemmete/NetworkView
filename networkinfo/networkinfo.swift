//
//  main.swift
//  networkinfo
//
//  Created by Eric Hemmeter on 4/11/25.
//

import Foundation
import ArgumentParser
import CoreWLAN
import CoreLocation


@main
struct Networkinfo: ParsableCommand, CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation) {
        // Required for location info
    }
    
    mutating func run() throws {
        if LocationServices.shared.locationManager.authorizationStatus == .authorizedAlways {
            LocationServices.shared.userLocationDelegate = self
            print("Authorized")
        } else {
            LocationServices.shared.locationManager.requestAlwaysAuthorization()
            print("Requesting authorization...")
        }
        let client = CWWiFiClient.shared()
        let ssid_name = client.interface()?.ssid() ?? "Unavailable"
        let bssid = client.interface()?.bssid() ?? "Unavailable"
        if let channel_number = client.interface()?.wlanChannel()?.channelNumber,
           let channel_width = client.interface()?.wlanChannel()?.channelWidth,
           let channel_band = client.interface()?.wlanChannel()?.channelBand
        {
            print("\(ssid_name) / \(channel_number)@\(channel_band)-\(channel_width) wide\nBSSID: \(bssid)")
        } else {
            print("Unable to get Wi-Fi information")
        }
    }
}


extension CWChannelBand: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .band2GHz: return "2.4GHz"
        case .band5GHz: return "5GHz"
        case .band6GHz: return "6GHz"
        default: return "Unknown"
        }
    }
}

extension CWChannelWidth: @retroactive CustomStringConvertible {
    public var description: String {
        switch  self {
        case .width160MHz:
            return "160MHz"
        case .width20MHz:
            return "20MHz"
        case .width40MHz:
            return "40MHz"
        case .width80MHz:
            return "80MHz"
        default:
            return "Unknown"
        }
    }
}
