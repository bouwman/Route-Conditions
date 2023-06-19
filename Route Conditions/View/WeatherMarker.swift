//
//  WeatherMarker.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import SwiftUI
import MapKit

struct WeatherMarker: MapContent {
    @Binding var weatherAttribute: WeatherAttribute
    var coordinate: CLLocationCoordinate2D
    var weather: WeatherData?
    
    init(weatherAttribute: Binding<WeatherAttribute>, coordinate: CLLocationCoordinate2D, weather: WeatherData? = nil) {
        self._weatherAttribute = weatherAttribute
        self.coordinate = coordinate
        self.weather = weather
    }
    
    var body: some MapContent {
        if let weather {
            switch weatherAttribute {
            case .wind:
                if let wind = weather.wind {
                    Marker(wind.speed.string, systemImage: wind.compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.dateString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .current:
                if let current = weather.current {
                    Marker(current.speed.string, systemImage: current.compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.dateString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .waves:
                if let waves = weather.waves {
                    Marker(waves.height.string, systemImage: waves.compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.dateString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .conditions:
                if let conditions = weather.conditions {
                    Marker(conditions.description, systemImage: conditions.symbolName, coordinate: coordinate)
                } else {
                    Marker(weather.dateString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .time:
                if let timeInfo = weather.timeInfo {
                    Marker(weather.dateString, systemImage: timeInfo.daylightSymbolName, coordinate: coordinate)
                } else {
                    Marker(weather.dateString, systemImage: "questionmark", coordinate: coordinate)
                }
            }
        } else {
            Marker("No data", systemImage: "questionmark", coordinate: coordinate)
        }
    }
}
