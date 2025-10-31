//
//  SettingsView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI
import Network
import ServiceManagement

struct SettingsView: View {
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("beTranslucent") var beTranslucent = false
    @AppStorage("externalIPCheck") var externalIPCheck = "icanhazip.com"
    @AppStorage("startAtLogin") var startAtLogin = false
    @AppStorage("displaySpeed") var displaySpeed = true
    @AppStorage("displayWifiDetails") var displayWifiDetails = true
    @AppStorage("displayBSSID") var displayBSSID = false

    @FocusState var isFocused: Bool
    @State var frameWidth = 350.0
    @State var frameHeight = 260.0
    
    var body: some View {
//        VStack(alignment: .listRowSeparatorLeading) {
        GroupBox {
            List {
                HStack {
                    Text("Start at login")
                    Spacer()
                    Toggle("", isOn: $startAtLogin)
                        .onChange(of: startAtLogin) {
                            let appService = SMAppService.mainApp
                            if startAtLogin {
                                do {
                                    try appService.register()
                                } catch {
                                    print("Could not register app service: \(error)")
                                }
                            } else {
                                do {
                                    try appService.unregister()
                                } catch {
                                    print("Could not unregister app service: \(error)")
                                }
                            }
                        }
                }
                HStack {
                    Text("Select font size:").fixedSize()
                    Spacer()
                    TextField("", value: $fontSize, format: .number)
                        .frame(minWidth: 15, maxWidth: 25)
                        .focused($isFocused)
                    Stepper("") {
                        isFocused = false
                        fontSize += 1
                    } onDecrement: {
                        isFocused = false
                        fontSize -= 1
                    }
                    .labelsHidden()
                }
                HStack {
                    Text("Use monospaced font:").fixedSize()
                    Spacer()
                    Toggle("", isOn: $useMonospaced)
                }
                HStack {
                    Text("Use translucent window:").fixedSize()
                    Spacer()
                    Toggle("", isOn: $beTranslucent)
                }
                HStack {
                    Text("Display speeds:").fixedSize()
                    Spacer()
                    Toggle("", isOn: $displaySpeed)
                }
                HStack {
                    Text("Display Wi-Fi details:").fixedSize()
                    Spacer()
                    Toggle("", isOn: $displayWifiDetails)
                }
                HStack {
                    Text("Display BSSID:").fixedSize()
                    Spacer()
                    Toggle("", isOn: $displayBSSID)
                }
                .disabled(!displayWifiDetails)
                Picker("External IP Lookup:",selection: $externalIPCheck) {
                    Text("icanhazip.com").tag("icanhazip.com")
                    Text("mapper.ntppool.org").tag("mapper.ntppool.org")
                }
                .pickerStyle(.menu)
                .onChange(of: externalIPCheck) {
                    let _ = NetworkMonitor()
                }
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        HStack {
            Text("""
                 If SSID is always \"Unavailable\",
                 enable location services
                 for NetworkView
                 """)
                .font(.caption)
                .fixedSize()
            Button {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
            } label: {
                Image(systemName: "location.circle.fill")
            }.buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    SettingsView()
}
