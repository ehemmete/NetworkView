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
    var body: some Scene {
        WindowGroup {
            ContentView(networkOutput: NetworkFunctions.updateNetworkInfo()!)
                .onDisappear { terminateApp() }
                .environmentObject(networkMonitor)
        }
        .defaultPosition(.bottomLeading)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        Settings {
            SettingsView(networkOutput: "")
                .navigationTitle("Settings")
        }
        .windowResizability(.contentSize)
    }
    private func terminateApp() {
        NSApplication.shared.terminate(self)
    }
}
