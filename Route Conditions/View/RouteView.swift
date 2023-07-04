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
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @State private var customWaypoints: [CustomWaypoint] = []
    @State private var weatherWaypoints: [WeatherWaypoint] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: WeatherWaypoint?
    @State private var weatherParameter: WeatherParameter = .conditions
    @State private var vehicle = Vehicle.sample()
    @State private var isLoadingWeather = false
    @State private var departureTime: Date = Date()
    @State private var departureTimeStep: Int = 1
    @State private var showVehicleEditor: Bool = false
    @State private var showRegularInspector: Bool = false
    @State private var centerCoordinate = CLLocationCoordinate2DMake(0, 0)
    
    private var showCompactInspector: Binding<Bool> { Binding(get: { weatherWaypoints.count != 0 }, set: { _ in }) }
    private let routeCalculationService = RouteCalculationService.shared
    private let weatherService = WeatherService.shared
    private let log = OSLog.ui
    private var hasNoWeatherData: Bool { weatherWaypoints.first?.currentWeather == nil }
    
    var body: some View {
        ZStack(alignment: .center) {
            Map(position: $position, selection: $selectedWaypoint) {
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
            .inspector(isPresented: sizeClass == .compact ? showCompactInspector : $showRegularInspector) {
                ChartView(weatherWaypoints: $weatherWaypoints)
                    .presentationDetents([.height(200), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationBackground(alignment: .bottom) { // TODO: Doesn't work. Check with new release
                        DateSlider(date: $departureTime, range: Date.threeDaysFromToday, height: 40)
                            .frame(maxWidth: 400)
                            .padding()
                    }
            }
            Rectangle()
                .fill(.primary)
                .frame(width: 2, height: 12, alignment: .center)
            Rectangle()
                .fill(.primary)
                .frame(width: 12, height: 2, alignment: .center)
        }
        .toolbar {
            ToolbarItem(id: "vehicle", placement: .secondaryAction) {
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
            ToolbarItem(id: "departure_date", placement: .bottomBar) {
                DateSlider(date: $departureTime, range: Date.threeDaysFromToday, height: 40)
                    .frame(maxWidth: 400)
                    .padding()
                    .onChange(of: departureTime) {
                        updateWeatherWaypoints()
                    }
            }
            WeatherBarItem(weatherParameter: $weatherParameter)
            if sizeClass == .regular {
                ToolbarItem(id: "inspector", placement: .primaryAction) {
                    Button {
                        showRegularInspector.toggle()
                    } label: {
                        Label("Charts", systemImage: "chart.bar")
                    }
                    .disabled(hasNoWeatherData)
                }
            }
            ToolbarItem(id: "update_weather", placement: .secondaryAction) {
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
        .onChange(of: weatherWaypoints) { oldValue, newValue in
            if oldValue.count == 0 && newValue.count > 0 {
                showRegularInspector = true
            } else if oldValue.count > 0 && newValue.count == 0 {
                showRegularInspector = false
            }
        }
        .onAppear {
            prepareView()
        }
        .task(priority: .userInitiated) {
            await loadStoredData()
        }
        .onDisappear {
            // TODO: Crashes
            // save()
        }
    }
    
    private func prepareView() {
        LocationManager.shared.requestPermission()
    }
    
    private func loadStoredData() async {
#if !targetEnvironment(simulator)
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
#else
        customWaypoints = CustomWaypoint.route
        weatherWaypoints = WeatherWaypoint.createWeatherWaypoints()
#endif
    }
    
    private func updateWeatherWaypoints() {
#if !targetEnvironment(simulator)
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
#endif
    }
    
    private func downloadWeather(from service: WeatherServiceType) {
#if !targetEnvironment(simulator)
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
#endif
    }
    
    private func addWaypoint() {
        let waypoint = CustomWaypoint(coordinate: centerCoordinate, position: customWaypoints.count + 1)
        customWaypoints.append(waypoint)
    }
    
    private func removeLastWaypoint() {
        if customWaypoints.count > 0 {
            customWaypoints.removeLast()
        }
    }
    
    private func save() {
#if !targetEnvironment(simulator)
        Task(priority: .utility) {
            do {
                let persistence = BackgroundPersistence(container: context.container)
                try await persistence.store(customWaypoints: weatherWaypoints)
                try await persistence.store(weatherWaypoints: weatherWaypoints)
                
                // Not sure if this is needed
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
#endif
    }
}

#Preview {
    ContentView()
}

/*
 @MainActor
 let previewContainer: ModelContainer = {
 do {
 let container = try ModelContainer(for: [WeatherWaypointData.self, CustomWaypointData.self, WeatherData.self, WindData.self, WaveData.self, CurrentData.self, SolarData.self], ModelConfiguration(inMemory: true))
 return container
 } catch {
 fatalError("Failed to create container")
 }
 }()
 */
