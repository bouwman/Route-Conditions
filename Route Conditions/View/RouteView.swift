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
    
    @State private var vehicle = Vehicle.sample()
    @State private var isLoadingWeather = false
    @State private var departureTime: Date = Date()
    
    private let routeCalculationService = RouteCalculationService.shared
    private let weatherService = WeatherService.shared
    
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
        ZStack(alignment: .top) {
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
            VStack(alignment: .center) {
                Text("\(centerCoordinate.latitude.wrappedValue)")
                    .foregroundStyle(.primary)
                    .padding()
                    .background(.regularMaterial, in: Capsule())
                Slider(value: $vehicle.speed.value, in: vehicle.speedRange, step: vehicle.step)
                    .onChange(of: vehicle.speed.value) {
                        updateWeatherWaypoints(departureTime: departureTime)
                    }
            }
            .padding()
            
        }
        .toolbar {
            ToolbarItem(id: "picker", placement: .bottomBar) {
                DatePicker("Departure Time", selection: $departureTime, in: Date.threeDaysFromToday)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .labelsHidden()
            }
            ToolbarItem(id: "slider", placement: .bottomBar, showsByDefault: false) {
                Slider(value: proxyDepartureTime, in: Date.threeDaysFromTodayTimeInterval, step: 60 * 60)
                    .frame(minWidth: 100, maxWidth: 400)
                    .padding()
                    .onChange(of: departureTime) { oldValue, newValue in
                        updateWeatherWaypoints(departureTime: newValue)
                    }
            }
            ToolbarItem(id: "add", placement: .bottomBar) {
                Button(action: {
                    addWaypoint()
                }, label: {
                    Label("Add Waypoint", systemImage: "plus")
                })
            }
            ToolbarItem(id: "update_weather", placement: .secondaryAction) {
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
            WeatherBarItem(weatherParameter: $selectedWeatherParameter)
            VehicleBarItem(vehicle: $vehicle)
        }
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
            let persistence = BackgroundPersistence(container: context.container)
            do {
                customWaypoints = try await persistence.loadAllCustomWaypoints()
                weatherWaypoints = try await persistence.loadAllWeatherWaypoints()
                
                if customWaypoints.count == 0 {
                    createSampleRoute()
                }
                position = MapCameraPosition.region(customWaypoints.region)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateWeatherWaypoints(departureTime: Date) {
        weatherWaypoints = []
        weatherWaypoints = routeCalculationService.calculateRoute(existingWaypoints: customWaypoints, speed: vehicle.speed.value, unit: vehicle.unit, departureTime: departureTime, timeInterval: Constants.RouteCalculation.interval)
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
        customWaypoints = CustomWaypoint.samplesUK()
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
