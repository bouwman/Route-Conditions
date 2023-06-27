//
//  Weather.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension Weather {
    
    var timeString: String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

extension Weather: Equatable {
    static func == (lhs: Weather, rhs: Weather) -> Bool {
        lhs.conditions == rhs.conditions && lhs.wind == rhs.wind && lhs.waves == rhs.waves && lhs.current == rhs.current && lhs.solar == rhs.solar && lhs.date == rhs.date && lhs.coordinate == rhs.coordinate
    }
}

extension Weather: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate)
        hasher.combine(date)
    }
}

extension Weather: WeatherModelConvertible {
    var convertedDate: Date {
        date
    }
    
    var convertedWindSpeed: Double? {
        wind.speed?.converted(to: .kilometersPerHour).value
    }
    
    var convertedWindDirection: Double? {
        wind.direction?.converted(to: .degrees).value
    }
    
    var convertedWindGust: Double? {
        wind.gust?.converted(to: .kilometersPerHour).value
    }
    
    var convertedWaveHeight: Double? {
        waves.height?.converted(to: .meters).value
    }
    
    var convertedWaveDirection: Double? {
        waves.direction?.converted(to: .degrees).value
    }
    
    var convertedCurrentSpeed: Double? {
        current.speed?.converted(to: .kilometersPerHour).value
    }
    
    var convertedCurrentDirection: Double? {
        current.direction?.converted(to: .degrees).value
    }
    
    var convertedConditionsTitle: String? {
        conditions.title
    }
    
    var convertedConditionsSymbol: String? {
        conditions.symbolName
    }
    
    var convertedSolarIsDaylight: Bool? {
        solar.isDaylight
    }
}

extension WeatherData: WeatherModelConvertible {
    var convertedDate: Date {
        date
    }
    
    var convertedWindSpeed: Double? {
        wind.speedData
    }
    
    var convertedWindDirection: Double? {
        wind.directionData
    }
    
    var convertedWindGust: Double? {
        wind.gustData    }
    
    var convertedWaveHeight: Double? {
        waves.heightData
    }
    
    var convertedWaveDirection: Double? {
        waves.directionData
    }
    
    var convertedCurrentSpeed: Double? {
        current.speedData
    }
    
    var convertedCurrentDirection: Double? {
        current.directionData
    }
    
    var convertedConditionsTitle: String? {
        conditions.title
    }
    
    var convertedConditionsSymbol: String? {
        conditions.symbolName
    }
    
    var convertedSolarIsDaylight: Bool? {
        solar.isDaylight
    }
}

