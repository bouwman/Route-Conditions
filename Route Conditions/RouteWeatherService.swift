//
//  RouteWeatherService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation

class RouteWeatherService {
    private let apiKey: String = ""
    private let baseUrl: String = ""
    
    func getWeatherData(latitude: Double, longitude: Double, time: Date) -> WeatherData? {
        let exampleWeatherData = WeatherData(
            windDirection: 45.0,
            windSpeed: 10.0,
            oceanCurrentDirection: 90.0,
            oceanCurrentSpeed: 1.0,
            waveHeight: 2.0,
            waveDirection: 45.0
        )
        return exampleWeatherData
    }
    
    //    func getWeatherConditionsAtLocation(location: Location) -> WeatherConditions {
//        // Implementation goes here
//    }
//    
//    func getTideInformationAtLocation(location: Location) -> TideInformation {
//        // Implementation goes here
//    }
//    
//    func getSunriseAndSunsetTimesAtLocation(location: Location) -> SunriseAndSunsetTimes {
//        // Implementation goes here
//    }
}
