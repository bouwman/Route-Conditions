//
//  ContentView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 19.05.23.
//

import SwiftUI
import WeatherKit
import CoreLocation
import MapKit

class Item: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var weatherDataHelper = WeatherDataHelper.shared
    @ObservedObject var userLocationHelper = LocationManager.shared
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
    @State private var items: [Item] = []
    @State private var selectedItem: Item?
    
    var body: some View {
        MapClusterView(region: $region, items: $items, selectedItem: $selectedItem) { coordinate in
            items.append(Item(coordinate: coordinate))
        }
            .ignoresSafeArea(edges: .vertical)
    }
    
    var form: some View {
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
                } footer: {
                    attribution
                }
            }
            if let hourlyWeather = weatherDataHelper.hourlyForecast {
                Section {
                    ForEach(hourlyWeather, id: \.self.date) { weatherEntry in
                        HStack {
                            Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .short, timeStyle: .short))
                            Spacer()
                            Image(systemName: weatherEntry.symbolName)
                            Text(weatherEntry.temperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
                        }
                    }
                } footer: {
                    attribution
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
        }
    }
    
    var attribution: some View {
        HStack {
            Spacer()
            VStack {
                if let attribution = weatherDataHelper.attributionInfo {
                    AsyncImage(url: colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    } placeholder: {
                        ProgressView()
                    }
                    Link("more", destination: attribution.legalPageURL)
                }
            }
            Spacer()
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
            weatherDataHelper.updateAttributionInfo()
        }
    }
    
    func loadHourlyWeatherData() {
        guard let userLocation = LocationManager.shared.userLocation else {
            return
        }
        Task.detached { @MainActor in
            weatherDataHelper.updateHourlyWeather(userLocation: userLocation)
            weatherDataHelper.updateAttributionInfo()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
