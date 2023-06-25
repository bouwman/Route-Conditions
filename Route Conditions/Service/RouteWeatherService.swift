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
    
    func fetchWeather(parameters: [WeatherParameter], coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        
        var combined: [WeatherModelConvertible] = []
        
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
    
    private func fetchWavesAndCurrents(coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        log.debug("Start fetching wave and current forecast from StormGlass ...")
        let forecast = try await stormGlassService.waveAndCurrentForecast(for: coordinate)
        log.debug("Received \(forecast.count) items from StormGlass")
        
        return forecast
    }
    
    private func fetchGeneralWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        log.debug("Start fetching hourly and daily weather from WeatherKit ...")
        let forecast = try await weatherKitService.weather(for: location, including: .hourly, .daily)
        log.debug("Received \(forecast.0.count) hour items and \(forecast.1.count) day items from WeatherKit")

        return forecast.0.forecast + forecast.1.forecast
    }
}
