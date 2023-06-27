//
//  WeatherDetailView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import SwiftUI

struct WeatherDetailView: View {
    var waypoint: WeatherWaypoint
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let weather = waypoint.currentWeather, let symbolName = weather.conditions.symbolName, let compassDirection = weather.wind.compassDirection, let speed = weather.wind.speed {
                        Label(symbolName, systemImage: symbolName)
                        // Label(weather.temperature.formatted(), systemImage: "thermometer")
                        // Label("\(Int(currentWeather.humidity * 100))%", systemImage: "humidity.fill")
                        Label(compassDirection.description, systemImage: compassDirection.imageName)
                        Label(speed.formatted() + ", max: " + (weather.wind.gust?.formatted() ?? "-"), systemImage: "wind")
                        // Label(currentWeather.pressure.formatted() + ", " + currentWeather.pressureTrend.description, systemImage: "barometer")
                        // Label(currentWeather.isDaylight ? "Day time" : "Night time", systemImage: currentWeather.isDaylight ? "sun.max.fill" : "moon.stars.fill")
                    }
                }
            }
            .navigationTitle(waypoint.timeString)
        }
    }
}

//#Preview {
//    WeatherDetailView(waypoint: WeatherWaypoint.samples().first!)
//}
