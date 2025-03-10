# NetworkView
A SwiftUI network connection and info monitor  
![Translucent Dark NetworkView window](./images/Translucent-Dark.png?raw=true? "NetworkView Window")   
Built completely with Swift and SwiftUI, this is an updated version of my [old app](https://github.com/ehemmete/NetworkInfoGUI).  
Thanks to MacTroll for helping me get the updates on network change working.  
External IP can now come from https://icanhazip.com/ or https://www.mapper.ntppool.org/json
  
Starting in macOS 14, reading the current SSID requires Location Services access.  NetworkView will prompt for this access on first launch.  If you decline, the SSID will always report as "Unavailable".  This access can be changed at any time in System Settings -> Privacy & Security -> Location Services (click the location icon in NetworkView Settings).  NetworkView does not collect any location data, but needs the access to display the SSID.  
![Settings window](./images/Settings.png?raw=true?)
