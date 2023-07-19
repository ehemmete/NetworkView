//
//  LocationController.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 7/11/23.
//

import Foundation
import CoreLocation
import Network

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
        let queue = DispatchQueue(label: "network.monitor")
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            networkOutput.updateOutput(newOutput: NetworkWorkflow.updateNetworkInfo(path: path) ?? "")
        }
        monitor.start(queue: queue)
//
    }
}
