//
//  ContentView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.05.23.
//

import SwiftUI
import WeatherKit
import CoreLocation
import MapKit
import SwiftData

struct ContentView: View {
    
    @Query(sort: \.name, order: .forward) private var routes: [Route]
    @Environment(\.modelContext) var context
    
    var body: some View {
        NavigationStack {
            List(routes) { route in
                NavigationLink {
                    RouteView(route: route)
                } label: {
                    Text(route.name)
                }
            }
            .toolbar {
                Button("Add") {
                    let route = Route(name: "New Route")
                    
                    let london = Waypoint(latitude: 51.5074, longitude: -0.1278, time: Date())
                    let manchester = Waypoint(latitude: 53.4808, longitude: -2.2426, time: Date())
                    let edinburgh = Waypoint(latitude: 55.9533, longitude: -3.1883, time: Date())
                    
                    route.waypoints = [london, manchester, edinburgh]
                    
                    context.insert(route)
                }
            }
        }

    }
}
