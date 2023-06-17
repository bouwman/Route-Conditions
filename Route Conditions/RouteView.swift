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
import WeatherKit

@MainActor struct RouteView: View {
    var route: Route
    
    @Environment(\.modelContext) var context
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: Waypoint?
    
    private var centerCoordinate: CLLocationCoordinate2D {
        return position.camera?.centerCoordinate ?? position.fallbackPosition?.camera?.centerCoordinate ?? position.region?.center ?? position.rect?.origin.coordinate ?? CLLocationCoordinate2D(latitude: 37, longitude: -122)
    }
    
    init(route: Route) {
        self.route = route
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.0, longitude: -3.0), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        self._position = State(initialValue: MapCameraPosition.region(region))
    }
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(route.waypoints) { waypoint in
                Marker("", coordinate: waypoint.coordinate)
            }
            if let predictedWaypoints = route.predictedWaypoints {
                ForEach(predictedWaypoints) { waypoint in
                    if let weather = selectedWaypoint?.currentWeather {
                        if let wind = weather.wind {
                            Marker("\(wind.windSpeed)", systemImage: wind.compassDirection.imageName, coordinate: waypoint.coordinate)
                        } else if let symbolName = weather.symbolName {
                            Marker("", systemImage: symbolName, coordinate: waypoint.coordinate)
                        } else {
                            Marker("", systemImage: "exclamationmark.triangle", coordinate: waypoint.coordinate)
                        }
                    } else {
                        Marker(coordinate: waypoint.coordinate) {
                            ProgressView()
                        }
                    }
                }
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
                    deletePrediction()
                }
                Spacer()
                Button("Add") {
                    addWaypoint()
                }
            }
            ToolbarItem(placement: .navigation) {
                Button("Calculate") {
                    calculateWaypoints()
                    updateWeather()
                }
            }
        }
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private let routeCalculationService = RouteCalculationService()
    
    func calculateWaypoints() {
        route.predictedWaypoints = routeCalculationService.calculateRoute(vehicle: Vehicle(), inputRoute: route.waypoints, departureTime: Date(), timeInterval: 60 * 60 * 5)
    }
    
    private let weatherService = RouteWeatherService.shared
    
    func updateWeather() {
        for waypoint in route.predictedWaypoints {
            Task {
                let weatherData = try! await weatherService.weather(coordinate: waypoint.coordinate, date: waypoint.time ?? Date())
                waypoint.weather = weatherData
            }
        }
    }
    
    func deletePrediction() {
        route.predictedWaypoints = []
        do { try context.save() } catch { print(error) }
    }
    
    func addWaypoint() {
        let waypoint = Waypoint(position: route.waypoints.count, latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        route.waypoints.append(waypoint)
    }
}

enum RouteConditionsError: Error {
    case unknown
}
