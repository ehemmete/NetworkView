//
//  Functions.swift
//  NetworkInfo
//
//  Created by Eric.Hemmeter on 7/19/19.
//  Copyright © 2019 Sneakypockets. All rights reserved.
//

import Foundation
import CoreWLAN
import SystemConfiguration
import SwiftUI

extension CWChannelBand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .band2GHz: return "2.4GHz"
        case .band5GHz: return "5GHz"
        case .band6GHz: return "6GHz"
        default: return "Unknown"
        }
    }
}

extension CWChannelWidth: CustomStringConvertible {
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

struct NetworkFunctions {
    private static let vpnProtocolsKeysIdentifiers = [
        "tap", "tun", "ppp", "ipsec", "utun"
    ]
    
    static func updateNetworkInfo() -> String? {
        @AppStorage("checkVPN") var checkVPN = true
        var output: [String] = []
//        print("Updating network info")
        if let serviceList = try! NetworkFunctions.getNetworkServices() {
//            print(serviceList)
            for service in serviceList {
//                print(service)
                if let service_name = try! NetworkFunctions.getServiceName(service as CFString),
                   let ip_address = try! NetworkFunctions.getIP(service as CFString) {
//                    print("\(service_name):\(ip_address)")
                    output.append(String("\(service_name): \(ip_address)"))
                    if service_name == "Wi-Fi" {
//                        print("service name is Wi-Fi")
                        if let wifiInfo = try! NetworkFunctions.getWifiInfo() {
//                            print(wifiInfo)
                            output.append(wifiInfo)
                        }
                    }
                }
            }
        }
        if checkVPN {
            if let vpnDetails = try! getVPNDetails() {
                output.append(vpnDetails)
            }
        }
        let publicIP = try! NetworkFunctions.getExternalIP()
//        print(publicIP)
        output.append(publicIP)
        
        return output.joined(separator: "\n")
    }
    
    static func getNetworkServices() throws -> [String]? {
        let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil)!
        let service_config = SCNetworkSetCopyCurrent(prefs)!
        let service_list_cf = SCNetworkSetGetServiceOrder(service_config)
        let service_order = service_list_cf as! Array<String>
        return service_order
    }

    static func getWifiInfo() throws -> String? {
        let client = CWWiFiClient.shared()
        let ssid_name = client.interface()?.ssid() ?? "Unavailable"
        if let channel_number = client.interface()?.wlanChannel()?.channelNumber,
           let channel_width = client.interface()?.wlanChannel()?.channelWidth,
           let channel_band = client.interface()?.wlanChannel()?.channelBand
        {
            return String("\(ssid_name) / \(channel_number)@\(channel_band)-\(channel_width) wide")
        } else {
            return String("Unable to get Wi-Fi information")
        }
    }
    
    static func getServiceName(_ service: CFString) throws -> String? {
        if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
           let network_services_copy = SCNetworkServiceCopy(prefs, service),
           let service_name = SCNetworkServiceGetName(network_services_copy) {
            return service_name as String
        } else {
            return nil
        }
    }
    
    static func getIP(_ service: CFString) throws -> String? {
        if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
           let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil),
           let network_services_copy = SCNetworkServiceCopy(prefs, service),
           let network_interface = SCNetworkServiceGetInterface(network_services_copy),
           let bsdName = SCNetworkInterfaceGetBSDName(network_interface),
           let ipInfo = SCDynamicStoreCopyValue(net_config, String("State:/Network/Interface/\(bsdName)/IPv4") as CFString),
           let address = ipInfo[kSCPropNetIPv4Addresses] as? [String]
        {
            return address[0]
        } else {
            return nil
        }
    }
    
    static func getExternalIP() throws -> String {
        do {
            let publicIP = try String(contentsOf: URL(string: "https://icanhazip.com/")!)
            return String("External: \(publicIP)")
        } catch {
            return String("No external connection")
        }
    }
    
    
    static func getVPNDetails() throws -> String? {
        var vpnOutput: [String] = []
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return nil }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
              let allKeys = keys.allKeys as? [String] else { return nil }
        
        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in vpnProtocolsKeysIdentifiers
            where key.starts(with: protocolId) {
                let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil)
                let ipInfo = SCDynamicStoreCopyValue(net_config, String("State:/Network/Interface/\(key)/IPv4") as CFString)
                if let address = ipInfo![kSCPropNetIPv4Addresses] as? [String] {
                    vpnOutput.append("\(key): \(address[0])")
                }
            }
        }
        if vpnOutput.isEmpty {
            return nil
        } else {
            return vpnOutput.joined(separator: "\n")
        }
    }
    
}
