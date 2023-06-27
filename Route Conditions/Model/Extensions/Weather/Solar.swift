//
//  TimeData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension Solar {
    var daylightSymbolName: String? {
        guard let isDaylight else { return nil }
        return isDaylight ? "sun.max" : "moon.stars"
    }
    
    var title: String? {
        guard let isDaylight else { return nil }
        return isDaylight ? NSLocalizedString("Day", comment: "") : NSLocalizedString("Night", comment: "")
    }
}

extension Solar: Equatable {
    static func == (lhs: Solar, rhs: Solar) -> Bool {
        lhs.isDaylight == rhs.isDaylight
    }
}

extension Solar: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(isDaylight)
    }
}
