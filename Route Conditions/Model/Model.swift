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
    
    var weather: [WeatherData] = []
    
    init(position: Int, latitude: Double, longitude: Double, time: Date) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
    }
}

@Model class WeatherData {
    var date: Date
    var wind: WindData?
    var current: CurrentData?
    var waves: WaveData?
    var conditions: ConditionsData?
    var timeInfo: TimeData?
    
    init(weatherKit: HourWeather) {
        self.date = weatherKit.date
        self.wind = WindData(speed: weatherKit.wind.speed, direction: weatherKit.wind.direction, gust: weatherKit.wind.gust)
        self.conditions = ConditionsData(title: weatherKit.condition.description, symbolName: weatherKit.symbolName)
        self.timeInfo = TimeData(isDaylight: weatherKit.isDaylight)
        self.current = nil
        self.waves = nil
    }
    
    init(weatherKit: DayWeather) {
        self.date = weatherKit.date
        self.wind = WindData(speed: weatherKit.wind.speed, direction: weatherKit.wind.direction, gust: weatherKit.wind.gust)
        self.conditions = ConditionsData(title: weatherKit.condition.description, symbolName: weatherKit.symbolName)
        self.current = nil
        self.waves = nil
        self.timeInfo = nil
    }
    
    init() {
        date = Date()
    }
}

@Model class WindData {
    var speedData: Double
    var directionData: Double
    var gustData: Double?
    
    init(speed: Measurement<UnitSpeed>, direction: Measurement<UnitAngle>, gust: Measurement<UnitSpeed>? = nil) {
        self.speedData = speed.converted(to: .kilometersPerHour).value
        self.directionData = direction.converted(to: .degrees).value
        self.gustData = gust?.converted(to: .kilometersPerHour).value
    }
}

@Model class CurrentData {
    var speedData: Double
    var directionData: Double
    
    init(speed: Measurement<UnitSpeed>, direction: Measurement<UnitAngle>) {
        self.speedData = speed.converted(to: .kilometersPerHour).value
        self.directionData = direction.converted(to: .degrees).value
    }
}

@Model class WaveData {
    var heightData: Double
    var directionData: Double
    
    init(height: Measurement<UnitLength>, direction: Measurement<UnitAngle>) {
        self.heightData = height.converted(to: .meters).value
        self.directionData = direction.converted(to: .degrees).value
    }
}

@Model class ConditionsData {
    var title: String
    var symbolName: String
    
    init(title: String, symbolName: String) {
        self.title = title
        self.symbolName = symbolName
    }
}

@Model class TimeData {
    var isDaylight: Bool
    
    init(isDaylight: Bool) {
        self.isDaylight = isDaylight
    }
}
