//
//  NetworkViewApp.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI

@main
struct NetworkViewApp: App {
    @StateObject var networkMonitor = NetworkMonitor()
    @AppStorage("hideTitleBar") var hideTitleBar = false

    var body: some Scene {
        WindowGroup {
            ContentView(networkOuput: NetworkFunctions.updateNetworkInfo()!)
                .onDisappear { terminateApp() }
                .environmentObject(networkMonitor)
        }.defaultSize(width: 200, height: 100)
            .defaultPosition(.bottomLeading)
            .windowResizability(.contentSize)
        Settings {
            SettingsView()
                .frame(width: 200, height: 80)
                .navigationTitle("Settings")
        }
        .windowResizability(.contentSize)
    }
    private func terminateApp() {
                NSApplication.shared.terminate(self)
            }
}
