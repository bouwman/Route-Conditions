//
//  WindData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

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
