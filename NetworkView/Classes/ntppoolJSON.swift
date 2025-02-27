//
//  ntppoolJSON.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 2/27/25.
//

import Foundation

struct ntppoolJSON: Codable {
    var DNS: String
    var EDNS: String
    var HTTP: String
}
