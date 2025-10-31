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
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            RunLoop.main.perform {
                print("Network Changed")
                Task {
                    do {
                        try await updateNetworkOutput(path: path)
                    } catch {
                        print("Error updating network output: \(error)")
                    }
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}

