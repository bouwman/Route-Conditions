//
//  CurrentData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import SwiftUI

extension CurrentData: DirectionalData, SpeedableData {
    
}

extension Current: Equatable {
    static func == (lhs: Current, rhs: Current) -> Bool {
        lhs.direction == rhs.direction && lhs.speed == rhs.speed
    }
}

extension Current: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(speed)
        hasher.combine(direction)
    }
}

extension Current: ColorScalable {
    var scaleColor: Color {
        guard let height = speed?.converted(to: .knots).value else { return .gray}
        switch height {
        case 0..<0.1:
            return .blue
        case 0.1..<0.5:
            return .cyan
        case 0.5..<1.25:
            return .green
        case 1.25..<2.5:
            return .yellow
        case 2.5..<4.0:
            return .orange
        case 4.0..<6.0:
            return .red
        case 6.0..<9.0:
            return .brown
        case 6.0..<9.0:
            return .pink
        case 9.0..<14.0:
            return .purple
        case 9.0..<100.0:
            return .indigo
        default:
            fatalError("Wave hight speed out of range")
        }
    }
}
