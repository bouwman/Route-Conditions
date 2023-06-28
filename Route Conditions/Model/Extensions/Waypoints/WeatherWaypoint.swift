//
//  WeatherWaypoint.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension WeatherWaypoint {
    
    var currentWeather: Weather? {
        let sort = weather.sorted { $0.date < $1.date }
        let first = sort.first { $0.date.timeIntervalSince(date) > 0 }
        
        return first
    }
    
    func currentWeather(for parameter: WeatherParameter) -> Weather? {
        let first = weather.first { item in
            let isNearTime = item.date.timeIntervalSince(date) > 0
            let isSameCoordinate = item.coordinate == coordinate
            
            var hasParameter = false
            
            switch parameter {
            case .conditions:
                hasParameter = item.conditions.title != nil
            case .wind:
                hasParameter = item.wind.direction != nil && item.wind.speed != nil
            case .current:
                hasParameter = item.current.direction != nil && item.current.speed != nil
            case .waves:
                hasParameter = item.waves.direction != nil && item.waves.height != nil
            case .time:
                hasParameter = item.solar.isDaylight != nil
            }
            
            return isNearTime && isSameCoordinate && hasParameter
        }
        
        return first
    }
    
    var timeString: String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

extension WeatherWaypoint: Equatable {
    static func == (lhs: WeatherWaypoint, rhs: WeatherWaypoint) -> Bool {
        lhs.coordinate == rhs.coordinate && lhs.position == rhs.position
    }
}

extension WeatherWaypoint: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate)
        hasher.combine(position)
    }
}
