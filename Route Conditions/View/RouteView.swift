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
                UserAnnotation()
                ForEach(predictedWaypoints) { waypoint in
                    WeatherMarker(weatherAttribute: $selectedWeatherParameter, coordinate: waypoint.coordinate, time: waypoint.time, weather: waypoint.currentWeather(for: selectedWeatherParameter))
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
                    if !isActive {
                        calculateWaypoints()
                    }
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
                    calculateWaypoints()
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
        let newWaypoints = routeCalculationService.calculateRoute(vehicle: vehicle, inputRoute: waypoints, departureTime: departureTime, timeInterval: 60 * 60 * 1)
        
        deletePredictedWaypoints()
        
        for waypoint in newWaypoints {
            let newWaypoint = WeatherWaypoint(position: waypoint.position, latitude: waypoint.latitude, longitude: waypoint.longitude, time: waypoint.time)
            newWaypoint.weather = fetchWeather(for: waypoint.coordinate) ?? []
            context.insert(newWaypoint)
        }
    }
    
    private func fetchWeather(for coordinate: CLLocationCoordinate2D) -> [WeatherData]? {
        let predicate = #Predicate<WeatherData> { data in
            data.latitude == coordinate.latitude && data.longitude == coordinate.longitude
        }
        let sort = SortDescriptor<WeatherData>(\.date)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
        
        log.debug("Start fetching weather data for coordinate \(coordinate.latitude) ...")
        do {
            return try context.fetch(descriptor)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func updateWeather() {
        isLoadingWeather = true
        log.debug("Start updating weather for \(predictedWaypoints.count) waypoints ...")
        
        for waypoint in predictedWaypoints {
            Task {
                do {
                    let persistence = BackgroundPersistenceService(container: context.container)
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
