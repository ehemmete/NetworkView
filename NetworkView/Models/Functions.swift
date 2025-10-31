//
//  Functions.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/30/25.
//

import SwiftUI
import CoreWLAN
import Network
import SystemConfiguration

func updateNetworkOutput(path: NWPath) async throws {
    NetworkOutput.shared.output.removeAll()
    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
       let service_config = SCNetworkSetCopyCurrent(prefs),
       let service_list_cf = SCNetworkSetGetServiceOrder(service_config) as? [CFString] {
        service_list_cf.forEach { service in
            let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil)
            if let serviceDictionary = SCDynamicStoreCopyValue(net_config, String("State:/Network/Service/\(service)/IPv4") as CFString) {
                var ip = ""
                var bsdName = ""
                var serviceName = ""
                var speed = ""
                var remoteAddress = ""
                if let addresses = serviceDictionary[kSCPropNetIPv4Addresses] as? [String] {
                    ip = addresses[0]
                }
                if let interface = serviceDictionary[kSCPropInterfaceName] as? String {
                    bsdName = interface
                }
                if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
                   let network_services_copy = SCNetworkServiceCopy(prefs, service),
                   let network_interface = SCNetworkServiceGetInterface(network_services_copy),
                   let configuration = SCNetworkInterfaceGetConfiguration(network_interface),
                   let _ = (configuration as NSDictionary)["RemoteAddress"] {
                    remoteAddress = (configuration as NSDictionary)["RemoteAddress"] as! String
                }
                if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
                   let network_services_copy = SCNetworkServiceCopy(prefs, service),
                   let _ = SCNetworkServiceGetName(network_services_copy) {
                    serviceName = SCNetworkServiceGetName(network_services_copy)! as String
                }
                do {
                    if let media_speed = try getMediaSpeed(service as CFString) {
                        speed = media_speed
                    }
                } catch {
                    print("Get media speed error: \(error)")
                }
                
                if serviceName == "Wi-Fi" {
                    do {
                        if let wifiInfo = try getWifiInfo() {
                            NetworkOutput.shared.output.append(NetworkData(serviceName: serviceName, serviceIP: ip, bsdName: bsdName, speed: speed, SSID: wifiInfo.ssid, BSSID: wifiInfo.bssid, channel: wifiInfo.channel, band: wifiInfo.band, width: wifiInfo.width))
                        }
                    } catch {
                        print("Error getting Wifi info: \(error)")
                    }
                } else if remoteAddress != "" {
                    NetworkOutput.shared.output.append(NetworkData(serviceName: remoteAddress, serviceIP: ip, bsdName: bsdName, speed: speed))
                } else {
                    NetworkOutput.shared.output.append(NetworkData(serviceName: serviceName, serviceIP: ip, bsdName: bsdName, speed: speed))
                }
            }
        }
    }
    await NetworkOutput.shared.output.append(try getExternalIP())
}

func getMediaSpeed(_ service: CFString) throws -> String? {
    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
       let network_services_copy = SCNetworkServiceCopy(prefs, service),
       let network_interface = SCNetworkServiceGetInterface(network_services_copy),
       let bsdName = SCNetworkInterfaceGetBSDName(network_interface) {
        let ifconfig = "/sbin/ifconfig"
        let args = [bsdName as String]
        let rawMediaDetails = try ProcessRunner.shellCommand(ifconfig, args)
        let mediaDetails = String(decoding: rawMediaDetails, as: Unicode.UTF8.self).components(separatedBy: "\n")
        var speed: String?
        if let media = mediaDetails.first(where: { $0.contains("media:") }) {
            speed = media.slice(from: "(", to: ")") ?? ""
            return speed
        } else {
            return nil
        }
    } else {
        return nil
    }
    
}

func getWifiInfo() throws -> WifiData? {
    let client = CWWiFiClient.shared()
    let ssid_name = client.interface()?.ssid() ?? "Unavailable"
    let bssid = client.interface()?.bssid() ?? "Unavailable"
    if let channel_number = client.interface()?.wlanChannel()?.channelNumber,
       let channel_width = client.interface()?.wlanChannel()?.channelWidth,
       let channel_band = client.interface()?.wlanChannel()?.channelBand
    {
        return WifiData(ssid: ssid_name, bssid: bssid, channel: channel_number, band: channel_band, width: channel_width)
    } else {
        return nil
    }
}

func getExternalIP() async throws -> NetworkData {
    @AppStorage("externalIPCheck") var externalIPCheck = "icanhazip.com"
    var externalIP = ""
    
    if externalIPCheck == "icanhazip.com" {
        let url = URL(string: "https://icanhazip.com/")
        print("Using icanhazip.com")
        do {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForResource = 2
            let (data, _) = try await URLSession(configuration: sessionConfig).data(from: url!)
            externalIP = String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\n", with: "")
        } catch {
            externalIP = "No Connection"
        }
    } else if externalIPCheck == "mapper.ntppool.org" {
        print("Using mapper.ntppool.org")
        let url = URL(string: "https://www.mapper.ntppool.org/json")
        do {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForResource = 2
            let (data, _) = try await URLSession(configuration: sessionConfig).data(from: url!)
            let decoder = JSONDecoder()
            if let jsonData = try? decoder.decode(ntppoolJSON.self, from: data) {
                externalIP = jsonData.HTTP
            }
        } catch {
            externalIP = "No Connection"
        }
    } else {
        externalIP = "No External IP Provider Selected"
    }
    return NetworkData(serviceName: "External", serviceIP: externalIP, bsdName: "")
}


//func getBSDName(_ service: CFString) throws -> String? {
//    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
//       //       let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil),
//       let network_services_copy = SCNetworkServiceCopy(prefs, service),
//       let network_interface = SCNetworkServiceGetInterface(network_services_copy),
//       let bsdName = SCNetworkInterfaceGetBSDName(network_interface) {
//        return bsdName as String
//    } else {
//        return nil
//    }
//}
//func getNetworkServices() throws -> [String]? {
//    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
//       let service_config = SCNetworkSetCopyCurrent(prefs),
//       let service_list_cf = SCNetworkSetGetServiceOrder(service_config),
//       let service_order = service_list_cf as? Array<String> {
//        return service_order
//    } else {
//        return nil
//    }
//}
//func getServiceName(_ service: CFString) throws -> String? {
//    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
//       let network_services_copy = SCNetworkServiceCopy(prefs, service),
//       let service_name = SCNetworkServiceGetName(network_services_copy) {
//        return service_name as String
//    } else {
//        return nil
//    }
//}
//func getIP(_ service: CFString) throws -> String? {
//    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
//       let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil),
//       let network_services_copy = SCNetworkServiceCopy(prefs, service),
//       let network_interface = SCNetworkServiceGetInterface(network_services_copy),
//       let bsdName = SCNetworkInterfaceGetBSDName(network_interface),
//       let ipInfo = SCDynamicStoreCopyValue(net_config, String("State:/Network/Interface/\(bsdName)/IPv4") as CFString),
//       let address = ipInfo[kSCPropNetIPv4Addresses] as? [String]
//    {
//        return address[0]
//    } else {
//        return nil
//    }
//}
//func getVPNRemoteAddress(_ service: CFString) throws -> String? {
//    if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
//       let network_services_copy = SCNetworkServiceCopy(prefs, service),
//       let network_interface = SCNetworkServiceGetInterface(network_services_copy),
//       let configuration = SCNetworkInterfaceGetConfiguration(network_interface),
//       let remoteAddress = (configuration as NSDictionary)["RemoteAddress"] as? String {
//        return remoteAddress
//    } else {
//        return nil
//    }
//}
