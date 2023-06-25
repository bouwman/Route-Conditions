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

actor RouteWeatherService {
    
    static let shared = RouteWeatherService()
    
    private init() { }
    
    private let weatherKitService = WeatherService.shared
    private let stormGlassService = StormGlassService.shared
    
    func fetchWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        let hourlyForecast = try await fetchHourlyWeather(coordinate: coordinate)
        let dailyForecast = try await fetchDailyWeather(coordinate: coordinate)
        let wavesAndCurrents = try await fetchWavesAndCurrents(coordinate: coordinate)
        
        return hourlyForecast + dailyForecast + wavesAndCurrents
    }
    
    private func fetchWavesAndCurrents(coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        let forecast = try await stormGlassService.waveAndCurrentForecast(for: coordinate)
        
        return forecast
    }
    
    private func fetchHourlyWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await weatherKitService.weather(for: location, including: .hourly)
        
        return forecast.map { $0 as WeatherModelConvertible }
    }
    
    private func fetchDailyWeather(coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await weatherKitService.weather(for: location, including: .daily)
        
        return forecast.map { $0 as WeatherModelConvertible }
    }
}
