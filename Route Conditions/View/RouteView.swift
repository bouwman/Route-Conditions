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
    
    private var proxyDepartureTime: Binding<Double> {
        Binding<Double> {
            return departureTime.timeIntervalSince1970
        } set: { newValue, transaction in
            departureTime = Date(timeIntervalSince1970: newValue)
        }
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
                ForEach(weatherWaypoints) { waypoint in
                    WeatherMarker(weatherAttribute: $selectedWeatherParameter, coordinate: waypoint.coordinate, time: waypoint.date, weather: waypoint.currentWeather(for: selectedWeatherParameter))
                }
                UserAnnotation()
            }
            .onMapCameraChange {
                print("camera changed")
            }
            .onMapCameraChange { updateContext in
                centerCoordinate = updateContext.camera.centerCoordinate
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
            Rectangle()
                .fill(.primary)
                .frame(width: 2, height: 12, alignment: .center)
            Rectangle()
                .fill(.primary)
                .frame(width: 12, height: 2, alignment: .center)
            
            HStack {
                VStack(alignment: .center) {
                    Text(vehicle.speed.formatted())
                        .multilineTextAlignment(.center)
                    Spacer()
                        .frame(maxHeight: 100)
                    Slider(value: $vehicle.speed.value, in: vehicle.speedRange, step: vehicle.step)
                        .frame(minWidth: 200, maxWidth: 300)
                        .rotationEffect(.degrees(-90))
                        .onChange(of: vehicle.speed.value) {
                            updateWeatherWaypoints()
                        }
                }
                .frame(maxWidth: 50, minHeight: 400)
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(id: "departure_time", placement: .bottomBar) {
                DatePicker("Departure Time", selection: $departureTime, in: Date.threeDaysFromToday)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .labelsHidden()
            }
            ToolbarItem(id: "slider", placement: .bottomBar, showsByDefault: false) {
                Slider(value: proxyDepartureTime, in: Date.threeDaysFromTodayTimeInterval, step: 60 * 60)
                    .frame(minWidth: 100, maxWidth: 400)
                    .padding()
                    .onChange(of: departureTime) { oldValue, newValue in
                        updateWeatherWaypoints()
                    }
            }
            ToolbarItem(id: "add", placement: .bottomBar) {
                Button(action: {
                    addWaypoint()
                    updateWeatherWaypoints()
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
        let waypoint = CustomWaypoint(coordinate: centerCoordinate, position: customWaypoints.count + 1)
        customWaypoints.append(waypoint)
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
