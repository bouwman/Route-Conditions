//
//  Model.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation

struct Boat {
    var name: String
    var averageSpeed: Double
    var windFactors: [WindFactor]
}

struct WindFactor {
    var direction: Double
    var factor: Double
}

struct Route {
    var waypoints: [Waypoint]
    var departureDate: Date
    var arrivalDate: Date
    var defaultBoat: Boat
}

struct Waypoint {
    var location: Location
    var time: Date
    var weatherForecast: WeatherForecast
}

struct Location {
    var latitude: Double
    var longitude: Double
}

struct WeatherForecast {
    var windDirection: Double
    var windSpeed: Double
    var oceanCurrentDirection: Double
    var oceanCurrentSpeed: Double
    var waveHeight: Double
    var waveDirection: Double
}

struct MapSettings {
    var showWindDirection: Bool
    var showWindSpeed: Bool
    var showOceanCurrentDirection: Bool
    var showOceanCurrentSpeed: Bool
    var showWaveHeight: Bool
    var showWaveDirection: Bool
}
