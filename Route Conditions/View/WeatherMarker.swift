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
    var weather: WeatherData?
    
    init(weatherAttribute: Binding<WeatherParameter>, coordinate: CLLocationCoordinate2D, time: Date, weather: WeatherData? = nil) {
        self._weatherAttribute = weatherAttribute
        self.coordinate = coordinate
        self.time = time
        self.weather = weather
    }
    
    var body: some MapContent {
        if let weather {
            switch weatherAttribute {
            case .wind:
                if let wind = weather.wind, let speed = wind.speed, let compassDirection = wind.compassDirection {
                    Marker(speed.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .current:
                if let current = weather.current, let speed = current.speed, let compassDirection = current.compassDirection {
                    Marker(speed.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .waves:
                if let waves = weather.waves, let height = waves.height, let compassDirection = waves.compassDirection {
                    Marker(height.formatted(), systemImage: compassDirection.imageName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .conditions:
                if let conditions = weather.conditions, let title = conditions.title, let symbolName = conditions.symbolName {
                    Marker(title, systemImage: symbolName, coordinate: coordinate)
                } else {
                    Marker(weather.timeString, systemImage: "questionmark", coordinate: coordinate)
                }
            case .time:
                if let timeInfo = weather.timeInfo, let daylightSymbolName = timeInfo.daylightSymbolName {
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
