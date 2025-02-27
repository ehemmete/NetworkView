//
//  ContentView.swift
//  NetworkView
//
//  Created by Eric Hemmeter on 6/14/23.
//

import SwiftUI
import CoreLocation

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
    nonisolated func userLocationUpdated(location: CLLocation) {
        //        print("Location Updated")
    }
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("beTranslucent") var beTranslucent = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var networkOutput: NetworkOutput
    @EnvironmentObject var externalIPOutput: ExternalIPOutput
    @State var presentMainAlert = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Text("NetworkView")
                .padding(.top, 6)
                .ignoresSafeArea()
                .bold()
            VStack(alignment: .leading) {
                Text(networkMonitor.isConnected ? networkOutput.displayOutput : "No network connection")
                    .textSelection(.enabled)
                    .font(useMonospaced ? .system(size: CGFloat(fontSize)).monospaced() : .system(size: CGFloat(fontSize)))
                    .fixedSize()
                Text(networkMonitor.isConnected ? externalIPOutput.externalIPDisplay : "No external IP address")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NetworkOutput(displayOutput:
"""
Thunderbolt Ethernet Slot 2: 172.21.21.104
Wi-Fi: 172.21.21.140
Sneakypockets / 157@5GHz-40MHz wide
ipsec0: 17.234.159.169
"""
                                            ))
            .environmentObject(ExternalIPOutput(externalIPDisplay: "No External IP"))
            .environmentObject(NetworkMonitor())
    }
}
