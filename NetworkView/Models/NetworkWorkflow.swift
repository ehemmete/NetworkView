//
//  NetworkWorkflow.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 7/18/23.
//

import Foundation
import CoreWLAN
import SystemConfiguration
import Network
import SwiftUI

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

enum NetworkWorkflow {
    
    struct ServiceData {
        var serviceName: String = ""
        var serviceIP: String = ""
        
        init(serviceName: String, serviceIP: String) {
            self.serviceName = serviceName
            self.serviceIP = serviceIP
        }
    }
    
    static func updateNetworkInfo(path: NWPath) throws -> String? {
        var output: [String] = []
        var serviceData: [ServiceData] = []
        
        if let serviceList = try! NetworkWorkflow.getNetworkServices() {
            for service in serviceList {
                if let service_name = try! NetworkWorkflow.getServiceName(service as CFString),
                   let ip_address = try! NetworkWorkflow.getIP(service as CFString) {
                    let newService: ServiceData = ServiceData(serviceName: service_name, serviceIP: ip_address)
                    serviceData.append(newService)
                }
            }
            
            for activeInterface in path.availableInterfaces {
                var serviceName = ""
                if let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil),
                   let ipInfo = SCDynamicStoreCopyValue(net_config, String("State:/Network/Interface/\(activeInterface.debugDescription)/IPv4") as CFString),
                   let address = ipInfo[kSCPropNetIPv4Addresses] as? [String] {
                    for serviceInfo in serviceData {
                        if serviceInfo.serviceIP == address[0] {
                            serviceName = serviceInfo.serviceName
                            break
                        } else {
                            serviceName = activeInterface.debugDescription
                        }
                    }
                    output.append("\(serviceName): \(address[0])")
                    if serviceName == "Wi-Fi" {
                        if let wifiInfo = try! NetworkWorkflow.getWifiInfo() {
                            output.append(wifiInfo)
                        }
                    }
                }
            }
        }
        
        if output.isEmpty {
            return nil
        } else {
            return output.joined(separator: "\n")
        }
    }
    
    static func getNetworkServices() throws -> [String]? {
        let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil)!
        let service_config = SCNetworkSetCopyCurrent(prefs)!
        let service_list_cf = SCNetworkSetGetServiceOrder(service_config)
        let service_order = service_list_cf as! Array<String>
        return service_order
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

    static func getExternalIP() async throws -> String {
        let url = URL(string: "https://icanhazip.com/")
        do {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForResource = 2
            let (data, _) = try await URLSession(configuration: sessionConfig).data(from: url!)
            return "External: \(String(decoding: data, as: UTF8.self))"
        } catch {
            return "External: No Connection"
        }
    }
}
