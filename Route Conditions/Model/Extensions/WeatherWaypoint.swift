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
    
    var timeString: String {
        dateFormatterTimeShort.string(from: time)
    }
}

