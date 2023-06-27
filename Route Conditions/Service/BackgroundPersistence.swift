//
//  BackgroundPersistenceActor.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import SwiftData
import CoreLocation
import OSLog
/*
@globalActor struct PersistenceActor {
    actor MyPersistenceActor { }

    static let shared: MyPersistenceActor = MyPersistenceActor()
}

final class PersistenceService {

    static let shared = BackgroundPersistenceActor(container: container)
    static var container: ModelContainer!
    
    var background: BackgroundPersistenceActor!
    
    static func setup(container: ModelContainer) {
        self.container = container
    }
    
    private init() {
        guard let container = PersistenceService.container else {
            fatalError("Error - you must call setup before accessing PersistenceService.shared")
        }
        background = BackgroundPersistenceActor(container: container)
    }
}
 */

actor BackgroundPersistence: ModelActor {
    
    nonisolated public let executor: any ModelExecutor
    
    private let log = OSLog.persistence
        
    init(container: ModelContainer) {
        let context = ModelContext(container)
        executor = DefaultModelExecutor(context: context)
    }
    
    func loadAllCustomWaypoints() throws -> [CustomWaypoint] {
        try loadAllCustomDataWaypoints().map { CustomWaypoint(coordinate: $0.coordinate, position: $0.position) }
    }
    
    func loadAllWeatherWaypoints() throws -> [WeatherWaypoint] {
        try loadAllWeatherDataPoints().map { WeatherWaypoint(coordinate: $0.coordinate, position: $0.position, date: $0.date, weather: $0.weather.map { Weather(coordinate: $0.coordinate, convertible: $0) }) }
    }
    
    func store(customWaypoints: [WeatherWaypoint]) throws {
        try deleteAllCustomWaypoints()
        
        for waypoint in customWaypoints {
            let newWaypoint = CustomWaypointData(position: waypoint.position, latitude: waypoint.latitude, longitude: waypoint.longitude)
            context.insert(newWaypoint)
        }
        
        try context.save()
    }
    
    func store(weatherWaypoints: [WeatherWaypoint]) throws {
        try deleteAllWeatherWaypoints()
        
        log.debug("Start creating \(weatherWaypoints.count) weather waypoints ...")
        
        for waypoint in weatherWaypoints {
            let newWaypoint = WeatherWaypointData(position: waypoint.position, latitude: waypoint.latitude, longitude: waypoint.longitude, date: waypoint.date)
            let newWeather = waypoint.weather.map { WeatherData(convertible: $0, coordinate: $0.coordinate) }
            
            for weather in newWeather {
                weather.waypoint = newWaypoint
                context.insert(weather)
            }
            
            context.insert(newWaypoint)
        }
        log.debug("Finished inserting \(weatherWaypoints.count) weather waypoints")
        
        try context.save()
    }
    
    func deleteAllWeatherWaypoints() throws {
        let allExistingWaypoints = try loadAllWeatherDataPoints()
        
        log.debug("Start deleting \(allExistingWaypoints.count) weather waypoints ...")
        
        for waypoint in allExistingWaypoints {
            context.delete(waypoint)
        }
        log.debug("Finished deleting \(allExistingWaypoints.count) weather waypoints")
    }
    
    func deleteAllCustomWaypoints() throws {
        let allExistingWaypoints = try loadAllCustomDataWaypoints()
        
        log.debug("Start deleting \(allExistingWaypoints.count) custom waypoints ...")

        for waypoint in allExistingWaypoints {
            context.delete(waypoint)
        }
        
        log.debug("Finished deleting  \(allExistingWaypoints.count) custom waypoints")
    }
    
    private func loadAllWeatherDataPoints() throws -> [WeatherWaypointData] {
        let predicate = #Predicate<WeatherWaypointData> { data in 1==1 }
        let sort = SortDescriptor<WeatherWaypointData>(\.date)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
        
        log.debug("Start fetching weather waypoints ...")
        let result = try context.fetch(descriptor)
        log.debug("Total weather waypoint count \(result.count)")
        
        return result
    }
    
    private func loadAllCustomDataWaypoints() throws -> [CustomWaypointData] {
        let predicate = #Predicate<CustomWaypointData> { data in 1==1 }
        let sort = SortDescriptor<CustomWaypointData>(\.position)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
        
        log.debug("Start fetching custom waypoints ...")
        let result = try context.fetch(descriptor)
        log.debug("Total custom waypoint count \(result.count)")
        
        return result
    }
    
    func storeRemoteWeather(data: [WeatherModelConvertible], for waypointId: PersistentIdentifier) throws {
        guard data.count != 0 else { return }
        
        let waypoint = context.object(with: waypointId) as! WeatherWaypointData
        let localData = data.map { WeatherData(convertible: $0, coordinate: waypoint.coordinate) }
        
        for data in localData {
            data.waypoint = waypoint
            context.insert(data)
        }
        
        try context.save()
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
}
