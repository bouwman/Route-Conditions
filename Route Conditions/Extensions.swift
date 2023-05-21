//
//  Extensions.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 21.05.23.
//

import Foundation
import WeatherKit

extension Wind.CompassDirection {
    var imageName: String {
        switch self {
        case .north, .northNortheast, .northNorthwest:
            return "arrow.up"
        case .northeast:
            return "arrow.up.right"
        case .east, .eastNortheast, .eastSoutheast:
            return "arrow.right"
        case .southeast:
            return "arrow.down.right"
        case .south, .southSoutheast, .southSouthwest:
            return "arrow.down"
        case .southwest:
            return "arrow.down.left"
        case .west, .westNorthwest, .westSouthwest:
            return "arrow.left"
        case .northwest:
            return "arrow.up.left"
        }
    }
}
