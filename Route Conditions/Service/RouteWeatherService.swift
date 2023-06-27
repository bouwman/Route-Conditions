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

actor RouteWeatherService {
    
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
        
        return combined
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
}
