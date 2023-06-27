//
//  Model+Extensions.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import Foundation
import CoreLocation
import MapKit
import WeatherKit

extension HasLocation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension HasCoordinate {
    var latitude: Double { coordinate.latitude }
    var longitude: Double { coordinate.longitude }
}

extension DirectionalData {
    var direction: Measurement<UnitAngle>? {
        guard let directionData else { return nil }
        return Measurement(value: directionData, unit: .degrees)
    }
}

extension Directional {
    var compassDirection: WeatherKit.Wind.CompassDirection? {
        guard let direction else { return nil }
        return WeatherKit.Wind.CompassDirection.from(degrees: direction.converted(to: .degrees).value)
    }
}

extension SpeedableData {
    var speed: Measurement<UnitSpeed>? {
        guard let speedData else { return nil }
        return Measurement(value: speedData, unit: .kilometersPerHour)
    }
}

extension HeightableData {
    var height: Measurement<UnitLength>? {
        guard let heightData else { return nil }
        return Measurement(value: heightData, unit: .meters)
    }
}
