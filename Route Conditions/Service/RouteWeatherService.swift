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

class RouteWeatherService {
    
    private let weatherKitService = WeatherService.shared
    private let stormGlassService = StormGlassService.shared
    
    func fetchWeather(coordinate: CLLocationCoordinate2D, existingData: [WeatherData]) async throws -> [WeatherData] {
        let upcomingWeather = existingData.filter { $0.date > Date() }
        
        if upcomingWeather.count < 24 {
            let hourlyForecast = try await fetchHourlyWeather(coordinate: coordinate)
            let dailyForecast = try await fetchDailyWeather(coordinate: coordinate)
            let wavesAndCurrents = try await fetchWavesAndCurrents(coordinate: coordinate)
            
            return try merge(forecasts: hourlyForecast, dailyForecast, wavesAndCurrents)
        } else {
            return existingData
        }
    }
    
    private func fetchWavesAndCurrents(coordinate: CLLocationCoordinate2D) async throws -> [WeatherData] {
        let forecast = try await stormGlassService.waveAndCurrentForecast(for: coordinate)
        
        return forecast.map { WeatherData(convertible: $0) }
    }
    
    private func fetchHourlyWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherData] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await weatherKitService.weather(for: location, including: .hourly)
        
        return forecast.map { WeatherData(convertible: $0) }
    }
    
    private func fetchDailyWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherData] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await weatherKitService.weather(for: location, including: .daily)
        
        return forecast.map { WeatherData(convertible: $0) }
    }
    
    private func merge(forecasts: [WeatherData]...) throws -> [WeatherData] {
        var data: [WeatherData] = []
        
        for forecastArray in forecasts {
            for forecast in forecastArray {
                if let existing = data.first(where: { $0.date == forecast.date }) {
                    if existing.wind?.gustData != nil {
                        existing.wind?.gustData = forecast.wind?.gustData
                    }
                    if existing.wind?.speedData != nil {
                        existing.wind?.speedData = forecast.wind?.speedData
                    }
                    if existing.wind?.directionData != nil {
                        existing.wind?.directionData = forecast.wind?.directionData
                    }
                    if existing.current?.speedData != nil {
                        existing.current?.speedData = forecast.current?.speedData
                    }
                    if existing.current?.directionData != nil {
                        existing.current?.directionData = forecast.current?.directionData
                    }
                    if existing.waves?.heightData != nil {
                        existing.waves?.heightData = forecast.waves?.heightData
                    }
                    if existing.waves?.directionData != nil {
                        existing.waves?.directionData = forecast.waves?.directionData
                    }
                    if existing.conditions?.title != nil {
                        existing.conditions?.title = forecast.conditions?.title
                    }
                    if existing.conditions?.symbolName != nil {
                        existing.conditions?.symbolName = forecast.conditions?.symbolName
                    }
                    if existing.timeInfo?.isDaylight != nil {
                        existing.timeInfo?.isDaylight = forecast.timeInfo?.isDaylight
                    }
                } else {
                    data.append(forecast)
                }
            }
        }
        
        return data.sorted(by: { $0.date > $1.date })
    }
}
