//
//  PersistenceService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import SwiftData

actor PersistenceService: ModelActor {
    nonisolated let executor: any ModelExecutor
    
    var context: ModelContext { executor.context }
    
    init(context: ModelContext) {
        executor = DefaultModelExecutor(context: context)
    }
    
    var isExistingDataEnough: Bool {
        
    }
    
    func createObject() -> [WeatherData] {
        let data = WeatherData()
        
        context.insert(data)
        
        return [data]
    }
    
    private func merge(forecasts: [WeatherData]...) throws -> [WeatherData] {
        var data: [WeatherData] = []
        
        for forecastArray in forecasts {
            for forecast in forecastArray {
                if let existing = data.first(where: { $0.date == forecast.date }) {
                    if existing.wind?.gustData != nil {
                        existing.wind?.gustData = forecast.wind?.gustData
                    }
                    if existing.wind?.speedData != nil {
                        existing.wind?.speedData = forecast.wind?.speedData
                    }
                    if existing.wind?.directionData != nil {
                        existing.wind?.directionData = forecast.wind?.directionData
                    }
                    if existing.current?.speedData != nil {
                        existing.current?.speedData = forecast.current?.speedData
                    }
                    if existing.current?.directionData != nil {
                        existing.current?.directionData = forecast.current?.directionData
                    }
                    if existing.waves?.heightData != nil {
                        existing.waves?.heightData = forecast.waves?.heightData
                    }
                    if existing.waves?.directionData != nil {
                        existing.waves?.directionData = forecast.waves?.directionData
                    }
                    if existing.conditions?.title != nil {
                        existing.conditions?.title = forecast.conditions?.title
                    }
                    if existing.conditions?.symbolName != nil {
                        existing.conditions?.symbolName = forecast.conditions?.symbolName
                    }
                    if existing.timeInfo?.isDaylight != nil {
                        existing.timeInfo?.isDaylight = forecast.timeInfo?.isDaylight
                    }
                } else {
                    data.append(forecast)
                }
            }
        }
        
        return data.sorted(by: { $0.date > $1.date })
    }
}
