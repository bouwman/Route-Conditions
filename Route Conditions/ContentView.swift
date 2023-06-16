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
                    context.insert(route)
                }
            }
        }

    }
}
