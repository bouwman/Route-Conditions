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
    @Relationship(.cascade) var waypoints: [Waypoint]
    @Relationship(.cascade) var predictedWaypoints: [Waypoint]?
    
    init(name: String) {
        self.id = UUID()
        self.name = String("New Route")
        self.waypoints = []
        self.predictedWaypoints = []
    }
}

@Model class Waypoint {
    var position: Int
    var latitude: Double
    var longitude: Double
    var time: Date?
    @Relationship(.cascade) var weather: [WeatherData]
    
    var id: Double {
        return latitude + longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(position: Int, latitude: Double, longitude: Double, time: Date? = nil) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
    }
    
    var currentWeather: WeatherData? {
        guard let time else { return nil }
        let sort = weather.sorted { $0.date < $1.date }
        let first = sort.first { $0.date.timeIntervalSince(time) > 0 }
        
        return first
    }
}

@Model class WeatherData {
    var date: Date
    var wind: WindData?
    var currentDirection: Double?
    var currentSpeed: Double?
    var waveHeight: Double?
    var waveDirection: Double?
    var symbolName: String?
    
    init(weatherKit: HourWeather) {
        self.date = weatherKit.date
        self.wind = WindData(compassDirection: weatherKit.wind.compassDirection, windDirection: weatherKit.wind.direction, windSpeed: weatherKit.wind.speed, gust: weatherKit.wind.gust)
        self.currentDirection = nil
        self.currentSpeed = nil
        self.waveHeight = nil
        self.waveDirection = nil
        self.symbolName = weatherKit.symbolName
    }
    
    
}

@Model class WindData {
    var compassDirection: Wind.CompassDirection
    var windDirection: Double
    var windSpeed: Double
    var gust: Double?
    
    init(compassDirection: Wind.CompassDirection, windDirection: Measurement<UnitAngle>, windSpeed: Measurement<UnitSpeed>, gust: Measurement<UnitSpeed>? = nil) {
        self.compassDirection = compassDirection
        self.windDirection = windDirection.value
        self.windSpeed = windSpeed.value
        self.gust = gust?.value
    }
}

extension Collection where Element == Waypoint {
    var mapRect: MKMapRect {
        let mapEdgePadding = UIEdgeInsets(top: 70, left: 70, bottom: 70, right: 70)
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
    
    var coordinates: [CLLocationCoordinate2D] {
        map { $0.coordinate }
    }
}
