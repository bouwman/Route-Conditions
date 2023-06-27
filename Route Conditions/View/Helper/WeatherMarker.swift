//
//  WeatherMarker.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import SwiftUI
import MapKit

struct WeatherMarker: MapContent {
    @Binding var weatherAttribute: WeatherParameter
    var coordinate: CLLocationCoordinate2D
    var time: Date
    var weather: Weather?
    
    init(weatherAttribute: Binding<WeatherParameter>, coordinate: CLLocationCoordinate2D, time: Date, weather: Weather? = nil) {
        self._weatherAttribute = weatherAttribute
        self.coordinate = coordinate
        self.time = time
        self.weather = weather
    }
    
    var body: some MapContent {
        if let weather {
            switch weatherAttribute {
            case .wind:
                if let speed = weather.wind.speed, let compassDirection = weather.wind.compassDirection {
                    Marker(speed.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .current:
                if let speed = weather.current.speed, let compassDirection = weather.current.compassDirection {
                    Marker(speed.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .waves:
                if let height = weather.waves.height, let compassDirection = weather.waves.compassDirection {
                    Marker(height.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .conditions:
                if let title = weather.conditions.title, let symbolName = weather.conditions.symbolName {
                    Marker(title, systemImage: symbolName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .time:
                if let daylightSymbolName = weather.solar.daylightSymbolName {
                    Marker(weather.timeString, systemImage: daylightSymbolName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            }
        } else {
            Marker(time.formatted(date: .omitted, time: .shortened), systemImage: "questionmark", coordinate: coordinate)
        }
    }
}
