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

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var weatherDataHelper = WeatherDataHelper.shared
    @ObservedObject var userLocationHelper = LocationManager.shared
    
    @State private var route: Route = Route()
    @State private var predictedRoute: Route? = nil
    @State private var selectedItem: MKAnnotation? = nil
    
    private var routeCalcService = RouteCalculationService(boat: Boat())
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
    
    var body: some View {
        MapView(region: $region, items: $route.annotations, selectedItem: $selectedItem, customAnnotation: { annotation in
            return WeatherAnnotationView(annotation: annotation, reuseIdentifier: "weather")
        }, onLongPress: { coordinate in
            let waypoint = Waypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            route.waypoints.append(waypoint)
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Calculate") {
                    routeCalcService.route = route
                    predictedRoute = routeCalcService.calculatePredictedRoute()
                }
            }
        }
        .toolbarBackground(.visible, for: .bottomBar)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
