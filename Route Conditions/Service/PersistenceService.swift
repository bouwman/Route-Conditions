//
//  PersistenceService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import SwiftData
import CoreLocation
import OSLog

actor PersistenceService: ModelActor {
    
    nonisolated let executor: any ModelExecutor
    
    private let log = OSLog.persistence
        
    init(container: ModelContainer) {
        let context = ModelContext(container)
        executor = DefaultModelExecutor(context: context)
    }
    
    func weatherParametersThatNeedsData(at coordinate: CLLocationCoordinate2D) throws -> [WeatherParameter] {
        // TODO: Filter by current date and waypoint once it works
        let predicate = #Predicate<WeatherData> { data in 1==1 }
        let sort = SortDescriptor<WeatherData>(\.date)
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
        
        log.debug("Start fetching weather data for coordinate \(coordinate.latitude) ...")
        let result = try context.fetch(descriptor)
        
        log.debug("Total weather data count \(result.count) for coordinate \(coordinate.latitude)")

        let hasTide = result.filter { data in
            guard let waypoint = data.waypoint else {
                context.delete(data)
                return false
            }
            let isSameCoordinate = waypoint.coordinate == coordinate
            let isUpcoming = data.date >= Date()
            let hasTideData = data.current?.directionData != nil
            let isValid = isSameCoordinate && isUpcoming && hasTideData
            
            if !isUpcoming {
                context.delete(data)
            }
            
            return isValid
        }
        
        let hasWind = result.filter { data in
            guard let waypoint = data.waypoint else {
                context.delete(data)
                return false
            }
            let isSameCoordinate = waypoint.coordinate == coordinate
            let isUpcoming = data.date >= Date()
            let hasWindData = data.wind?.directionData != nil
            let isValid = isSameCoordinate && isUpcoming && hasWindData
            
            if !isUpcoming {
                context.delete(data)
            }
            
            return isValid
        }
        
        let tideCount = hasTide.count
        let windCount = hasWind.count
        
        log.debug("Filtered tide data count \(tideCount) / 60 for coordinate \(coordinate.latitude)")
        log.debug("Filtered wind data count \(windCount) / 200 for coordinate \(coordinate.latitude)")
        
        if tideCount >= 60 && windCount >= 200 {
            return []
        } else if tideCount >= 60 && windCount < 200 {
            return [.conditions]
        } else if tideCount < 60 && windCount >= 200 {
            return [.current]
        } else {
            return WeatherParameter.all
        }
    }
    
    func storeRemoteWeather(data: [WeatherModelConvertible], for waypointId: PersistentIdentifier) throws {
        guard data.count != 0 else { return }
        
        let localData = mergeRemote(data: data)
        let waypoint = context.object(with: waypointId) as! WeatherWaypoint
        
        for data in localData {
            data.waypoint = waypoint
            context.insert(data)
        }
        
        try context.save()
    }
    
    private func mergeRemote(data: [WeatherModelConvertible]) -> [WeatherData] {
        var localData: [WeatherData] = []
        
        log.debug("Start merging \(data.count) weather data points ...")
        for newData in data {
            if let existing = localData.first(where: { newData.convertedDate.isWithinSameHour(as: $0.date) }) {
                if existing.wind!.gustData == nil {
                    existing.wind!.gustData = newData.convertedWindGust
                }
                if existing.wind!.speedData == nil {
                    existing.wind!.speedData = newData.convertedWindSpeed
                }
                if existing.wind!.directionData == nil {
                    existing.wind!.directionData = newData.convertedWindDirection
                }
                if existing.current!.speedData == nil {
                    existing.current!.speedData = newData.convertedCurrentSpeed
                }
                if existing.current!.directionData == nil {
                    existing.current!.directionData = newData.convertedCurrentDirection
                }
                if existing.waves!.heightData == nil {
                    existing.waves!.heightData = newData.convertedWaveHeight
                }
                if existing.waves!.directionData == nil {
                    existing.waves!.directionData = newData.convertedWaveDirection
                }
                if existing.conditions!.title == nil {
                    existing.conditions!.title = newData.convertedConditionsTitle
                }
                if existing.conditions!.symbolName == nil {
                    existing.conditions!.symbolName = newData.convertedConditionsSymbol
                }
                if existing.timeInfo!.isDaylight == nil {
                    existing.timeInfo!.isDaylight = newData.convertedTimeIsDaylight
                }
            } else {
                localData.append(WeatherData(convertible: newData))
            }
        }
        log.debug("Created \(localData.count) weather data points")
        
        return localData
    }
}
