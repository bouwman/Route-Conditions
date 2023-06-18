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

struct Vehicle {
    let id: UUID = UUID()
    var name: String
    var averageSpeed: Measurement<UnitSpeed>
    
    init(name: String, averageSpeed: Measurement<UnitSpeed>) {
        self.name = name
        self.averageSpeed = averageSpeed
    }
}

@Model final class CustomWaypoint: Waypoint {
    var position: Int
    @Attribute(.unique) var latitude: Double
    @Attribute(.unique) var longitude: Double
    
    init(position: Int, latitude: Double, longitude: Double) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
    }
}

@Model final class WeatherWaypoint: Waypoint, Equatable {
    var position: Int
    @Attribute(.unique) var latitude: Double
    @Attribute(.unique) var longitude: Double
    var time: Date
    
    @Transient var weather: [WeatherData] = []
    
    init(position: Int, latitude: Double, longitude: Double, time: Date) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
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
