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

extension DirectionalData {
    var direction: Measurement<UnitAngle>? {
        guard let directionData else { return nil }
        return Measurement(value: directionData, unit: .degrees)
    }
    var compassDirection: Wind.CompassDirection? {
        guard let directionData else { return nil }
        return Wind.CompassDirection.from(degrees: directionData)
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
