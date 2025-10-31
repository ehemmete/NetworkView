//
//  NetworkOutput.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/30/25.
//

import Foundation

@Observable class NetworkOutput {
    static let shared = NetworkOutput()
    var output: [NetworkData] = []
    
    private init() {}
    
}


