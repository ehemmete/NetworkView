//
//  NetworkOutput.swift
//  viewUpdateTest
//
//  Created by Eric Hemmeter on 7/12/23.
//

import Foundation

var networkOutput = NetworkOutput(displayOutput: "Loading")

class NetworkOutput: ObservableObject {
    @Published var displayOutput: String
    
    init(displayOutput: String) {
        self.displayOutput = displayOutput
    }
    
    func updateOutput(newOutput: String) {
        self.displayOutput = newOutput
    }
}


