//
//  WeatherData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension WeatherData {
    
    var timeString: String {
        dateFormatterTimeShort.string(from: date)
    }
}

let dateFormatterTimeShort: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()
