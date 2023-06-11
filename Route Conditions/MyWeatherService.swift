//
//  WeatherService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation

class WeatherService {
    var apiKey: String
    var baseUrl: String
    
    init(apiKey: String, baseUrl: String) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
    }
    
    func getWeatherForecast(location: Location, date: Date) -> WeatherForecast {
        return WeatherForecast(windDirection: 1.0, windSpeed: 1.0, oceanCurrentDirection: 1.0, oceanCurrentSpeed: 1.0, waveHeight: 1.0, waveDirection: 1.0)
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
