//
//  Wave.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import SwiftUI

extension Wave: Equatable {
    static func == (lhs: Wave, rhs: Wave) -> Bool {
        lhs.direction == rhs.direction && lhs.height == rhs.height
    }
}

extension Wave: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(height)
        hasher.combine(direction)
    }
}

extension Wave: ColorScalable {
    var scaleColor: Color {
        guard let height = height?.converted(to: .meters).value else { return .gray}
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
