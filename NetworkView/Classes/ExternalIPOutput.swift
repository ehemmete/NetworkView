//
//  ExternalIPOutput.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/18/24.
//

import Foundation

let externalIPOutput = ExternalIPOutput(externalIPDisplay: "Loading")

final class ExternalIPOutput: ObservableObject, Sendable {
    @Published var externalIPDisplay: String = "Loading"
    
    init(externalIPDisplay: String) {
        self.externalIPDisplay = externalIPDisplay
    }
    
    func updateExternalIPOutput(newOutput: String) {
        self.externalIPDisplay = newOutput
    }
}
