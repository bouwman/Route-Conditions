//
//  Vehicle.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension Vehicle {
    func updateSpeedUsingUnit() {
        speed = Measurement(value: Double(speedString) ?? 1.0, unit: self.unit)
    }
}
