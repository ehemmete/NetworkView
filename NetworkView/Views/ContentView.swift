//
//  ContentView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI

struct ContentView: View {
    @State var networkOuput: String
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var body: some View {
        if networkMonitor.isConnected {
            if useMonospaced {
                Text(networkOuput)
                    .textSelection(.enabled)
                    .font(.system(size: CGFloat(fontSize)).monospaced())
                    .padding()
                    .fixedSize()
            } else {
                Text(networkOuput)
                    .textSelection(.enabled)
                    .font(.system(size: CGFloat(fontSize)))
                    .padding()
                    .fixedSize()
            }
            
        } else {
            Text("No network connection")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networkOuput: """
Thunderbolt Ethernet: 172.21.21.21
Wi-Fi: 10.0.0.1
SSID / 157@5GHz-40MHz wide
External: 100.100.100.100
""").environmentObject(NetworkMonitor())
    }
}
