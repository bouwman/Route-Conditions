//
//  Extensions.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 21.05.23.
//

import Foundation
import WeatherKit
import CoreLocation

extension Wind.CompassDirection {
    var imageName: String {
        switch self {
        case .north, .northNortheast, .northNorthwest:
            return "arrow.up"
        case .northeast:
            return "arrow.up.right"
        case .east, .eastNortheast, .eastSoutheast:
            return "arrow.right"
        case .southeast:
            return "arrow.down.right"
        case .south, .southSoutheast, .southSouthwest:
            return "arrow.down"
        case .southwest:
            return "arrow.down.left"
        case .west, .westNorthwest, .westSouthwest:
            return "arrow.left"
        case .northwest:
            return "arrow.up.left"
        }
    }
}

extension CLLocation {
    
    func bearing(to destination: CLLocation) -> CLLocationDegrees {
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()
        let lat2 = destination.coordinate.latitude.toRadians()
        let lon2 = destination.coordinate.longitude.toRadians()
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing.toDegrees()
    }
    
    func destinationLocation(bearing: CLLocationDegrees, distance: CLLocationDistance) -> CLLocation {
        let radius = self.horizontalAccuracy + distance
        let radiansBearing = bearing.toRadians()
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()
        
        let lat2 = asin(sin(lat1) * cos(distance / radius) + cos(lat1) * sin(distance / radius) * cos(radiansBearing))
        let lon2 = lon1 + atan2(sin(radiansBearing) * sin(distance / radius) * cos(lat1), cos(distance / radius) - sin(lat1) * sin(lat2))
        
        return CLLocation(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }
}

extension CLLocationDegrees {
    func toRadians() -> CLLocationDegrees {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> CLLocationDegrees {
        return self * 180.0 / .pi
    }
}

