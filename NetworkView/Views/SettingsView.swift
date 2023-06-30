//
//  SettingsView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    var body: some View {
        Stepper(value: $fontSize,
                in: 8 ... 72) {
            Text("Selct the font size: \(fontSize)")
            
        }
        Toggle(isOn: $useMonospaced) {
            Text("Use monospaced font")
        }
    }
}

#Preview {
    SettingsView()
}
