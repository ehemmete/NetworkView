//
//  NetworkViewApp.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/30/25.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillUpdate(_ notification: Notification) {
        if let menu = NSApplication.shared.mainMenu {
            if let file = menu.items.first(where: { $0.title == "File"}) {
                menu.removeItem(file);
            }
            if let edit = menu.items.first(where: { $0.title == "Edit"}) {
                menu.removeItem(edit);
            }
            if let window = menu.items.first(where: { $0.title == "Window"}) {
                menu.removeItem(window);
            }
            if let view = menu.items.first(where: { $0.title == "View"}) {
                menu.removeItem(view);
            }
            if let help = menu.items.first(where: { $0.title == "Help"}) {
                menu.removeItem(help);
            }
        }
    }
}

@main
struct NetworkViewApp: App {
    @State private var networkMonitor = NetworkMonitor()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
