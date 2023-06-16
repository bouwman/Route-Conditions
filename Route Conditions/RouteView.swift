//
//  RouteView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 15.06.23.
//

import SwiftUI
import CoreLocation
import MapKit
import SwiftData

struct RouteView: View {
    var route: Route
    
    @Environment(\.modelContext) var context
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: Waypoint?
    
    private var centerCoordinate: CLLocationCoordinate2D {
        return position.camera?.centerCoordinate ?? position.fallbackPosition?.camera?.centerCoordinate ?? position.region?.center ?? position.rect?.origin.coordinate ?? CLLocationCoordinate2D(latitude: 37, longitude: -122)
    }
        
    private var routeCalculationService = RouteCalculationService()
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(route.waypoints) { waypoint in
                Marker("", systemImage: "wind", coordinate: waypoint.coordinate)
            }
            if let predictedWaypoints = route.predictedWaypoints {
                MapPolyline(coordinates: predictedWaypoints.coordinates)
            }
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Clear") {
                    route.waypoints = []
                    route.predictedWaypoints = []
                    do { try context.save() } catch { print(error) }
                }
                Spacer()
                Button("Add") {
                    let waypoint = Waypoint(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    route.waypoints.append(waypoint)
                }
            }
            ToolbarItem(placement: .navigation) {
                Button("Calculate") {
                    route.predictedWaypoints = routeCalculationService.calculateRoute(vehicle: Vehicle(), inputRoute: route.waypoints, departureTime: Date(), timeInterval: 60 * 60)
                }
            }
        }
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    init(route: Route) {
        self.route = route
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020), latitudinalMeters: 750, longitudinalMeters: 750)
        self._position = State(initialValue: MapCameraPosition.region(region))
    }
}
