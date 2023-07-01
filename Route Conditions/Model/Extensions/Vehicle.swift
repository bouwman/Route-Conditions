//
//  Vehicle.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension Measurement<Dimension> {
    func formatted(unit: Dimension) -> String {
        formatter.string(from: self.converted(to: unit))
    }
}

extension Measurement<UnitSpeed> {
    func formatted(unit: UnitSpeed) -> String {
        formatter.string(from: self.converted(to: unit))
    }
}

extension Vehicle {
    var speedRange: ClosedRange<Int> {
        return type.speedRange(unit: unit)
    }
    
    var speedFormatted: String {
        return formatter.string(from: speed.converted(to: unit))
    }
    
    var step: Double {
        return type.step(unit: unit)
    }
}

extension Vehicle: Equatable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.type == rhs.type
    }
}

extension Vehicle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}
