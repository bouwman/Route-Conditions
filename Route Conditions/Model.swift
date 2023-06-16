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

@Model class Vehicle {
    @Attribute var id: UUID
    @Attribute var name: String
    @Attribute var averageSpeed: Double
    
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
    @Attribute var name: String
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
    @Attribute var latitude: Double
    @Attribute var longitude: Double
    @Attribute var time: Date?
    
    var id: Double {
        return latitude + longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, time: Date? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
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
