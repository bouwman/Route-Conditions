//
//  RouteWeatherService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation
import CoreLocation
import WeatherKit
import SwiftData
import SwiftUI
import OSLog

class RouteWeatherService {
    
    static let shared = RouteWeatherService()
    
    private init() { }
    
    private let weatherKitService = WeatherService.shared
    private let stormGlassService = StormGlassService.shared
    
    private let log = OSLog.network
    
    func fetchWeather(parameters: [WeatherParameter], coordinate: CLLocationCoordinate2D) async throws -> [Weather] {
        
        var combined: [Weather] = []
        
        if parameters.contains(where: { $0 == .conditions || $0 == .time || $0 == .wind }) {
            let generalForecast = try await fetchGeneralWeather(coordinate: coordinate)
            combined += generalForecast
        }
        
        if parameters.contains(where: { $0 == .waves || $0 == .current }) {
            let wavesAndCurrents = try await fetchWavesAndCurrents(coordinate: coordinate)
            combined += wavesAndCurrents
        }
        
        log.debug("Finished downloading \(combined.count) forecast items.")
        
        return merge(data: combined)
    }
    
    private func fetchWavesAndCurrents(coordinate: CLLocationCoordinate2D) async throws -> [Weather] {
        log.debug("Start fetching wave and current forecast from StormGlass ...")
        let forecast = try await stormGlassService.waveAndCurrentForecast(for: coordinate)
        log.debug("Received \(forecast.count) items from StormGlass")
        
        return forecast.map { Weather(coordinate: coordinate, convertible: $0) }
    }
    
    private func fetchGeneralWeather(coordinate: CLLocationCoordinate2D) async throws -> [Weather] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        log.debug("Start fetching hourly and daily weather from WeatherKit ...")
        let forecast = try await weatherKitService.weather(for: location, including: .hourly, .daily)
        log.debug("Received \(forecast.0.count) hour items and \(forecast.1.count) day items from WeatherKit")

        let hours = forecast.0.map { Weather(coordinate: coordinate, convertible: $0) }
        let days = forecast.1.map { Weather(coordinate: coordinate, convertible: $0) }
        
        return hours + days
    }
    
    func weatherParametersThatNeedsData(at coordinate: CLLocationCoordinate2D, existingData: [Weather]) throws -> [WeatherParameter] {
        let hasTide = existingData.filter { data in
            let isSameCoordinate = data.coordinate == coordinate
            let isUpcoming = data.date >= Date()
            let hasTideData = data.current.direction != nil
            let isValid = isSameCoordinate && isUpcoming && hasTideData
            
            return isValid
        }
        
        let hasWind = existingData.filter { data in
            let isSameCoordinate = data.coordinate == coordinate
            let isUpcoming = data.date >= Date()
            let hasWindData = data.wind.direction != nil
            let isValid = isSameCoordinate && isUpcoming && hasWindData
            
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
    
    func merge(data: [Weather]) -> [Weather] {
        
        var mergedData: [Weather] = []
        
        log.debug("Start merging \(data.count) weather data points ...")
        
        for newData in data {
            var existing = mergedData.first(where: { newData.date == $0.date })
            
            if existing != nil  {
                if existing?.wind.gust == nil {
                    existing?.wind.gust = newData.wind.gust
                }
                if existing?.wind.speed == nil {
                    existing?.wind.speed = newData.wind.speed
                }
                if existing?.wind.direction == nil {
                    existing?.wind.direction = newData.wind.direction
                }
                if existing?.current.speed == nil {
                    existing?.current.speed = newData.current.speed
                }
                if existing?.current.direction == nil {
                    existing?.current.direction = newData.current.direction
                }
                if existing?.waves.height == nil {
                    existing?.waves.height = newData.waves.height
                }
                if existing?.waves.direction == nil {
                    existing?.waves.direction = newData.waves.direction
                }
                if existing?.conditions.title == nil {
                    existing?.conditions.title = newData.conditions.title
                }
                if existing?.conditions.symbolName == nil {
                    existing?.conditions.symbolName = newData.conditions.symbolName
                }
                if existing?.solar.isDaylight == nil {
                    existing?.solar.isDaylight = newData.solar.isDaylight
                }
            } else {
                existing = newData
            }
            mergedData.append(existing!)
        }
        log.debug("Created \(mergedData.count) weather data points")
        
        return mergedData
    }
}
