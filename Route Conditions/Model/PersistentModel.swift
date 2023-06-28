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

@Model final class CustomWaypointData: Waypointable {
    @Attribute(.unique) var latitude: Double
    @Attribute(.unique) var longitude: Double
    
    var position: Int
    
    init(position: Int, latitude: Double, longitude: Double) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
    }
}

@Model final class WeatherWaypointData: Waypointable, Equatable {
    @Attribute(.unique) var latitude: Double
    @Attribute(.unique) var longitude: Double
    
    @Relationship(.cascade, inverse: \WeatherData.waypoint) var weather: [WeatherData] = []
    
    var position: Int
    var date: Date
    
    init(position: Int, latitude: Double, longitude: Double, date: Date) {
        self.position = position
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
    }
}

@Model class WeatherData: HasLocation {
    var date: Date
    var latitude: Double
    var longitude: Double
    
    @Relationship(.cascade) var wind: WindData
    @Relationship(.cascade) var current: CurrentData
    @Relationship(.cascade) var waves: WaveData
    @Relationship(.cascade) var conditions: ConditionsData
    @Relationship(.cascade) var solar: SolarData
    @Relationship(.cascade) var waypoint: WeatherWaypointData
    
    init(convertible: WeatherModelConvertible, coordinate: CLLocationCoordinate2D) {
        self.date = convertible.convertedDate
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.wind = WindData(speedData: convertible.convertedWindSpeed, directionData: convertible.convertedWindDirection, gustData: convertible.convertedWindGust)
        self.current = CurrentData(speedData: convertible.convertedCurrentSpeed, directionData: convertible.convertedCurrentDirection)
        self.waves = WaveData(heightData: convertible.convertedWaveHeight, directionData: convertible.convertedWaveDirection)
        self.conditions = ConditionsData(title: convertible.convertedConditionsTitle, symbolName: convertible.convertedConditionsSymbol)
        self.solar = SolarData(isDaylight: convertible.convertedSolarIsDaylight)
    }
    
    init() { }
}

@Model class WindData {
    var speedData: Double?
    var directionData: Double?
    var gustData: Double?
    
    init(speedData: Double? = nil, directionData: Double? = nil, gustData: Double? = nil) {
        self.speedData = speedData
        self.directionData = directionData
        self.gustData = gustData
    }
}

@Model class CurrentData {
    var speedData: Double?
    var directionData: Double?
    
    init(speedData: Double? = nil, directionData: Double? = nil) {
        self.speedData = speedData
        self.directionData = directionData
    }
}

@Model class WaveData {
    var heightData: Double?
    var directionData: Double?
    
    init(heightData: Double? = nil, directionData: Double? = nil) {
        self.heightData = heightData
        self.directionData = directionData
    }
}

@Model class ConditionsData {
    var title: String?
    var symbolName: String?
    
    init(title: String? = nil, symbolName: String? = nil) {
        self.title = title
        self.symbolName = symbolName
    }
}

@Model class SolarData {
    var isDaylight: Bool?
    
    init(isDaylight: Bool?) {
        self.isDaylight = isDaylight
    }
}