//
//  WeatherKit.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import WeatherKit

extension WeatherKit.HourWeather: WeatherModelConvertible {
    var convertedDate: Date {
        date
    }
    
    var convertedWindSpeed: Double? {
        wind.speed.converted(to: .kilometersPerHour).value
    }
    
    var convertedWindDirection: Double? {
        wind.direction.converted(to: .degrees).value
    }
    
    var convertedWindGust: Double? {
        wind.gust?.converted(to: .kilometersPerHour).value
    }
    
    var convertedWaveHeight: Double? {
        nil
    }
    
    var convertedWaveDirection: Double? {
        nil
    }
    
    var convertedCurrentSpeed: Double? {
        nil
    }
    
    var convertedCurrentDirection: Double? {
        nil
    }
    
    var convertedConditionsTitle: String? {
        condition.description
    }
    
    var convertedConditionsSymbol: String? {
        symbolName
    }
    
    var convertedSolarIsDaylight: Bool? {
        isDaylight
    }
}

extension WeatherKit.DayWeather: WeatherModelConvertible {
    var convertedDate: Date {
        date
    }
    
    var convertedWindSpeed: Double? {
        wind.speed.converted(to: .kilometersPerHour).value
    }
    
    var convertedWindDirection: Double? {
        wind.direction.converted(to: .degrees).value
    }
    
    var convertedWindGust: Double? {
        wind.gust?.converted(to: .kilometersPerHour).value
    }
    
    var convertedWaveHeight: Double? {
        nil
    }
    
    var convertedWaveDirection: Double? {
        nil
    }
    
    var convertedCurrentSpeed: Double? {
        nil
    }
    
    var convertedCurrentDirection: Double? {
        nil
    }
    
    var convertedConditionsTitle: String? {
        condition.description
    }
    
    var convertedConditionsSymbol: String? {
        symbolName
    }
    
    var convertedSolarIsDaylight: Bool? {
        nil
    }
}
