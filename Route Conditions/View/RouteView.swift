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

enum WeatherServiceType: Identifiable {
    case apple
    case stormGlass
    case grib
    
    var all: [WeatherServiceType] {
        [.apple, .stormGlass, .grib]
    }
    
    var id: Self { return self }
}

@MainActor struct RouteView: View {
    
    @Environment(\.modelContext) private var context: ModelContext
    
    @State private var customWaypoints: [CustomWaypoint] = []
    @State private var weatherWaypoints: [WeatherWaypoint] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: WeatherWaypoint?
    @State private var weatherParameter: WeatherParameter = .conditions
    @State private var vehicle = Vehicle.sample()
    @State private var isLoadingWeather = false
    @State private var departureTime: Date = Date()
    @State private var departureTimeStep: Int = 1
    @State private var isEditing: Bool = true
    @State private var showVehicleEditor: Bool = false
    
    private let routeCalculationService = RouteCalculationService.shared
    private let weatherService = WeatherService.shared
    private let log = OSLog.ui
    
    private var showInspector: Binding<Bool> {
        Binding { selectedWaypoint != nil } set: { newValue in selectedWaypoint = nil }
    }
    
    @State private var centerCoordinate = CLLocationCoordinate2DMake(0, 0)
    
    var body: some View {
        ZStack(alignment: .center) {
            Map(position: $position, selection: $selectedWaypoint) {
                //                ForEach(customWaypoints) { waypoint in
                //                    Annotation("", coordinate: waypoint.coordinate) {
                //                        Circle().fill(.accent).frame(width: 10, height: 10, alignment: .center)
                //                    }
                //                }
                MapPolyline(coordinates: customWaypoints.map { $0.coordinate })
                ForEach(weatherWaypoints) { waypoint in
                    WeatherParameterMarker(weatherParameter: $weatherParameter, coordinate: waypoint.coordinate, time: waypoint.date, weather: waypoint.currentWeather(for: weatherParameter))
                }
                UserAnnotation()
            }
            .onMapCameraChange { updateContext in
                centerCoordinate = updateContext.camera.centerCoordinate
            }
            .mapStyle(.standard(elevation: .automatic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapScaleView()
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
            if isEditing {
                Rectangle()
                    .fill(.primary)
                    .frame(width: 2, height: 12, alignment: .center)
                Rectangle()
                    .fill(.primary)
                    .frame(width: 12, height: 2, alignment: .center)
            } else {
                VStack() {
                    Spacer()
                    DateSlider(date: $departureTime, range: Date.threeDaysFromToday, height: 40) { isActive in }
                    .frame(maxWidth: 300)
                    .padding()
                    .onChange(of: departureTime) {
                        updateWeatherWaypoints()
                    }
                }
            }
            VStack {
                Picker("Edit or View", selection: $isEditing) {
                    Text("Edit").tag(true)
                    Text("View").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
                .padding()
                Spacer()
            }
                
        }
        .toolbar {
            if isEditing {
                ToolbarItem(id: "vehicle", placement: .primaryAction) {
                    Menu {
                        Picker(selection: $vehicle) {
                            ForEach(Vehicle.allSamples()) { vehicle in
                                Label(vehicle.type.title, systemImage: vehicle.type.imageName).tag(vehicle)
                            }
                        } label: {
                            Label(vehicle.type.title, systemImage: vehicle.type.imageName)
                        }
                        Button {
                            showVehicleEditor = true
                        } label: {
                            Label("Edit Speed", systemImage: "pencil")
                        }
                    } label: {
                        Label(vehicle.type.title, systemImage: vehicle.type.imageName)
                    }
                }
                ToolbarItem(id: "edit_waypoints", placement: .bottomBar) {
                    HStack(spacing: 8) {
                        Button(action: {
                            addWaypoint()
                            updateWeatherWaypoints()
                        }, label: {
                            Text("Add Waypoint")
                        })
                        .buttonStyle(.borderedProminent)
                        Button(action: {
                            removeLastWaypoint()
                            updateWeatherWaypoints()
                        }, label: {
                            Label("Remove Waypoint", systemImage: "arrow.uturn.backward")
                                .frame(maxHeight: .infinity) // Match other button
                        })
                        .disabled(weatherWaypoints.count == 0)
                        .buttonStyle(.bordered)
                    }
                }
            } else {
                ToolbarItem(id: "update_weather", placement: .primaryAction) {
                    Menu {
                        Button {
                            downloadWeather(from: .apple)
                        } label: {
                            Label("Apple Weather", systemImage: "apple.logo")
                        }
                        Button {
                            downloadWeather(from: .stormGlass)
                        } label: {
                            Label("StormGlass", systemImage: "staroflife")
                        }
                    } label: {
                        if isLoadingWeather {
                            ProgressView()
                        } else {
                            Label("Update Weather", systemImage: "arrow.down.circle")
                        }
                    }
                    .disabled(weatherWaypoints.count == 0)
                }
                WeatherBarItem(weatherParameter: $weatherParameter)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
        .popover(isPresented: $showVehicleEditor) {
            VehicleForm(vehicle: $vehicle)
                .presentationDetents([.medium])
        }
        .onChange(of: vehicle) {
            updateWeatherWaypoints()
            save()
        }
        .onChange(of: vehicle.speed) {
            updateWeatherWaypoints()
        }
        .onAppear {
            prepareView()
        }
        .onDisappear {
            // TODO: Crashes
            // save()
        }
    }
    
    private func prepareView() {
        LocationManager.shared.requestPermission()
        loadStoredData()
    }
    
    private func loadStoredData() {
        Task(priority: .userInitiated) {
            let persistence = BackgroundPersistence(container: context.container)
            do {
                customWaypoints = try await persistence.loadAllCustomWaypoints()
                weatherWaypoints = try await persistence.loadAllWeatherWaypoints()
                
                if customWaypoints.count > 0 {
                    position = MapCameraPosition.region(customWaypoints.region)
                } else {
                    position = .userLocation(fallback: .automatic)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateWeatherWaypoints() {
        let newWaypoints = routeCalculationService.calculateRoute(existingWaypoints: customWaypoints, speed: vehicle.speed.value, unit: vehicle.unit, departureTime: departureTime, timeInterval: Constants.RouteCalculation.interval)
        let newCount = newWaypoints.count
        let existingCount = weatherWaypoints.count
        
        guard newCount != 0 else {
            weatherWaypoints = []
            return
        }
        
        if newCount == existingCount {
            for (i, existing) in weatherWaypoints.enumerated() {
                existing.date = newWaypoints[i].date
                existing.coordinate = newWaypoints[i].coordinate
            }
        } else if newCount > existingCount  {
            for (i, new) in newWaypoints.enumerated() {
                if i < existingCount {
                    weatherWaypoints[i].date = new.date
                    weatherWaypoints[i].coordinate = new.coordinate
                } else {
                    weatherWaypoints.append(new)
                }
            }
        } else if newCount < existingCount {
            for (i, existing) in weatherWaypoints.enumerated() {
                if i < newCount {
                    existing.date = newWaypoints[i].date
                    existing.coordinate = newWaypoints[i].coordinate
                } else {
                    weatherWaypoints.removeLast()
                }
            }
        }
    }
    
    private func downloadWeather(from service: WeatherServiceType) {
        isLoadingWeather = true
        log.debug("Start updating weather for \(weatherWaypoints.count) customWaypoints ...")
        
        Task(priority: .userInitiated) {
            for waypoint in weatherWaypoints {
                do {
                    let neededData = try weatherService.weatherParametersThatNeedsData(at: waypoint.coordinate, existingData: waypoint.weather)
                    let existing = waypoint.weather
                    
                    let new: [Weather]
                    
                    switch service {
                    case .apple:
                        new = try await weatherService.fetchAppleWeather(parameters: neededData, coordinate: waypoint.coordinate)
                    case .stormGlass:
                        new = try await weatherService.fetchStormGlassWeather(parameters: neededData, coordinate: waypoint.coordinate)
                    case .grib:
                        new = []
                    }
                    
                    waypoint.weather = weatherService.merge(data: new + existing)
                } catch {
                    print(error.localizedDescription)
                }
            }
            log.debug("Finished updating \(weatherWaypoints.count) customWaypoints")
            isLoadingWeather = false
        }
    }
    
    private func addWaypoint() {
        let waypoint = CustomWaypoint(coordinate: centerCoordinate, position: customWaypoints.count + 1)
        customWaypoints.append(waypoint)
    }
    
    private func removeLastWaypoint() {
        customWaypoints.removeLast()
    }
    
    private func save() {
        Task(priority: .utility) {
            do {
                let persistence = BackgroundPersistence(container: context.container)
                try await persistence.store(customWaypoints: weatherWaypoints)
                try await persistence.store(weatherWaypoints: weatherWaypoints)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: [CustomWaypointData.self, WeatherWaypointData.self], ModelConfiguration(inMemory: true))
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
