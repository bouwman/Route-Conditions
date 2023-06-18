//
//  Route_ConditionsApp.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.05.23.
//

import SwiftUI
import SwiftData

@main
struct RouteConditionsApp: App {
    
    var body: some Scene {
        DocumentGroup(editing: [Route.self, WeatherWaypoint.self, CustomWaypoint.self, Vehicle.self], contentType: Constants.documentType) {
            ContentView()
        }
    }
}
