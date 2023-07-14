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
        guard let speed = speed?.converted(to: .knots).value else { return .gray}
        
        return Color.from(value: speed, range: 0...9, minHue: 100)
    }
}
