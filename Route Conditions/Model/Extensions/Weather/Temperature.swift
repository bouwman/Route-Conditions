//
//  Temperature.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 01.07.23.
//

import Foundation
import SwiftUI

extension Temperature: Equatable {
    static func == (lhs: Temperature, rhs: Temperature) -> Bool {
        lhs.air == rhs.air && lhs.water == rhs.water
    }
}

extension Temperature: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(air)
        hasher.combine(water)
    }
}

extension Temperature: ColorScalable {
    var scaleColor: Color {
        guard let temp = air?.converted(to: .celsius).value else { return .gray}
        
        return Color.from(value: temp, range: -20...60, minHue: 211)
    }
    
//    static var minHue: Double = 211
//    static let minValue: Double = 0
//    static let maxValue: Double = 50
    
//    static func subGradient(min: Double, max: Double) -> Gradient {
//        let grad: Gradient
//        
//        let lowerColor = (min - minValue) / Double(fullGradient.stops.count)
//        
//        grad.stops
//    }
//    
    static let fullGradient: Gradient = Gradient(colors: [.cyan, .blue, .green, .yellow, .orange, .red])
}
