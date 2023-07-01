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
        switch temp {
        case -1000..<0:
            return .cyan
        case 0..<15:
            return .blue
        case 15..<25:
            return .yellow
        case 25..<30:
            return .orange
        case 30..<40:
            return .red
        case 40..<50:
            return .brown
        case 50..<60:
            return .pink
        case 60..<70.0:
            return .purple
        case 70..<100.0:
            return .indigo
        default:
            fatalError("Wave hight speed out of range")
        }
    }
}
