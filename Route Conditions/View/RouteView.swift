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
import OSLog

@MainActor struct RouteView: View {
    
    @Query(sort: \.position, order: .forward) private var waypoints: [CustomWaypoint]
    @Query(sort: \.position, order: .forward) private var predictedWaypoints: [WeatherWaypoint]
    
    @Environment(\.modelContext) var context
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: WeatherWaypoint?
    
    @State private var selectedWeatherAttribute: WeatherParameter = .wind
    
    @State private var vehicle = Vehicle(name: "My Vehicle", averageSpeed: .init(value: 90, unit: .kilometersPerHour), type: .car)
    @State private var isVehicleInspectorOpen = false
    
    @State private var isLoadingWeather = false
    
    private let routeCalculationService = RouteCalculationService.shared
    private let weatherService = RouteWeatherService.shared
    
    private let log = OSLog.ui
    
    private var showInspector: Binding<Bool> {
        Binding { selectedWaypoint != nil } set: { newValue in selectedWaypoint = nil }
    }
        
    private var centerCoordinate: Binding<CLLocationCoordinate2D> {
        Binding(get: { position.camera?.centerCoordinate ?? position.fallbackPosition?.camera?.centerCoordinate ?? position.region?.center ?? position.rect?.origin.coordinate ?? CLLocationCoordinate2D.random() }, set: { _ in } )
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedWaypoint) {
                UserAnnotation()
                ForEach(predictedWaypoints) { waypoint in
                    WeatherMarker(weatherAttribute: $selectedWeatherAttribute, coordinate: waypoint.coordinate, weather: waypoint.currentWeather)
                }
                ForEach(waypoints) { waypoint in
                    Annotation("", coordinate: waypoint.coordinate) {
                        Circle().fill(.accent).frame(width: 10, height: 10, alignment: .center)
                    }
                }
            }
            .mapStyle(.standard(elevation: .automatic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
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
            .sheet(item: $selectedWaypoint) {
                selectedWaypoint = nil
            } content: { waypoint in
                WeatherDetailView(waypoint: waypoint)
            }
            .inspector(isPresented: showInspector) {
                if let selectedWaypoint {
                    WeatherDetailView(waypoint: selectedWaypoint)
                        .presentationDetents([.medium, .large])
                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                } else {
                    Text("Inspector opened without waypoint selected")
                }
            }
            .inspector(isPresented: $isVehicleInspectorOpen, content: {
                VehicleForm(vehicle: $vehicle)
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
            Text("\(centerCoordinate.latitude.wrappedValue)")
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    updateWeather()
                } label: {
                    if isLoadingWeather {
                        ProgressView()
                    } else {
                        Text("Get Weather")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            ToolbarItem(id: "calculate", placement: .bottomBar) {
                Button("Calculate") {
                    deletePredictedWaypoints()
                    calculateWaypoints()
                }
                .buttonStyle(.borderedProminent)
            }
            ToolbarItem(id: "add", placement: .bottomBar) {
                Button(action: {
                    addWaypoint()
                }, label: {
                    Label("", systemImage: "plus")
                })
                .buttonStyle(.borderedProminent)
            }
            ToolbarItem(id: "weather_selection", placement: .primaryAction) {
                Picker(selection: $selectedWeatherAttribute) {
                    ForEach(WeatherParameter.all) { attribute in
                        Label(attribute.string, systemImage: attribute.imageName)
                    }
                } label: {
                    Label(selectedWeatherAttribute.string, systemImage: selectedWeatherAttribute.imageName)
                }
            }
            ToolbarItem(id: "vehicle_selection", placement: .primaryAction) {
                Button {
                    isVehicleInspectorOpen.toggle()
                } label: {
                    Label("Edit Vehicle", systemImage: vehicle.type.imageName)
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
        let newWaypoints = routeCalculationService.calculateRoute(vehicle: vehicle, inputRoute: waypoints, departureTime: Date(), timeInterval: 60 * 60 * 3)
        
        for waypoint in newWaypoints {
            context.insert(waypoint)
        }
        // save()
    }
    
    private func updateWeather() {
        isLoadingWeather = true
        log.debug("Start updating weather for \(predictedWaypoints.count) waypoints ...")
        
        for waypoint in predictedWaypoints {
            Task {
                do {
                    let persistence = PersistenceService(container: context.container)
                    let neededData = try await persistence.weatherParametersThatNeedsData(at: waypoint.coordinate)
                    let weatherData = try await weatherService.fetchWeather(parameters: neededData, coordinate: waypoint.coordinate)
                    
                    try await persistence.storeRemoteWeather(data: weatherData, for: waypoint.id)
                } catch {
                    print(error.localizedDescription)
                }
                log.debug("Finished updating \(predictedWaypoints.count) waypoints")
                isLoadingWeather = false
            }
        }
    }
    
    private func deletePredictedWaypoints() {
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
        for waypoint in CustomWaypoint.samplesChannel() {
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
        let container = try ModelContainer(for: [CustomWaypoint.self, WeatherWaypoint.self], ModelConfiguration(inMemory: true))
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
