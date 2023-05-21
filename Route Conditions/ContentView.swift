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

class WeatherAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.clusteringIdentifier = "weather"
        self.canShowCallout = true
        self.displayPriority = .defaultLow
        
        guard let weatherItem = annotation as? Item else { return }
        
        self.glyphText = weatherItem.temperature ?? "-"
        self.selectedGlyphImage = UIImage(systemName: "circle.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Item: NSObject, MKAnnotation, Identifiable {
    var coordinate: CLLocationCoordinate2D
    var temperature: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
        MapClusterView(region: $region, items: $items, selectedItem: $selectedItem, customAnnotation: { annotation in
            return WeatherAnnotationView(annotation: annotation, reuseIdentifier: "weather")
        }, onLongPress: { coordinate in
            let item = Item(coordinate: coordinate)
            i
            items.append(Item(coordinate: coordinate))
        })
        .onChange(of: selectedItem) { item in            
            loadCurrentWeatherData()
        }
        .ignoresSafeArea(edges: .vertical)
        .sheet(item: $selectedItem) {
            // On dismiss
            selectedItem = nil
        } content: { item in
            Form {
                Section {
                    locationWeather
                } footer: {
                    attribution
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    var locationWeather: some View {
        Section {
            if let currentWeather = weatherDataHelper.currentWeather {
                Label(currentWeather.temperature.formatted(), systemImage: "thermometer")
                Label("\(Int(currentWeather.humidity * 100))%", systemImage: "humidity.fill")
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
