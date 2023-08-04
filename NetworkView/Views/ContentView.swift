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
    func userLocationUpdated(location: CLLocation) {
        //        print("Location Updated")
    }
    @AppStorage("fontSize") var fontSize = 12
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("beTranslucent") var beTranslucent = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var networkOutput: NetworkOutput
    @State var presentMainAlert = false
    
    var body: some View {
        //        let _ = Self._printChanges()
        ZStack(alignment: .top) {
            Text("NetworkView")
                .padding(.top, 6)
                .ignoresSafeArea()
                .bold()
            if networkMonitor.isConnected {
                if useMonospaced {
                    Text(networkOutput.displayOutput)
                        .textSelection(.enabled)
                        .font(.system(size: CGFloat(fontSize)).monospaced())
                        .padding(.horizontal)
                        .fixedSize()
                } else {
                    Text(networkOutput.displayOutput)
                        .textSelection(.enabled)
                        .font(.system(size: CGFloat(fontSize)))
                        .padding(.horizontal)
                        .fixedSize()
                }
            } else {
                if useMonospaced {
                    Text("No network connection")
                        .frame(minWidth: 200)
                        .textSelection(.enabled)
                        .font(.system(size: CGFloat(fontSize)).monospaced())
                        .padding(.horizontal)
                        .fixedSize()
                } else {
                    Text("No network connection")
                        .frame(minWidth: 200)
                        .textSelection(.enabled)
                        .font(.system(size: CGFloat(fontSize)))
                        .padding(.horizontal)
                        .fixedSize()
                }
            }
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
    }
}
