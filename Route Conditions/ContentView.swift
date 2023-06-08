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

class WeatherItem: NSObject, MKAnnotation, Identifiable {
    var coordinate: CLLocationCoordinate2D
    var windSpeed: String?
    var windGustSpeed: String?
    var windDirectionImageName: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    var title: String? {
        windSpeed
    }
    
    var subtitle: String? {
        windGustSpeed
    }
    
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var weatherDataHelper = WeatherDataHelper.shared
    @ObservedObject var userLocationHelper = LocationManager.shared
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var items: [WeatherItem] = []
    @State private var selectedItem: WeatherItem?
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .onChange(of: selectedItem) {
            loadCurrentWeatherData()
        }
        .sheet(item: $selectedItem) {
            // On dismiss
            selectedItem = nil
        } content: { item in
            Form {
                Section {
                    locationWeather
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    func getWeather(coordinate: CLLocationCoordinate2D) async {
        do {
            let item = WeatherItem(coordinate: coordinate)
            let forcast = try await WeatherService.shared.weather(
                for: item.location,
                including: .current)
            
            item.windSpeed = forcast.wind.speed.formatted()
            item.windGustSpeed = forcast.wind.gust?.formatted()
            item.windDirectionImageName = forcast.wind.compassDirection.imageName
            
            DispatchQueue.main.async {
                items.append(item)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var locationWeather: some View {
        Section {
            if let currentWeather = weatherDataHelper.currentWeather {
                Label(currentWeather.condition.description, systemImage: currentWeather.symbolName)
                Label(currentWeather.temperature.formatted(), systemImage: "thermometer")
                Label("\(Int(currentWeather.humidity * 100))%", systemImage: "humidity.fill")
                Label(currentWeather.wind.compassDirection.description, systemImage: currentWeather.wind.compassDirection.imageName)
                Label(currentWeather.wind.speed.formatted() + ", max: " + (currentWeather.wind.gust?.formatted() ?? "-"), systemImage: "wind")
                Label(currentWeather.pressure.formatted() + ", " + currentWeather.pressureTrend.description, systemImage: "barometer")
                Label(currentWeather.isDaylight ? "Day time" : "Night time", systemImage: currentWeather.isDaylight ? "sun.max.fill" : "moon.stars.fill")
            }
        }
    }
    
    var attribution: some View {
        HStack(spacing: 8.0) {
            if let attribution = weatherDataHelper.attributionInfo {
                AsyncImage(url: colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                } placeholder: {
                    ProgressView()
                }
                Link("more", destination: attribution.legalPageURL)
            }
        }
    }
    
    func loadUserCurrentLocation() {
        userLocationHelper.requestPermission()
        userLocationHelper.locationManager.requestLocation()
    }
    
    func loadCurrentWeatherData() {
        guard let selectedItem else { return }
        Task.detached { @MainActor in
            weatherDataHelper.updateCurrentWeather(location: selectedItem.location)
            weatherDataHelper.updateAttributionInfo()
        }
    }
    
    func loadHourlyWeatherData() {
        guard let selectedItem else { return }
        Task.detached { @MainActor in
            weatherDataHelper.updateHourlyWeather(userLocation: selectedItem.location)
            weatherDataHelper.updateAttributionInfo()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
