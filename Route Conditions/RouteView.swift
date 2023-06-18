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
    
    @Query(sort: \.position, order: .forward) private var waypoints: [CustomWaypoint]
    @Query(sort: \.position, order: .forward) private var predictedWaypoints: [WeatherWaypoint]
    
    @Environment(\.modelContext) var context
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: WeatherWaypoint?
    
    private let routeCalculationService = RouteCalculationService()
    private let weatherService = RouteWeatherService.shared
    
    private var centerCoordinate: Binding<CLLocationCoordinate2D> {
        Binding(get: { position.camera?.centerCoordinate ?? position.fallbackPosition?.camera?.centerCoordinate ?? position.region?.center ?? position.rect?.origin.coordinate ?? CLLocationCoordinate2D(latitude: 53, longitude: 0) }, set: { _ in } )
    }
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()
                Waypoints()
                PredictedWaypoints()
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapScaleView()
                Button {
                    addWaypoint()
                } label: {
                    Label("", systemImage: "plus")
                }
            }
            Text("\(centerCoordinate.latitude.wrappedValue)")
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Clear") {
                    deletePrediction()
                }
            }
            ToolbarItem(id: "calculate", placement: .primaryAction) {
                Button("Calculate") {
                    calculateWaypoints()
                    updateWeather()
                }
            }
        }
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
        .onAppear {
            prepareView()
        }
    }
    
    private func Waypoints() -> some MapContent {
        ForEach(waypoints) { waypoint in
            Marker("", coordinate: waypoint.coordinate)
        }
    }
    
    private func PredictedWaypoints() -> some MapContent {
        ForEach(predictedWaypoints) { waypoint in
            let coordinate = waypoint.coordinate
            if let weather = waypoint.currentWeather {
                if let wind = weather.wind {
                    Marker(wind.speedString, systemImage: wind.compassDirection.imageName, coordinate: coordinate)
                } else if let symbolName = weather.symbolName {
                    Marker("", systemImage: symbolName, coordinate: coordinate)
                } else {
                    Marker("", systemImage: "exclamationmark.triangle", coordinate: coordinate)
                }
            } else {
                Marker("", monogram: "-", coordinate: coordinate)
            }
        }
    }
    
    private func prepareView() {
        if waypoints.count == 0 {
            createSampleRoute()
        }
        
        LocationManager.shared.requestPermission()
        
        if waypoints.count == 0 {
            position = .userLocation(fallback: .automatic)
        } else {
            position = MapCameraPosition.region(waypoints.region)
        }
    }
    
    private func calculateWaypoints() {
        let waypoints = routeCalculationService.calculateRoute(vehicle: Vehicle(), inputRoute: waypoints, departureTime: Date(), timeInterval: 60 * 60 * 5)
        
        for waypoint in waypoints {
            context.insert(waypoint)
        }
        save()
    }
        
    private func updateWeather() {
        for waypoint in predictedWaypoints {
            Task {
                let weatherData = try? await weatherService.weather(coordinate: waypoint.coordinate)
                waypoint.weather = weatherData ?? [WeatherData.sample()]
            }
        }
    }
    
    private func deletePrediction() {
        for waypoint in predictedWaypoints {
            context.delete(waypoint)
        }
        save()
    }
    
    private func addWaypoint() {
        let waypoint = CustomWaypoint(position: waypoints.count + 1, latitude: centerCoordinate.latitude.wrappedValue, longitude: centerCoordinate.longitude.wrappedValue)
        context.insert(waypoint)
        save()
    }
    
    private func createSampleRoute() {
        for waypoint in CustomWaypoint.samples() {
            context.insert(waypoint)
        }
        save()
    }
    
    private func save() {
        do { try context.save() } catch { print(error) }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: [Route.self, CustomWaypoint.self, WeatherWaypoint.self, Vehicle.self], ModelConfiguration(inMemory: true))
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

