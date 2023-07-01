//
//  Model+Samples.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import Foundation
import CoreLocation

extension CustomWaypoint {
    static func samplesUK() -> [CustomWaypoint] {
        let london = CustomWaypoint(coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278), position: 1)
        let manchester = CustomWaypoint(coordinate: CLLocationCoordinate2D(latitude: 53.4808, longitude: -2.2426), position: 2)
        let edinburgh = CustomWaypoint(coordinate: CLLocationCoordinate2D(latitude: 55.9533, longitude: -3.1883), position: 3)
        
        return [london, manchester, edinburgh]
    }
    
    static func samplesChannel() -> [CustomWaypoint] {
        let cherbourg = CustomWaypoint(coordinate: CLLocationCoordinate2D(latitude: 49.66373, longitude: -1.61641), position: 1)
        let race = CustomWaypoint(coordinate: CLLocationCoordinate2D(latitude: 49.76040, longitude: -2.01965), position: 2)
        let peterport = CustomWaypoint(coordinate: CLLocationCoordinate2D(latitude: 49.45640, longitude: -2.51279), position: 3)
        
        return [cherbourg, race, peterport]
    }
}

extension WeatherWaypoint {
    static func samples() -> [WeatherWaypoint] {
        return CustomWaypoint.samplesChannel().map { WeatherWaypoint(coordinate: $0.coordinate, position: $0.position, weather: [Weather.sample()])}
    }
}

extension Weather {
    
    static func sample() -> Weather {
        let weather = Weather()
        
        weather.current = Current(direction: .init(value: 80.0, unit: .degrees), speed: .init(value: 0.8, unit: .knots))
        weather.wind = Wind(direction: .init(value: 80, unit: .degrees), speed: .init(value: 15, unit: .knots), gust: nil)
        weather.conditions = Conditions(title: "Partially sunny", symbolName: "could.sun")
        weather.solar = Solar(isDaylight: false)
        
        return weather
    }
}

extension Temperature {
    
    static func allSamples() -> [Temperature] {
        let temp1 = Temperature(date: Date(), air: .init(value: 19.0, unit: .celsius), water: .init(value: 17.2, unit: .celsius))
        let temp2 = Temperature(date: Date(timeIntervalSinceNow: 1 * 60 * 60), air: .init(value: 19.0, unit: .celsius), water: .init(value: 17.2, unit: .celsius))
        let temp3 = Temperature(date: Date(timeIntervalSinceNow: 2 * 60 * 60), air: .init(value: 20.5, unit: .celsius), water: .init(value: 17.3, unit: .celsius))
        let temp4 = Temperature(date: Date(timeIntervalSinceNow: 3 * 60 * 60), air: .init(value: 23.1, unit: .celsius), water: .init(value: 17.5, unit: .celsius))
        let temp5 = Temperature(date: Date(timeIntervalSinceNow: 4 * 60 * 60), air: .init(value: 25.6, unit: .celsius), water: .init(value: 17.8, unit: .celsius))
        let temp6 = Temperature(date: Date(timeIntervalSinceNow: 5 * 60 * 60), air: .init(value: 24.3, unit: .celsius), water: .init(value: 18.1, unit: .celsius))
        let temp7 = Temperature(date: Date(timeIntervalSinceNow: 6 * 60 * 60), air: .init(value: 23.5, unit: .celsius), water: .init(value: 18.0, unit: .celsius))

        return [temp1, temp2, temp3, temp4, temp5, temp6, temp7]
    }
}

extension Vehicle {
    static func sample() -> Vehicle {
        return allSamples()[4]
    }
    
    static func allSamples() -> [Vehicle] {
        return VehicleType.all.map { Vehicle(averageSpeed: $0.defaultSpeed, type: $0, unit: $0.defaultUnit) }
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
