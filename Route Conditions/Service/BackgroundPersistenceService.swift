//
//  BackgroundPersistenceService.swift
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

actor BackgroundPersistenceActor: ModelActor {
    
    nonisolated public let executor: any ModelExecutor
    
    private let log = OSLog.persistence
        
    init(container: ModelContainer) {
        let context = ModelContext(container)
        executor = DefaultModelExecutor(context: context)
    }
    
    func loadCustomWaypoints() throws -> [CustomWaypoint] {
        let predicate = #Predicate<CustomWaypointData> { data in 1==1 }
        let sort = SortDescriptor<CustomWaypointData>(\.position)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
        
        log.debug("Start fetching custom waypoints ...")
        let result = try context.fetch(descriptor)
        log.debug("Total custom waypoint count \(result.count)")
        
        return result.map { CustomWaypoint(coordinate: $0.coordinate, position: $0.position) }
    }
    
    func loadWeatherWaypoints() throws -> [WeatherWaypoint] {
        let predicate = #Predicate<WeatherWaypointData> { data in 1==1 }
        let sort = SortDescriptor<WeatherWaypointData>(\.date)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
        
        log.debug("Start fetching weather data ...")
        let result = try context.fetch(descriptor)
        log.debug("Total weather data count \(result.count)")
        
        return result.map { WeatherWaypoint(coordinate: $0.coordinate, position: $0.position, date: $0.date, weather: $0.weather.map { Weather(coordinate: $0.coordinate, convertible: $0) }) }
    }
    
    func storeRemoteWeather(data: [WeatherModelConvertible], for waypointId: PersistentIdentifier) throws {
        guard data.count != 0 else { return }
        
        let waypoint = context.object(with: waypointId) as! WeatherWaypointData
        let localData = mergeRemote(data: data, coordinate: waypoint.coordinate)
        
        for data in localData {
            data.waypoint = waypoint
            context.insert(data)
        }
        
        try context.save()
    }
    
    private func mergeRemote(data: [WeatherModelConvertible], coordinate: CLLocationCoordinate2D) -> [WeatherData] {
        var localData: [WeatherData] = []
        
        log.debug("Start merging \(data.count) weather data points ...")
        for newData in data {
//            if let existing = localData.first(where: { newData.convertedDate.isWithinSameHour(as: $0.date) }) {
//                if existing.wind!.gustData == nil {
//                    existing.wind!.gustData = newData.convertedWindGust
//                }
//                if existing.wind!.speedData == nil {
//                    existing.wind!.speedData = newData.convertedWindSpeed
//                }
//                if existing.wind!.directionData == nil {
//                    existing.wind!.directionData = newData.convertedWindDirection
//                }
//                if existing.current!.speedData == nil {
//                    existing.current!.speedData = newData.convertedCurrentSpeed
//                }
//                if existing.current!.directionData == nil {
//                    existing.current!.directionData = newData.convertedCurrentDirection
//                }
//                if existing.waves!.heightData == nil {
//                    existing.waves!.heightData = newData.convertedWaveHeight
//                }
//                if existing.waves!.directionData == nil {
//                    existing.waves!.directionData = newData.convertedWaveDirection
//                }
//                if existing.conditions!.title == nil {
//                    existing.conditions!.title = newData.convertedConditionsTitle
//                }
//                if existing.conditions!.symbolName == nil {
//                    existing.conditions!.symbolName = newData.convertedConditionsSymbol
//                }
//                if existing.timeInfo!.isDaylight == nil {
//                    existing.timeInfo!.isDaylight = newData.convertedTimeIsDaylight
//                }
//            } else {
                localData.append(WeatherData(convertible: newData, coordinate: coordinate))
//            }
        }
        log.debug("Created \(localData.count) weather data points")
        
        return localData
    }
}
