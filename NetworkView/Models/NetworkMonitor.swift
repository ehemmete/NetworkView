//
//  NetworkMonitor.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/13/23.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            RunLoop.main.perform {
                print("Network Changed")
                networkOutput.updateOutput(newOutput: NetworkWorkflow.updateNetworkInfo(path: path) ?? "")
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}

