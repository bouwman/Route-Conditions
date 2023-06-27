//
//  MemoryModel.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 27.06.23.
//

import Foundation
import CoreLocation
import SwiftUI

@Observable struct CustomWaypoint: HasCoordinate, Identifiable {
    var id = UUID()
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var position: Int = 0
    
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0), position: Int) {
        self.coordinate = coordinate
        self.position = position
    }
}

@Observable struct WeatherWaypoint: HasCoordinate, Identifiable {
    var id = UUID()
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var position: Int = 0
    var date = Date()
    
    /// Make sure the weather is always ordered by date
    var weather: [Weather] = []
    
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0), position: Int, date: Date = Date(), weather: [Weather] = []) {
        self.coordinate = coordinate
        self.position = position
        self.date = date
        self.weather = weather
    }
}

@Observable struct Weather {
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var date: Date = Date()
    var wind = Wind()
    var current = Current()
    var waves = Wave()
    var conditions = Conditions()
    var solar = Solar()
    
    init(coordinate: CLLocationCoordinate2D, convertible: WeatherModelConvertible) {
        self.coordinate = coordinate
        self.date = convertible.convertedDate
        self._wind = Wind(direction: .optional(value: convertible.convertedWindDirection, unit: .radians), speed: .optional(value: convertible.convertedWindSpeed, unit: .kilometersPerHour), gust: .optional(value: convertible.convertedWindGust, unit: .kilometersPerHour))
        self._current = Current(direction: .optional(value: convertible.convertedCurrentDirection, unit: .radians), speed: .optional(value: convertible.convertedCurrentSpeed, unit: .kilometersPerHour))
        self._waves = Wave(direction: .optional(value: convertible.convertedWaveDirection, unit: .radians), height: .optional(value: convertible.convertedWaveHeight, unit: .meters))
        self._conditions = Conditions(title: convertible.convertedConditionsTitle, symbolName: convertible.convertedConditionsSymbol)
        self._solar = Solar(isDaylight: convertible.convertedSolarIsDaylight)
    }
    
    init() { }
}

@Observable struct Conditions {
    var title: String? = nil
    var symbolName: String? = nil
    
    init(title: String? = nil, symbolName: String? = nil) {
        self.title = title
        self.symbolName = symbolName
    }
}

@Observable struct Wind: Directional {
    var direction: Measurement<UnitAngle>? = nil
    var speed: Measurement<UnitSpeed>? = nil
    var gust: Measurement<UnitSpeed>? = nil
    
    init(direction: Measurement<UnitAngle>? = nil, speed: Measurement<UnitSpeed>? = nil, gust: Measurement<UnitSpeed>? = nil) {
        self.direction = direction
        self.speed = speed
        self.gust = gust
    }
}

@Observable struct Current: Directional {
    var direction: Measurement<UnitAngle>? = nil
    var speed: Measurement<UnitSpeed>? = nil
    
    init(direction: Measurement<UnitAngle>? = nil, speed: Measurement<UnitSpeed>? = nil) {
        self.direction = direction
        self.speed = speed
    }
}

@Observable struct Wave: Directional {
    var direction: Measurement<UnitAngle>? = nil
    var height: Measurement<UnitLength>? = nil
    
    init(direction: Measurement<UnitAngle>? = nil, height: Measurement<UnitLength>? = nil) {
        self.direction = direction
        self.height = height
    }
}

@Observable struct Solar {
    var isDaylight: Bool? = nil
    
    init(isDaylight: Bool? = nil) {
        self.isDaylight = isDaylight
    }
}
