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
        Marker("", coordinate: coordinate)
    }
}
