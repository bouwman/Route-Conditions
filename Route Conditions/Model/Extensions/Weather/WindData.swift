//
//  WindData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension WindData: DirectionalData, SpeedableData {
    var gust: Measurement<UnitSpeed>? {
        guard let gustData else { return nil }
        return Measurement(value: gustData, unit: .kilometersPerHour)
    }
}
