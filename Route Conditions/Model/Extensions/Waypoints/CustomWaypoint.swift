//
//  CustomWaypoint.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 27.06.23.
//

import Foundation

extension CustomWaypoint: Equatable {
    static func == (lhs: CustomWaypoint, rhs: CustomWaypoint) -> Bool {
        lhs.coordinate == rhs.coordinate && lhs.position == rhs.position
    }
}

extension CustomWaypoint: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate)
        hasher.combine(position)
    }
}
