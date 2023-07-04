//
//  MemoryModel.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 27.06.23.
//

import Foundation
import CoreLocation
import SwiftUI

@Observable class Vehicle: Identifiable {
    let type: VehicleType
    var speed: Measurement<UnitSpeed> = .init(value: 90, unit: .kilometersPerHour)
    var unit: UnitSpeed = .kilometersPerHour
    var id: VehicleType { return type }
    
    init(averageSpeed: Measurement<UnitSpeed>, type: VehicleType = .car, unit: UnitSpeed = .kilometersPerHour) {
        self.type = type
        self.speed = averageSpeed
        self.unit = unit        
    }
}

@Observable class CustomWaypoint: HasCoordinate, Identifiable {
    var id = UUID()
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var position: Int = 0
    
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0), position: Int) {
        self.coordinate = coordinate
        self.position = position
    }
}

@Observable class WeatherWaypoint: HasCoordinate, Identifiable {
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

@Observable class Weather {
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var date: Date = Date()
    var temperature = Temperature()
    var wind = Wind()
    var current = Current()
    var waves = Wave()
    var conditions = Conditions()
    var solar = Solar()
    
    init(coordinate: CLLocationCoordinate2D, convertible: WeatherModelConvertible) {
        self.coordinate = coordinate
        self.date = convertible.convertedDate
        self._temperature = Temperature(date: date, air: .optional(value: convertible.convertableTemperatureAir, unit: .celsius), water: .optional(value: convertible.convertableTemperatureWater, unit: .celsius), symbolName: convertible.convertedConditionsSymbol)
        self._wind = Wind(date: date, direction: .optional(value: convertible.convertedWindDirection, unit: .degrees), speed: .optional(value: convertible.convertedWindSpeed, unit: .kilometersPerHour), gust: .optional(value: convertible.convertedWindGust, unit: .kilometersPerHour))
        self._current = Current(date: date, direction: .optional(value: convertible.convertedCurrentDirection, unit: .degrees), speed: .optional(value: convertible.convertedCurrentSpeed, unit: .kilometersPerHour))
        self._waves = Wave(date: date, direction: .optional(value: convertible.convertedWaveDirection, unit: .degrees), height: .optional(value: convertible.convertedWaveHeight, unit: .meters))
        self._conditions = Conditions(date: date, title: convertible.convertedConditionsTitle, symbolName: convertible.convertedConditionsSymbol)
        self._solar = Solar(date: date, isDaylight: convertible.convertedSolarIsDaylight)
    }
    
    init() { }
}

@Observable class Conditions {
    var date: Date = Date()
    var title: String? = nil
    var symbolName: String? = nil
    
    init(date: Date = Date(), title: String? = nil, symbolName: String? = nil) {
        self.date = date
        self.title = title
        self.symbolName = symbolName
    }
}

@Observable class Temperature: Identifiable {
    var date: Date = Date()
    var air: Measurement<UnitTemperature>? = nil
    var water: Measurement<UnitTemperature>? = nil
    var symbolName: String? = nil
    var id: Date { return date }
    
    init(date: Date = Date(), air: Measurement<UnitTemperature>? = nil, water: Measurement<UnitTemperature>? = nil, symbolName: String? = nil) {
        self.date = date
        self.air = air
        self.water = water
        self.symbolName = symbolName
    }
}

@Observable class Wind: Identifiable, Directional {
    var date: Date = Date()
    var direction: Measurement<UnitAngle>? = nil
    var speed: Measurement<UnitSpeed>? = nil
    var gust: Measurement<UnitSpeed>? = nil
    var id: Date { return date }
    
    init(date: Date = Date(), direction: Measurement<UnitAngle>? = nil, speed: Measurement<UnitSpeed>? = nil, gust: Measurement<UnitSpeed>? = nil) {
        self.date = date
        self.direction = direction
        self.speed = speed
        self.gust = gust
    }
}

@Observable class Current: Identifiable, Directional {
    var date: Date = Date()
    var direction: Measurement<UnitAngle>? = nil
    var speed: Measurement<UnitSpeed>? = nil
    var id: Date { return date }
    
    init(date: Date = Date(), direction: Measurement<UnitAngle>? = nil, speed: Measurement<UnitSpeed>? = nil) {
        self.date = date
        self.direction = direction
        self.speed = speed
    }
}

@Observable class Wave: Identifiable, Directional {
    var date: Date = Date()
    var direction: Measurement<UnitAngle>? = nil
    var height: Measurement<UnitLength>? = nil
    var id: Date { return date }
    
    init(date: Date = Date(), direction: Measurement<UnitAngle>? = nil, height: Measurement<UnitLength>? = nil) {
        self.date = date
        self.direction = direction
        self.height = height
    }
}

@Observable class Solar {
    var date: Date = Date()
    var isDaylight: Bool? = nil
    
    init(date: Date = Date(), isDaylight: Bool? = nil) {
        self.date = date
        self.isDaylight = isDaylight
    }
}
