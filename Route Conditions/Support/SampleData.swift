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
        return allSamples()[0]
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

extension CustomWaypoint {
    static var route: [CustomWaypoint] {
        return [
            CustomWaypoint(coordinate: CLLocationCoordinate2DMake(49.0084, -2.5381), position: 1), // Start point (France)
            CustomWaypoint(coordinate: CLLocationCoordinate2DMake(49.4345, -2.6253), position: 2), // Waypoint 1
            CustomWaypoint(coordinate: CLLocationCoordinate2DMake(49.9094, -2.7597), position: 3), // Waypoint 2
            CustomWaypoint(coordinate: CLLocationCoordinate2DMake(50.3466, -2.7941), position: 4), // Waypoint 3
            CustomWaypoint(coordinate: CLLocationCoordinate2DMake(50.7167, -1.8806), position: 5) // End point (UK)
        ]
    }
}

extension WeatherWaypoint {
    static func createWeatherWaypoints() -> [WeatherWaypoint] {
        var weatherWaypoints: [WeatherWaypoint] = []
        let customWaypoints = CustomWaypoint.route
        
        var currentDate = Date()
        for i in 1..<(customWaypoints.count - 1) {
            let waypoint1 = customWaypoints[i]
            let waypoint2 = customWaypoints[i + 1]
            let distance = WeatherWaypoint.calculateDistanceBetweenWaypoints(waypoint1, waypoint2)
            let numberOfWeatherWaypoints = Int(distance.converted(to: UnitLength.meters).value / WeatherWaypoint.distanceBetweenWeatherWaypoints.converted(to: UnitLength.meters).value)
            
            for j in 0..<numberOfWeatherWaypoints {
                let fraction = Double(j + 1) / Double(numberOfWeatherWaypoints + 1)
                let latitude = waypoint1.coordinate.latitude + (waypoint2.coordinate.latitude - waypoint1.coordinate.latitude) * fraction
                let longitude = waypoint1.coordinate.longitude + (waypoint2.coordinate.longitude - waypoint1.coordinate.longitude) * fraction
                let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                var weatherWaypoint = WeatherWaypoint(
                    coordinate: coordinate,
                    position: weatherWaypoints.count + 1,
                    date: currentDate
                )
                
                let weatherObjects = Weather.generateWeatherObjects(currentDate: currentDate, coordinate: coordinate)
                weatherWaypoint.weather = weatherObjects
                
                weatherWaypoints.append(weatherWaypoint)
                
                // Increment the date by one hour
                currentDate.addTimeInterval(3600)
            }
        }
        
        return weatherWaypoints
    }
    
    private static func calculateDistanceBetweenWaypoints(_ waypoint1: CustomWaypoint, _ waypoint2: CustomWaypoint) -> Measurement<UnitLength> {
        let location1 = CLLocation(latitude: waypoint1.coordinate.latitude, longitude: waypoint1.coordinate.longitude)
        let location2 = CLLocation(latitude: waypoint2.coordinate.latitude, longitude: waypoint2.coordinate.longitude)
        let distance = location1.distance(from: location2)
        return Measurement(value: distance, unit: UnitLength.meters)
    }
    
    static var distanceBetweenWeatherWaypoints: Measurement<UnitLength> {
        let distances = CustomWaypoint.route.dropFirst().dropLast().map { waypoint -> Measurement<UnitLength> in
            let nextWaypoint = CustomWaypoint.route[waypoint.position]
            return calculateDistanceBetweenWaypoints(waypoint, nextWaypoint)
        }
        
        let totalDistance = distances.reduce(Measurement(value: 0, unit: UnitLength.meters), +)
        let weatherWaypointCount = 20
        let distanceBetweenWeatherWaypoints = totalDistance / Double(weatherWaypointCount + 1)
        return distanceBetweenWeatherWaypoints
    }
}

extension Weather {
    static func generateWeatherObjects(currentDate: Date, coordinate: CLLocationCoordinate2D) -> [Weather] {
        var weatherObjects: [Weather] = []
        var date = currentDate
        for _ in 0..<168 {
            let weather = Weather()
            
            weather.coordinate = coordinate
            weather.date = date
            
            // Generate random weather data
            weather.temperature.air = Measurement(value: Double.random(in: 10...25), unit: UnitTemperature.celsius)
            weather.temperature.water = Measurement(value: Double.random(in: 10...20), unit: UnitTemperature.celsius)
            weather.wind.direction = Measurement(value: Double.random(in: 0...360), unit: UnitAngle.degrees)
            weather.wind.speed = Measurement(value: Double.random(in: 5...20), unit: UnitSpeed.knots)
            weather.current.direction = Measurement(value: Double.random(in: 0...360), unit: UnitAngle.degrees)
            weather.current.speed = Measurement(value: Double.random(in: 0...2), unit: UnitSpeed.knots)
            weather.waves.direction = Measurement(value: Double.random(in: 0...360), unit: UnitAngle.degrees)
            weather.waves.height = Measurement(value: Double.random(in: 0...3), unit: UnitLength.meters)
            weather.conditions.title = "Sunny"
            weather.conditions.symbolName = "sun.max"
            weather.solar.isDaylight = true
            
            weatherObjects.append(weather)
            
            // Increment the date by one hour
            date.addTimeInterval(3600)
        }
        
        return weatherObjects
    }
}
