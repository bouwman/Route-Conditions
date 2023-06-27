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
    
    @Environment(\.modelContext) private var context: ModelContext
    
    @State private var customWaypoints: [CustomWaypoint] = []
    @State private var weatherWaypoints: [WeatherWaypoint] = []
        
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedWaypoint: WeatherWaypoint?
    
    @State private var selectedWeatherParameter: WeatherParameter = .wind
    
    @State private var vehicle = Vehicle(name: "My Vehicle", averageSpeed: .init(value: 90, unit: .kilometersPerHour), type: .car)
    @State private var isVehicleInspectorOpen = false
    @State private var isLoadingWeather = false
    @State private var departureTime: Date = Date()
    
    private let routeCalculationService = RouteCalculationService.shared
    private let weatherService = RouteWeatherService.shared
    
    private let log = OSLog.ui
    
    private var showInspector: Binding<Bool> {
        Binding { selectedWaypoint != nil } set: { newValue in selectedWaypoint = nil }
    }
        
    private var centerCoordinate: Binding<CLLocationCoordinate2D> {
        Binding(get: { position.camera?.centerCoordinate ?? position.fallbackPosition?.camera?.centerCoordinate ?? position.region?.center ?? position.rect?.origin.coordinate ?? CLLocationCoordinate2D.random() }, set: { _ in } )
    }
    
    private var proxyDepartureTime: Binding<Double> {
        Binding<Double> {
            return departureTime.timeIntervalSince1970
        } set: { newValue, transaction in
            departureTime = Date(timeIntervalSince1970: newValue)
        }

    }
        
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selectedWaypoint) {
                ForEach(customWaypoints) { waypoint in
                    Annotation("", coordinate: waypoint.coordinate) {
                        Circle().fill(.accent).frame(width: 10, height: 10, alignment: .center)
                    }
                }
                ForEach(weatherWaypoints) { waypoint in
                    WeatherMarker(weatherAttribute: $selectedWeatherParameter, coordinate: waypoint.coordinate, time: waypoint.date, weather: waypoint.currentWeather(for: selectedWeatherParameter))
                }
                UserAnnotation()
            }
            .onMapCameraChange {
                print("camera changed")
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
//            .inspector(isPresented: $isVehicleInspectorOpen, content: {
//                VehicleForm(vehicle: $vehicle)
//                    .presentationDetents([.medium, .large])
//                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            //            })
            VStack(alignment: .center) {
                Text("\(centerCoordinate.latitude.wrappedValue)")
                    .foregroundStyle(.primary)
                    .padding()
                    .background(.regularMaterial, in: Capsule())
                Spacer()
                Text("Departure Time")
                DatePicker("Departure Time", selection: $departureTime, in: Date.threeDaysFromToday)
                    .labelsHidden()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                Slider(value: proxyDepartureTime, in: Date.threeDaysFromTodayTimeInterval, step: 60 * 60) { isActive in
                    updateWeatherWaypoints()
                }
                .frame(maxWidth: 300)
                .padding()
            }
            .padding()
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Button {
                    updateWeather()
                } label: {
                    if isLoadingWeather {
                        ProgressView()
                    } else {
                        Label("Update Weather", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            ToolbarItem(id: "calculate", placement: .secondaryAction) {
                Button {
                    updateWeatherWaypoints()
                } label: {
                    Label("Calculate", systemImage: "equal.square")
                }

            }
            ToolbarItem(id: "add", placement: .secondaryAction) {
                Button(action: {
                    addWaypoint()
                }, label: {
                    Label("Add Waypoint", systemImage: "plus")
                })
            }
            ToolbarItem(id: "weather_selection", placement: .primaryAction) {
                Picker(selection: $selectedWeatherParameter) {
                    ForEach(WeatherParameter.all) { attribute in
                        Label(attribute.string, systemImage: attribute.imageName)
                    }
                } label: {
                    Label(selectedWeatherParameter.string, systemImage: selectedWeatherParameter.imageName)
                }
            }
            ToolbarItem(id: "vehicle_selection", placement: .secondaryAction) {
                Button {
                    isVehicleInspectorOpen.toggle()
                    // TODO: Find better case to save (not on disappear)
                    save()
                } label: {
                    Label("Edit Vehicle", systemImage: vehicle.type.imageName)
                }
                .popover(isPresented: $isVehicleInspectorOpen) {
                    VehicleForm(vehicle: $vehicle)
                        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
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
            let persistence = BackgroundPersistenceActor(container: context.container)
            do {
                customWaypoints = try await persistence.loadAllCustomWaypoints()
                weatherWaypoints = try await persistence.loadAllWeatherWaypoints()
                
                if customWaypoints.count == 0 {
                    position = .userLocation(fallback: .automatic)
                    createSampleRoute()
                } else {
                    position = MapCameraPosition.region(customWaypoints.region)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateWeatherWaypoints() {
        weatherWaypoints = routeCalculationService.calculateRoute(vehicle: vehicle, inputRoute: customWaypoints, departureTime: departureTime, timeInterval: 60 * 60 * 1)
    }
    
    private func updateWeather() {
        isLoadingWeather = true
        log.debug("Start updating weather for \(weatherWaypoints.count) customWaypoints ...")
        
        $weatherWaypoints.forEach { waypoint in
            Task(priority: .userInitiated) {
                do {
                    let neededData = try weatherService.weatherParametersThatNeedsData(at: waypoint.coordinate.wrappedValue, existingData: waypoint.weather.wrappedValue)
                    let weather = try await weatherService.fetchWeather(parameters: neededData, coordinate: waypoint.coordinate.wrappedValue)
                    
                    waypoint.weather.wrappedValue = weather
                } catch {
                    print(error.localizedDescription)
                }
                log.debug("Finished updating \(weatherWaypoints.count) customWaypoints")
                isLoadingWeather = false
            }
        }
    }
    
    private func addWaypoint() {
        let waypoint = CustomWaypoint(coordinate: centerCoordinate.wrappedValue, position: customWaypoints.count + 1)
        customWaypoints.append(waypoint)
    }
    
    private func createSampleRoute() {
        customWaypoints = CustomWaypoint.samplesChannel()
    }
    
    private func save() {
        Task(priority: .utility) {
            do {
                let persistence = BackgroundPersistenceActor(container: context.container)
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
