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
    //    @AppStorage("externalIPSelection") var externalIPSelection: ExternalIPProviders = .icanhazip
    //    @State var externalIPSelection: ExternalIPProviders = .icanhazip
    
    
    //    @AppStorage("checkVPN") var checkVPN = true
    @FocusState var isFocused: Bool
    @State var presentSettingsAlert = false
    
    var body: some View {
        VStack(alignment: .listRowSeparatorLeading) {
            HStack {
                Text("Start at login:").fixedSize()
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
            }.frame(width: 200)
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
            }.frame(width: 195)
            HStack {
                Text("Use monospaced font:").fixedSize()
                Spacer()
                Toggle("", isOn: $useMonospaced)
            }.frame(width: 200)
            HStack {
                Text("Use translucent window:").fixedSize()
                Spacer()
                Toggle("", isOn: $beTranslucent)
            }.frame(width: 200)
            VStack(alignment: .leading) {
                Text("External IP Lookup:")
                Picker("",selection: $externalIPCheck) {
                    Text("icanhazip.com").tag("icanhazip.com")
                    Text("mapper.ntppool.org").tag("mapper.ntppool.org")
                }.pickerStyle(RadioGroupPickerStyle())
                    .onChange(of: externalIPCheck) {
                        Task {
                            do {
                                try await externalIPOutput.updateExternalIPOutput(newOutput: NetworkWorkflow.getExternalIP())
                            } catch {
                                print(error)
                            }
                        }
                    }
            }
            .padding(.bottom)
            HStack {
                Text("""
                 If SSID is always \"Unavailable\",
                 enable location services
                 for NetworkView
                 """)
                .font(.caption)
                .fixedSize()
                Spacer()
                Button {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
                } label: {
                    Image(systemName: "location.circle.fill")
                }.buttonStyle(PlainButtonStyle())
            }.frame(width: 200)
            
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
