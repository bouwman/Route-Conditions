//
//  StormGlass.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import StormGlass

let timeConverter = ISO8601DateFormatter()

extension Paths.Point.GetResponse.Hour: WeatherModelConvertible {
    var convertedDate: Date {
        guard let time else { fatalError("Weather data without time") }
        guard let date = timeConverter.date(from: time) else { fatalError("Weather data unexpected time format") }
        
        return date
    }
    
    var convertedWindSpeed: Double? {
        nil
    }
    
    var convertedWindDirection: Double? {
        nil
    }
    
    var convertedWindGust: Double? {
        nil
    }
    
    var convertedWaveHeight: Double? {
        guard let dict = waveHeight else { return nil }
        guard let value = dict["sg"] else { return nil }
        return Double(value)
    }
    
    var convertedWaveDirection: Double? {
        guard let dict = waveDirection else { return nil }
        guard let value = dict["sg"] else { return nil }
        return Double(value)
    }
    
    var convertedCurrentSpeed: Double? {
        guard let dict = currentSpeed else { return nil }
        guard let value = dict["sg"] else { return nil }
        return Double(value)
    }
    
    var convertedCurrentDirection: Double? {
        guard let dict = currentDirection else { return nil }
        guard let value = dict["sg"] else { return nil }
        return Double(value)

    }
    
    var convertedConditionsTitle: String? {
        nil
    }
    
    var convertedConditionsSymbol: String? {
        nil
    }
    
    var convertedTimeIsDaylight: Bool? {
        nil
    }
}
