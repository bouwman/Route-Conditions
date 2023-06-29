//
//  WeatherParameterMarker.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import SwiftUI
import MapKit

struct WeatherParameterMarker: MapContent {
    @Binding var weatherParameter: WeatherParameter
    var coordinate: CLLocationCoordinate2D
    var time: Date
    var weather: Weather?
    
    init(weatherParameter: Binding<WeatherParameter>, coordinate: CLLocationCoordinate2D, time: Date, weather: Weather? = nil) {
        self._weatherParameter = weatherParameter
        self.coordinate = coordinate
        self.time = time
        self.weather = weather
    }
    
    var body: some MapContent {
        if let weather {
            switch weatherParameter {
            case .wind:
                if let speed = weather.wind.speed, let compassDirection = weather.wind.compassDirection {
                    Marker(speed.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                        .tint(.blue)
                } else {
                    Marker(weather.timeString, systemImage: "viewfinder", coordinate: coordinate)
                        .tint(.blue)
                }
            case .current:
                if let speed = weather.current.speed, let compassDirection = weather.current.compassDirection {
                    Marker(speed.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                        .tint(.blue)
                } else {
                    Marker(weather.timeString, systemImage: "viewfinder", coordinate: coordinate)
                        .tint(.blue)
                }
            case .waves:
                if let height = weather.waves.height, let compassDirection = weather.waves.compassDirection {
                    Marker(height.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                        .tint(.blue)
                } else {
                    Marker(weather.timeString, systemImage: "viewfinder", coordinate: coordinate)
                        .tint(.blue)
                }
            case .conditions:
                if let title = weather.conditions.title, let symbolName = weather.conditions.symbolName {
                    Marker(title, systemImage: symbolName, coordinate: coordinate)
                        .tint(.blue)
                } else {
                    Marker(weather.timeString, systemImage: "viewfinder", coordinate: coordinate)
                        .tint(.blue)
                }
            case .time:
                if let daylightSymbolName = weather.solar.daylightSymbolName {
                    Marker(weather.timeString, systemImage: daylightSymbolName, coordinate: coordinate)
                        .tint(.blue)
                } else {
                    Marker(weather.timeString, systemImage: "viewfinder", coordinate: coordinate)
                        .tint(.blue)
                }
            }
        } else {
            Marker(time.formatted(date: .omitted, time: .shortened), systemImage: "viewfinder", coordinate: coordinate)
                .tint(.blue)
        }
    }
}
