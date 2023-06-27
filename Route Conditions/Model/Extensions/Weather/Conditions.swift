//
//  Conditions.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 27.06.23.
//

import Foundation

extension Conditions: Equatable {
    static func == (lhs: Conditions, rhs: Conditions) -> Bool {
        lhs.title == rhs.title
    }
}

extension Conditions: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
