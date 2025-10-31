//
//  NetworkViewApp.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/30/25.
//

import SwiftUI

@main
struct NetworkViewApp: App {
    @State private var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkMonitor)
                .onDisappear { terminateApp() }
            
        }
        .defaultPosition(.bottomLeading)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        Settings {
            SettingsView()
                .navigationTitle("Settings")
        }
        .windowResizability(.contentSize)
    }
    private func terminateApp() {
        NSApplication.shared.terminate(self)
    }
}
