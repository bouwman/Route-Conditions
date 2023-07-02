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
        
        return Color.from(value: height, range: 0...9, minHue: 211)
    }
}
