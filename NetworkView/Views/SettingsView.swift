//
//  SettingsView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI
import Network

struct SettingsView: View {
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("beTranslucent") var beTranslucent = false
//    @AppStorage("checkVPN") var checkVPN = true
    @FocusState var isFocused: Bool
    @State var presentSettingsAlert = false
    
    var body: some View {
        VStack(alignment: .listRowSeparatorLeading) {
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
        }
        .padding()
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
