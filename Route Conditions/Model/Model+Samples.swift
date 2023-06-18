//
//  Model+Samples.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import Foundation

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
        var weather = WeatherData()
        let wind = WindData(compassDirection: .east, direction: .init(value: 80, unit: .degrees), speed: .init(value: 10, unit: .knots))
        
        weather.currentSpeed = .init(value: 15, unit: .knots)
        weather.currentDirection = .init(value: 270, unit: .degrees)
        weather.waveHeight = .init(value: 0.2, unit: .meters)
        weather.waveDirection = .init(value: 80, unit: .degrees)
        weather.wind = wind
        weather.symbolName = "cloud.sun"
        
        return weather
    }
}

extension Vehicle {
    static func sample() -> Vehicle {
        return Vehicle(name: "Car", averageSpeed: .init(value: 80, unit: .kilometersPerHour))
    }
}
