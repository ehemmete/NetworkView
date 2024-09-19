//
//  NetworkMonitor.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/13/23.
//

import Foundation
import Network

final class NetworkMonitor: ObservableObject, Sendable {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            RunLoop.main.perform {
                print("Network Changed")
                do {
                    try networkOutput.updateOutput(newOutput: NetworkWorkflow.updateNetworkInfo(path: path) ?? "")
                } catch {
                    print(error)
                }
                Task {
                    do {
                        try await externalIPOutput.udpateExternalIPOutput(newOutput: NetworkWorkflow.getExternalIP())
                    } catch {
                        print(error)
                    }
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}

