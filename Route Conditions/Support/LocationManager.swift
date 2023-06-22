//
//  LocationManager.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.05.23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var userLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    // We just want the weather, so hundred meters accruacy should be good.
    static let shared = LocationManager(accuracy: kCLLocationAccuracyBest)
    
    init(accuracy: CLLocationAccuracy) {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = accuracy
    }
    
    func requestPermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        #if os(macOS)
        if manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorized {
            self.locationManager.requestLocation()
        }
        #elseif os(xrOS)
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager.requestLocation()
        }
        #else
        if manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager.requestLocation()
        }
        #endif
    }
    
}
