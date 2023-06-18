//
//  WeatherMarker.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import SwiftUI
import MapKit

struct WeatherMarker: MapContent {
    var coordinate: CLLocationCoordinate2D
    var weather: WeatherData?
    
    var body: some MapContent {
        if let weather {
            if let wind = weather.wind {
                Marker(weather.dateString, systemImage: wind.compassDirection.imageName, coordinate: coordinate)
            } else if let symbolName = weather.symbolName {
                Marker(weather.dateString, systemImage: symbolName, coordinate: coordinate)
            } else {
                Marker(weather.dateString, systemImage: "exclamationmark.triangle", coordinate: coordinate)
            }
        } else {
            Marker("No data", systemImage: "questionmark", coordinate: coordinate)
        }
    }
}
