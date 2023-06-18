//
//  Model.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation
import CoreLocation
import SwiftUI
import Observation
import MapKit
import SwiftData
import WeatherKit

@Model class Vehicle {
    @Attribute(.unique) var id: UUID
    var name: String
    var averageSpeed: Double
    
    init(id: UUID, name: String, averageSpeed: Double) {
        self.id = id
        self.name = name
        self.averageSpeed = averageSpeed
    }
    
    convenience init() {
        self.init(id: UUID(), name: "My Boat", averageSpeed: 5.0)
    }
}

@Model class Route {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(.cascade) var waypoints: [CustomWaypoint]
    @Relationship(.cascade) var predictedWaypoints: [WeatherWaypoint]?
    
    init(name: String) {
        self.id = UUID()
        self.name = String("New Route")
        self.waypoints = []
        self.predictedWaypoints = []
    }
}

protocol Waypoint {
    var position: Int { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
}

extension Waypoint {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

@Model final class CustomWaypoint: Waypoint {
    var position: Int
    var latitude: Double
    var longitude: Double
    
    init(position: Int, latitude: Double, longitude: Double) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
    }
}

@Model final class WeatherWaypoint: Waypoint {
    var position: Int
    var latitude: Double
    var longitude: Double
    var time: Date
    
    @Transient var weather: [WeatherData] = []
    
    init(position: Int, latitude: Double, longitude: Double, time: Date) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
    }
}

extension WeatherWaypoint {
    var currentWeather: WeatherData? {
        let sort = weather.sorted { $0.date < $1.date }
        let first = sort.first { $0.date.timeIntervalSince(time) > 0 }
        
        return first
    }
}

struct WeatherData {
    var date: Date
    var wind: WindData?
    var currentDirection: Double?
    var currentSpeed: Double?
    var waveHeight: Double?
    var waveDirection: Double?
    var symbolName: String?
    
    init(weatherKit: HourWeather) {
        self.date = weatherKit.date
        self.wind = WindData(compassDirection: weatherKit.wind.compassDirection, direction: weatherKit.wind.direction, speed: weatherKit.wind.speed, gust: weatherKit.wind.gust)
        self.currentDirection = nil
        self.currentSpeed = nil
        self.waveHeight = nil
        self.waveDirection = nil
        self.symbolName = weatherKit.symbolName
    }
    
    init() {
        date = Date()
    }
}

let measurementFormatter = MeasurementFormatter()

struct WindData {
    var compassDirection: Wind.CompassDirection
    var direction: Measurement<UnitAngle>
    var speed: Measurement<UnitSpeed>
    var gust: Measurement<UnitSpeed>?
    
    init(compassDirection: Wind.CompassDirection, direction: Measurement<UnitAngle>, speed: Measurement<UnitSpeed>, gust: Measurement<UnitSpeed>? = nil) {
        self.compassDirection = compassDirection
        self.direction = direction
        self.speed = speed
        self.gust = gust
    }
}

extension WindData {
    var speedString: String {
        measurementFormatter.string(from: speed)
    }
    
    var directionString: String {
        measurementFormatter.string(from: direction)
    }
}

extension Collection where Element: Waypoint {
    var mapRect: MKMapRect {
        // let mapEdgePadding = UIEdgeInsets(top: 70, left: 70, bottom: 70, right: 70)
        var zoomRect = MKMapRect.null

        for annotation in self {
            let aPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
                
        return zoomRect
    }
    
    var region: MKCoordinateRegion {
        var region = MKCoordinateRegion(mapRect)
        
        region.span.latitudeDelta += 5
        region.span.longitudeDelta += 5
        
        return region
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        map { $0.coordinate }
    }
    
    var points: [MKMapPoint] {
        map { MKMapPoint($0.coordinate) }
    }
}

extension CustomWaypoint {
    static func samples() -> [CustomWaypoint] {
        let london = CustomWaypoint(position: 1, latitude: 51.5074, longitude: -0.1278)
        let manchester = CustomWaypoint(position: 2, latitude: 53.4808, longitude: -2.2426)
        let edinburgh = CustomWaypoint(position: 3, latitude: 55.9533, longitude: -3.1883)
        
        return [london, manchester, edinburgh]
    }
}

extension WeatherData {
    
    static func sample() -> WeatherData {
        var weather = WeatherData()
        let wind = WindData(compassDirection: .east, direction: .init(value: 90, unit: .degrees), speed: .init(value: 10, unit: .knots))
        
        weather.currentSpeed = 1.0
        weather.currentDirection = 44
        weather.waveHeight = 0.3
        weather.waveDirection = 90
        weather.wind = wind
        weather.symbolName = "cloud.sun"
        
        return weather
    }
}
