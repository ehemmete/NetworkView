//
//  ExternalIPProviders.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/26/24.
//

import Foundation

enum ExternalIPProviders: CaseIterable, Identifiable, CustomStringConvertible, Codable {
    case icanhazip
    case ntppool
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .icanhazip:
            return "icanhazip.com"
        case .ntppool:
            return "mapper.ntppool.org"
        }
    }
    
    var ip: String {
        switch self {
        case .icanhazip:
            return "https://icanhazip.com"
        case .ntppool:
            return "http://www.mapper.ntppool.org/json"
        }
    }
}
