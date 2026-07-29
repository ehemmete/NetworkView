//
//  NetworkMonitor.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/13/23.
//

import SwiftUI
import Network

@Observable class NetworkMonitor {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let status = path.status == .satisfied
            
            // Use a Task to handle the async update on the MainActor
            Task { @MainActor in
                self.isConnected = status
                print("Network Changed: \(status ? "Connected" : "Disconnected")")
                do {
                    try await updateNetworkOutput(path: path)
                } catch {
                    print("Error updating network output: \(error)")
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
    
    deinit {
        networkMonitor.cancel()
    }
}
