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

struct Boat {
    var id: UUID
    var name: String
    var averageSpeed: Double
    var windInfluenceFactors: [Double] // Factors for each wind direction
    
    init(id: UUID, name: String, averageSpeed: Double, windInfluenceFactors: [Double]) {
        self.id = id
        self.name = name
        self.averageSpeed = averageSpeed
        self.windInfluenceFactors = windInfluenceFactors
    }
    
    init() {
        self.init(id: UUID(), name: "My Boat", averageSpeed: 5.0, windInfluenceFactors: [0.9, 1.0, 1.1])
    }
}

@Observable struct Route {
    var id: UUID = UUID()
    var name: String = "New Route"
    var waypoints: [Waypoint] = []
    
    var coordinates: [CLLocationCoordinate2D] {
        waypoints.map { $0.coordinate }
    }
    
    var annotations: [MKAnnotation] {
        get {
            access(keyPath: \.annotations)
            return waypoints.map { WaypointAnnotation(waypoint: $0) }
        }
        set {
            withMutation(keyPath: \.annotations) {
                waypoints = newValue.map { Waypoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            }
        }
    }
    
    private class WaypointAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        
        init(waypoint: Waypoint) {
            self.coordinate = waypoint.coordinate
        }
    }
}

struct Waypoint: Equatable, Identifiable {
    var latitude: Double
    var longitude: Double
    var time: Date
    var weather: WeatherData?
    
    var id: Double {
        return latitude + longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, time: Date, weather: WeatherData) {
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
        self.weather = weather
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.time = Date()
        self.weather = nil
    }
}

struct WeatherData: Equatable {
    var windDirection: Double
    var windSpeed: Double
    var oceanCurrentDirection: Double
    var oceanCurrentSpeed: Double
    var waveHeight: Double
    var waveDirection: Double
}
