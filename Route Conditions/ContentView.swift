//
//  ContentView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.05.23.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    
    @ObservedObject var weatherDataHelper = WeatherDataHelper.shared
    @ObservedObject var userLocationHelper = LocationManager.shared
    
    var body: some View {
        Form {
            if let currentWeather = weatherDataHelper.currentWeather {
                Section {
                    Label(currentWeather.temperature.formatted(), systemImage: "thermometer")
                    Label("\(Int(currentWeather.humidity * 100))%", systemImage: "humidity.fill")
                    Label(currentWeather.isDaylight ? "Day time" : "Night time", systemImage: currentWeather.isDaylight ? "sun.max.fill" : "moon.stars.fill")
                } header: {
                    HStack {
                        Spacer()
                        Image(systemName: currentWeather.symbolName)
                            .font(.system(size: 60))
                        Spacer()
                    }
                }
            }
            Section {
                if userLocationHelper.userLocation == nil {
                    Button("Load user current location") {
                        loadUserCurrentLocation()
                    }
                }
                Button("Fetch current weather") {
                    loadCurrentWeatherData()
                }
                Button("Fetch hourly weather") {
                    loadHourlyWeatherData()
                }
            }
            if let hourlyWeather = weatherDataHelper.hourlyForecast {
                ForEach(hourlyWeather, id: \.self.date) { weatherEntry in
                    HStack {
                        Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .short, timeStyle: .short))
                        Spacer()
                        Image(systemName: weatherEntry.symbolName)
                        Text(weatherEntry.temperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
                    }
                }
            }
        }
    }
    
    func loadUserCurrentLocation() {
        userLocationHelper.requestPermission()
        userLocationHelper.locationManager.requestLocation()
    }
    
    func loadCurrentWeatherData() {
        guard let userLocation = LocationManager.shared.userLocation else {
            return
        }
        Task.detached { @MainActor in
            weatherDataHelper.updateCurrentWeather(userLocation: userLocation)
        }
    }
    
    func loadHourlyWeatherData() {
        guard let userLocation = LocationManager.shared.userLocation else {
            return
        }
        Task.detached { @MainActor in
            weatherDataHelper.updateHourlyWeather(userLocation: userLocation)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
