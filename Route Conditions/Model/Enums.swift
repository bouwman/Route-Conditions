//
//  Enums.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

enum VehicleType: String, Codable {
    case car
    case truck
    case speedboat
    case sailboat
    case bicycle
}

enum WeatherParameter {
    case wind
    case current
    case waves
    case conditions
    case time
}
