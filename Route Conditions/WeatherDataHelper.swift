//
//  WeatherDataHelper.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.05.23.
//

import Foundation
import WeatherKit
import CoreLocation

@MainActor
class WeatherDataHelper: ObservableObject {
    
    static let shared = WeatherDataHelper()
    private let service = WeatherService.shared
    
    @Published var currentWeather: CurrentWeather?
    @Published var hourlyForecast: Forecast<HourWeather>?
    @Published var attributionInfo: WeatherAttribution?
    
    func updateCurrentWeather(location: CLLocation) {
        Task.detached(priority: .userInitiated) {
            do {
                let forcast = try await self.service.weather(
                    for: location,
                    including: .current)
                DispatchQueue.main.async {
                    self.currentWeather = forcast
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateHourlyWeather(userLocation: CLLocation) {
        Task.detached(priority: .userInitiated) {
            do {
                let forcast = try await self.service.weather(
                    for: userLocation,
                    including: .hourly)
                DispatchQueue.main.async {
                    self.hourlyForecast = forcast
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateAttributionInfo() {
        Task.detached(priority: .background) {
            let attribution = try await self.service.attribution
            DispatchQueue.main.async {
                self.attributionInfo = attribution
            }
        }
    }
}
