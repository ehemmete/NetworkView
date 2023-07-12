//
//  LocationController.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 7/11/23.
//

import Foundation
import CoreLocation

protocol CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation)
}
class LocationServices: NSObject, CLLocationManagerDelegate, ObservableObject {
    public static let shared = LocationServices()
    var userLocationDelegate: CustomUserLocationDelegate?
    let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Changed")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization Changed")
        networkOutput.updateOutput(newOutput: NetworkFunctions.updateNetworkInfo() ?? "")
    }
}
