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
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Select font size:")
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
            }
            HStack {
                Text("Use monospaced font:")
                Toggle("", isOn: $useMonospaced)
            }
        }        
    }
}

#Preview {
    SettingsView()
}
