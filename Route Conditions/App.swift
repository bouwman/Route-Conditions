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
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Route.self, Waypoint.self, Vehicle.self, WeatherData.self, WindData.self])
        
//        DocumentGroup(viewing: Route.self, contentType: Constants.documentType) {
//            ContentView()
//        }
    }
}
