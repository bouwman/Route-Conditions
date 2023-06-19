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
    var current: CurrentData?
    var waves: WaveData?
    var conditions: ConditionsData?
    var timeInfo: TimeData?
    
    init(weatherKit: HourWeather) {
        self.date = weatherKit.date
        self.wind = WindData(speed: weatherKit.wind.speed, direction: weatherKit.wind.direction, compassDirection: weatherKit.wind.compassDirection, gust: weatherKit.wind.gust)
        self.current = nil
        self.waves = nil
        self.conditions = ConditionsData(description: weatherKit.condition.description, symbolName: weatherKit.symbolName)
        self.timeInfo = TimeData(isDaylight: weatherKit.isDaylight)
    }
    
    init() {
        date = Date()
    }
}

struct WindData {
    var speed: Measurement<UnitSpeed>
    var direction: Measurement<UnitAngle>
    var compassDirection: Wind.CompassDirection
    var gust: Measurement<UnitSpeed>?
}

struct CurrentData {
    var speed: Measurement<UnitSpeed>
    var direction: Measurement<UnitAngle>
    var compassDirection: Wind.CompassDirection
}

struct WaveData {
    var height: Measurement<UnitLength>
    var direction: Measurement<UnitAngle>
    var compassDirection: Wind.CompassDirection
}

struct ConditionsData {
    var description: String
    var symbolName: String
}

struct TimeData {
    var isDaylight: Bool
}
