//
//  Model+Samples.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import Foundation
import CoreLocation

extension CustomWaypoint {
    static func samples() -> [CustomWaypoint] {
        let london = CustomWaypoint(position: 1, latitude: 51.5074, longitude: -0.1278)
        let manchester = CustomWaypoint(position: 2, latitude: 53.4808, longitude: -2.2426)
        let edinburgh = CustomWaypoint(position: 3, latitude: 55.9533, longitude: -3.1883)
        
        return [london, manchester, edinburgh]
    }
}

extension WeatherWaypoint {
    static func samples() -> [WeatherWaypoint] {
        let london = WeatherWaypoint(position: 1, latitude: 51.5074, longitude: -0.1278, time: Date())
        let manchester = WeatherWaypoint(position: 2, latitude: 53.4808, longitude: -2.2426, time: Date())
        let edinburgh = WeatherWaypoint(position: 3, latitude: 55.9533, longitude: -3.1883, time: Date())
        
        london.weather = [WeatherData.sample()]
        manchester.weather = [WeatherData.sample()]
        edinburgh.weather = [WeatherData.sample()]
        
        return [london, manchester, edinburgh]
    }
}

extension WeatherData {
    
    static func sample() -> WeatherData {
        let weather = WeatherData()
        
        weather.current = CurrentData(speed: .init(value: 15, unit: .knots), direction: .init(value: 270, unit: .degrees))
        weather.waves = WaveData(height: .init(value: 0.2, unit: .meters), direction: .init(value: 80, unit: .degrees))
        weather.wind = WindData(speed: .init(value: 10, unit: .knots), direction: .init(value: 80, unit: .degrees))
        weather.conditions = ConditionsData(title: "Partially sunny", symbolName: "could.sun")
        weather.timeInfo = TimeData(isDaylight: false)
        
        return weather
    }
}

extension Vehicle {
    static func sample() -> Vehicle {
        return Vehicle(name: "Car", averageSpeed: .init(value: 80, unit: .kilometersPerHour))
    }
}

extension CLLocationCoordinate2D {
    /// Random locations across the UK
    static func random() -> CLLocationCoordinate2D {
        let minLatitude = 50.8 // Minimum latitude of the UK
        let maxLatitude = 58.5 // Maximum latitude of the UK
        let minLongitude = -8.649357 // Minimum longitude of the UK
        let maxLongitude = 1.763335 // Maximum longitude of the UK
        
        let latitude = Double.random(in: minLatitude...maxLatitude)
        let longitude = Double.random(in: minLongitude...maxLongitude)
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
