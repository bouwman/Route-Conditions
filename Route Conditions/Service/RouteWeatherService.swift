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
    
    private let apiKey: String = ""
    private let baseUrl: String = ""
    
    private let weatherKitService = WeatherService.shared
    
    func fetchWeather(coordinate: CLLocationCoordinate2D, existingData: [WeatherData]) async throws -> [WeatherData] {
        let upcomingWeather = existingData.filter { $0.date > Date() }
        
        if upcomingWeather.count < 24 {
            let hourlyForecast = try await fetchHourlyWeather(coordinate: coordinate)
            let dailyForecast = try await fetchDailyWeather(coordinate: coordinate)
            
            return hourlyForecast + dailyForecast
            
        } else {
            return existingData
        }
    }
    
    private func fetchHourlyWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherData] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await weatherKitService.weather(for: location, including: .hourly)
        
        return forecast.map { WeatherData(weatherKit: $0) }
    }
    
    private func fetchDailyWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherData] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await weatherKitService.weather(for: location, including: .daily)
        
        return forecast.map { WeatherData(weatherKit: $0) }
    }
}
