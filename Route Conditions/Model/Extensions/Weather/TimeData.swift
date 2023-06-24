//
//  TimeData.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

extension TimeData {
    var daylightSymbolName: String? {
        guard let isDaylight else { return nil }
        return isDaylight ? "sun.max" : "moon.stars"
    }
    
    var title: String? {
        guard let isDaylight else { return nil }
        return isDaylight ? NSLocalizedString("Day", comment: "") : NSLocalizedString("Night", comment: "")
    }
}
