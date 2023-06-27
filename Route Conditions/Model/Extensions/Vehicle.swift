//
//  Vehicle.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension Vehicle {
    func updateSpeedUsingString() {
        speed = Measurement(value: Double(speedString) ?? 1.0, unit: self.unit)
    }
    
    var speedRange: ClosedRange<Double> {
        return type.speedRange(unit: unit)
    }
    
    var step: Double {
        return type.step(unit: unit)
    }
}


extension Vehicle: Equatable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.id == rhs.id && lhs.id == rhs.id
    }
}

extension Vehicle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
