//
//  Enums.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

enum VehicleType: String, Codable {
    case plane
    case car
    case truck
    case speedboat
    case sailboat
    case bicycle
}

enum WeatherParameter: Equatable {
    case wind
    case current
    case waves
    case conditions
    case time
}
