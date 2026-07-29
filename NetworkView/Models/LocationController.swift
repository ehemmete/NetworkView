//
//  LocationController.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 7/11/23.
//

import Foundation
import CoreLocation
import Network
import SwiftUI

@Observable
class LocationServices: NSObject, CLLocationManagerDelegate {
    public static let shared = LocationServices()
    
    var lastLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastLocation = location
            print("Location Updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization Changed")
    }
}
