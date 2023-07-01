//
//  WeatherAttribute.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.06.23.
//

import Foundation

extension WeatherParameter {
    static var all: [WeatherParameter] {
        [.conditions, .temperature, .wind, .time, .current, .waves]
    }
    
    var string: String {
        switch self {
        case .temperature:
            NSLocalizedString("Temperature", comment: "")
        case .wind:
            NSLocalizedString("Wind", comment: "")
        case .current:
            NSLocalizedString("Current", comment: "")
        case .waves:
            NSLocalizedString("Waves", comment: "")
        case .conditions:
            NSLocalizedString("Conditions", comment: "")
        case .time:
            NSLocalizedString("Time", comment: "")
        }
    }
    
    var imageName: String {
        switch self {
        case .temperature:
            "thermometer.medium"
        case .wind:
            "wind"
        case .current:
            "water.waves"
        case .waves:
            "figure.surfing"
        case .conditions:
            "cloud.sun"
        case .time:
            "moon"
        }
    }
}

extension WeatherParameter: Identifiable {
    var id: Self {
        return self
    }
}
