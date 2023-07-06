//
//  SettingsView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI

struct SettingsView: View {
    @State var networkOutput: String
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("beTranslucent") var beTranslucent = false
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .listRowSeparatorLeading) {
            HStack {
                Text("Select font size:    ").fixedSize()
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
                Text("Use monospaced font:    ").fixedSize()
                Toggle("", isOn: $useMonospaced)
            }
            HStack {
                Text("Use translucent window: ").fixedSize()
                Toggle("", isOn: $beTranslucent)
            }
        }.padding(.horizontal)
            .padding(.top)
        Button("Force Refresh", action: {
            networkOutput = NetworkFunctions.updateNetworkInfo() ?? ""
        }).padding()
    }
}

#Preview {
    SettingsView(networkOutput: "")
}
