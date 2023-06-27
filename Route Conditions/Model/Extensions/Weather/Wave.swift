//
//  Wave.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

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
