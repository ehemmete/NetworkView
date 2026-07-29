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

// Shared session to avoid recreating connections on every IP check
private let session = URLSession(configuration: {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForResource = 2
    return config
}())

@MainActor
func updateNetworkOutput(path: NWPath) async throws {
    print("Updating network output")
    
    // Build a temporary list to avoid UI flicker caused by .removeAll()
    var newOutput: [NetworkData] = []
    
    guard let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
          let service_config = SCNetworkSetCopyCurrent(prefs),
          let service_list_cf = SCNetworkSetGetServiceOrder(service_config) as? [CFString] else {
        return
    }
    
    let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil)
    
    for service in service_list_cf {
        guard let serviceDictionary = SCDynamicStoreCopyValue(net_config, String("State:/Network/Service/\(service)/IPv4") as CFString) else {
            continue
        }
        
        var ip = ""
        var bsdName = ""
        var serviceName = ""
        var speed = ""
        var remoteAddress = ""
        
        if let addresses = serviceDictionary[kSCPropNetIPv4Addresses] as? [String], !addresses.isEmpty {
            ip = addresses[0]
        }
        
        if let interface = serviceDictionary[kSCPropInterfaceName] as? String {
            bsdName = interface
        }
        
        if let network_services_copy = SCNetworkServiceCopy(prefs, service),
           let network_interface = SCNetworkServiceGetInterface(network_services_copy),
           let configuration = SCNetworkInterfaceGetConfiguration(network_interface),
           let remoteAddr = (configuration as NSDictionary)["RemoteAddress"] as? String {
            remoteAddress = remoteAddr
        }
        
        if let network_services_copy = SCNetworkServiceCopy(prefs, service),
           let name = SCNetworkServiceGetName(network_services_copy) {
            serviceName = name as String
        }
        
        if !speed.isEmpty {
            do {
                if let media_speed = try getMediaSpeed(service as CFString) {
                    speed = media_speed
                }
            } catch {
                print("Get media speed error: \(error)")
            }
        } else {
            // Try to get speed if it's currently empty
            do {
                if let media_speed = try getMediaSpeed(service as CFString) {
                    speed = media_speed
                }
            } catch {
                print("Get media speed error: \(error)")
            }
        }
        
        if serviceName == "Wi-Fi" {
            do {
                if let wifiInfo = try getWifiInfo() {
                    newOutput.append(NetworkData(serviceName: serviceName, serviceIP: ip, bsdName: bsdName, speed: speed, SSID: wifiInfo.ssid, BSSID: wifiInfo.bssid, channel: wifiInfo.channel, band: wifiInfo.band, width: wifiInfo.width))
                }
            } catch {
                print("Error getting Wifi info: \(error)")
            }
        } else if !remoteAddress.isEmpty {
            newOutput.append(NetworkData(serviceName: remoteAddress, serviceIP: ip, bsdName: bsdName, speed: speed))
        } else {
            newOutput.append(NetworkData(serviceName: serviceName, serviceIP: ip, bsdName: bsdName, speed: speed))
        }
    }

    do {
        let external = try await getExternalIP()
        newOutput.append(external)
    } catch {
        print("External IP fetch failed: \(error)")
    }
    
    // Atomic update: replaces the entire array once, preventing UI flicker
    NetworkOutput.shared.output = newOutput
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
        
        if let media = mediaDetails.first(where: { $0.contains("media:") }) {
            return media.slice(from: "(", to: ")") ?? ""
        }
    }
    return nil
}

func getWifiInfo() throws -> WifiData? {
    let client = CWWiFiClient.shared()
    guard let interface = client.interface() else { return nil }
    
    let ssid_name = interface.ssid() ?? "Unavailable"
    let bssid = interface.bssid() ?? "Unavailable"
    
    if let wlanChannel = interface.wlanChannel() {
        return WifiData(ssid: ssid_name, bssid: bssid, channel: wlanChannel.channelNumber, band: wlanChannel.channelBand, width: wlanChannel.channelWidth)
    } else {
        return nil
    }
}

func getExternalIP() async throws -> NetworkData {
    let externalIPCheck = UserDefaults.standard.string(forKey: "externalIPCheck") ?? "icanhazip.com"
    var externalIP = ""
    
    if externalIPCheck == "icanhazip.com" {
        if let url = URL(string: "https://icanhazip.com/") {
            do {
                let (data, _) = try await session.data(from: url)
                externalIP = String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\n", with: "")
            } catch {
                externalIP = "No Connection"
            }
        }
    } else if externalIPCheck == "mapper.ntppool.org" {
        if let url = URL(string: "https://www.mapper.ntppool.org/json") {
            do {
                let (data, _) = try await session.data(from: url)
                let decoder = JSONDecoder()
                if let jsonData = try? decoder.decode(ntppoolJSON.self, from: data) {
                    externalIP = jsonData.HTTP
                }
            } catch {
                externalIP = "No Connection"
            }
        }
    } else {
        externalIP = "No External IP Provider Selected"
    }
    return NetworkData(serviceName: "External", serviceIP: externalIP, bsdName: "")
}
