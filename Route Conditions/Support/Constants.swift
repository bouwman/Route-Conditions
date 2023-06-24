//
//  Constants.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 09.06.23.
//

import Foundation
import UniformTypeIdentifiers

enum Constants {
    static let name = String(localized: "Route Conditions")
    static let earthRadius = 6371000.0 // meters
    
    static let documentType = UTType(exportedAs: "com.tassilobouwman.Route-Conditions")
    
    enum Network {
        static let timeout: TimeInterval = 5.0
    }
}
