//
//  WeatherMarker.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 28.06.23.
//

import SwiftUI
import MapKit
import CoreLocation

struct WeatherMarker: MapContent {
    var coordinate: CLLocationCoordinate2D
    var time: Date
    var value: String?
    var systemImage: String?
    var tint: Color?
    
    init(coordinate: CLLocationCoordinate2D, time: Date, value: String?, systemImage: String?, tint: Color?) {
        self.coordinate = coordinate
        self.time = time
        self.value = value
        self.systemImage = systemImage
        self.tint = tint
    }
    
    var body: some MapContent {
        if let value, let systemImage{
            Marker(value, systemImage: systemImage, coordinate: coordinate)
                .tint(tint ?? .gray)
        } else {
            Marker(time.formatted(date: .omitted, time: .shortened), systemImage: "circle", coordinate: coordinate)
                .tint(.gray)
        }
    }
}
