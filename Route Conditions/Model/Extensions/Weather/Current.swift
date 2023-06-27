//
//  CurrentData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

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
