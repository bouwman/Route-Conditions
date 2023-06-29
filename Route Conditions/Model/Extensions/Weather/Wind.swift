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
        switch speed {
        case 0..<6:
            return .cyan
        case 6..<16:
            return .green
        case 16..<27:
            return .yellow
        case 27..<40:
            return .orange
        case 40..<55:
            return .red
        case 55..<64:
            return .brown
        case 64..<1000:
            return .indigo
        default:
            fatalError("Wind speed out of range")
        }
    }
}
