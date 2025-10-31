//
//  ContentView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 9/30/25.
//

import SwiftUI
import CoreLocation
import CoreWLAN

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        //
    }
}

struct ContentView: View, CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation) {
                print("Location Updated")
    }
    
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("beTranslucent") var beTranslucent = false
    @AppStorage("displaySpeed") var displaySpeed = true
    @AppStorage("displayWifiDetails") var displayWifiDetails = true
    @AppStorage("displayBSSID") var displayBSSID = false

    @Environment(NetworkMonitor.self) var networkMonitor
    @State var presentMainAlert = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Text("NetworkView")
                .padding(.top, 6)
                .ignoresSafeArea()
                .bold()
            VStack(alignment: .leading) {
                    ForEach(NetworkOutput.shared.output) { service in
                        Text("\(service.serviceName): \(service.serviceIP)")
                        if service.speed != nil && service.speed != "" && displaySpeed {
                            Text("  \(service.speed!)")
                        }
                        if service.SSID != nil && displayWifiDetails {
                            let ssid = service.SSID ?? "Unknown"
                            let channel = String(service.channel ?? 0)
                            let band = service.band ?? .bandUnknown
                            let width = service.width ?? .widthUnknown
                            let bssid = service.BSSID ?? "Unknown"
                            
                            Text("  \(ssid) / \(channel)@\(band.description)-\(width.description)")
                            if displayBSSID {                                
                                Text("  BSSID: \(bssid)")
                            }
                        }
                    }
                    .textSelection(.enabled)
                    .font(useMonospaced ? .system(size: CGFloat(fontSize)).monospaced() : .system(size: CGFloat(fontSize)))
                    .fixedSize()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .alert("Please restart NetworkView to apply the change.", isPresented: $presentMainAlert) {
            Button("OK") {}
        }
        .background(beTranslucent ? VisualEffectView().ignoresSafeArea() : nil)
        .onAppear(perform: {
            if LocationServices.shared.locationManager.authorizationStatus == .authorizedAlways {
                LocationServices.shared.userLocationDelegate = self
            } else {
                LocationServices.shared.locationManager.requestAlwaysAuthorization()
            }
        })
    }
}

#Preview {
    ContentView()
}
