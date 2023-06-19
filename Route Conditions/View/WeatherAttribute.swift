//
//  WeatherAttribute.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.06.23.
//

import Foundation

enum WeatherAttribute: Identifiable {
    case wind
    case current
    case waves
    case conditions
    case time
    
    static var all: [WeatherAttribute] {
        [.wind, .current, .waves, .conditions, .time]
    }
    
    var string: String {
        switch self {
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
    
    var id: Self {
        return self
    }
}
