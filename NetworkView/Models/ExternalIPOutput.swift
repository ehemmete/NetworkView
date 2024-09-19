//
//  ExternalIPOutput.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/18/24.
//

import Foundation
import Network
import CoreWLAN

var externalIPOutput = ExternalIPOutput(externalIPDisplay: "Loading")

final class ExternalIPOutput: ObservableObject {
    @Published var externalIPDisplay: String
    
    init(externalIPDisplay: String) {
        self.externalIPDisplay = externalIPDisplay
    }
    
    func udpateExternalIPOutput(newOutput: String) {
        self.externalIPDisplay = newOutput
    }
}
