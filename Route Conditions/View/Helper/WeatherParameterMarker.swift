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
        switch weatherParameter {
        case .temperature:
            WeatherMarker(coordinate: coordinate, time: time, value: weather?.temperature.air?.formatted(), systemImage: weather?.conditions.symbolName, tint: weather?.temperature.scaleColor)
        case .wind:
            WeatherMarker(coordinate: coordinate, time: time, value: weather?.wind.speed?.formatted(), systemImage: weather?.wind.compassDirection?.imageName, tint: weather?.wind.scaleColor)
        case .current:
            WeatherMarker(coordinate: coordinate, time: time, value: weather?.current.speed?.formatted(unit: .knots), systemImage: weather?.current.compassDirection?.imageName, tint: weather?.current.scaleColor)
        case .waves:
            WeatherMarker(coordinate: coordinate, time: time, value: weather?.waves.height?.formatted(), systemImage: weather?.waves.compassDirection?.imageName, tint: weather?.waves.scaleColor)
        case .conditions:
            WeatherMarker(coordinate: coordinate, time: time, value: weather?.conditions.title, systemImage: weather?.conditions.symbolName, tint: weather?.conditions.scaleColor)
        case .time:
            WeatherMarker(coordinate: coordinate, time: time, value: weather?.timeString, systemImage: weather?.solar.daylightSymbolName, tint: weather?.solar.scaleColor)
        }
    }
}
