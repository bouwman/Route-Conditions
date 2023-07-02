//
//  WindData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import SwiftUI

extension Wind: Equatable {
    static func == (lhs: Wind, rhs: Wind) -> Bool {
        lhs.direction == rhs.direction && lhs.speed == rhs.speed
    }
}

extension Wind: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(speed)
        hasher.combine(direction)
    }
}

extension Wind: ColorScalable {
    var scaleColor: Color {
        guard let speed = speed?.converted(to: .knots).value else { return .gray}
        
        return Color.from(value: speed, range: 0...64, minHue: 211)
    }
}
