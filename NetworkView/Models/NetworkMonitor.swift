//
//  NetworkMonitor.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/13/23.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    @Published var networkOutput = ""
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            RunLoop.main.perform {
                self.networkOutput = NetworkFunctions.updateNetworkInfo() ?? ""
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
