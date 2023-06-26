//
//  WeatherWaypoint.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension WeatherWaypoint {
    
    var currentWeather: WeatherData? {
        let sort = weather.sorted { $0.date < $1.date }
        let first = sort.first { $0.date.timeIntervalSince(time) > 0 }
        
        return first
    }
    
    func currentWeather(for parameter: WeatherParameter) -> WeatherData? {
        let sort = weather.sorted { $0.date < $1.date }
        let first = sort.first { item in
            let isNearTime = item.date.timeIntervalSince(time) > 0
            var hasParameter = false
            
            switch parameter {
            case .conditions:
                hasParameter = item.conditions?.title != nil
            case .wind:
                hasParameter = item.wind?.directionData != nil && item.wind?.speedData != nil
            case .current:
                hasParameter = item.current?.directionData != nil && item.current?.speedData != nil
            case .waves:
                hasParameter = item.waves?.directionData != nil && item.waves?.heightData != nil
            case .time:
                hasParameter = item.timeInfo?.isDaylight != nil
            }
            
            return isNearTime && hasParameter
        }
        
        return first
    }
    
    var timeString: String {
        dateFormatterTimeShort.string(from: time)
    }
}

