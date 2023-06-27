//
//  Constants.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 09.06.23.
//

import Foundation
import UniformTypeIdentifiers
import SwiftData

enum Constants {
    static let name = String(localized: "Route Conditions")
    
    static let documentType = UTType(exportedAs: "com.tassilobouwman.Route-Conditions")
    
    enum RouteCalculation {
        static let interval: TimeInterval = 60 * 60 * 1
        static let earthRadius = 6371.0 // km
    }
    
    enum Network {
        static let timeout: TimeInterval = 5.0
    }
    
    enum Background {
        static let saveIdentifier = "com.tassilobouwman.Route-Conditions.savedata"
    }
}
