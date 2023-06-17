//
//  RouteWeatherService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation
import CoreLocation
import WeatherKit

class RouteWeatherService {
    
    private let apiKey: String = ""
    private let baseUrl: String = ""
    
    static let shared = RouteWeatherService()
    private let service = WeatherService.shared
    
    func weather(coordinate: CLLocationCoordinate2D, date: Date) async throws -> [WeatherData] {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let forecast = try await WeatherService.shared.weather(for: location, including: .hourly)
        
        return forecast.map { WeatherData(weatherKit: $0) }
    }
}
