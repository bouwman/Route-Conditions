//
//  ChartView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 01.07.23.
//

import Foundation
import SwiftUI



struct ChartView: View {
    
    @Binding var weatherWaypoints: [WeatherWaypoint]
        
    var body: some View {
        List {
            Section("Temperature") {
                TemperatureChart(temperatures: weatherWaypoints.map { $0.currentWeather?.temperature ?? Temperature() })
                    .frame(minHeight: 150)
            }
            Section("Wind") {
                WindChart(winds: weatherWaypoints.map { $0.currentWeather?.wind ?? Wind() })
                    .frame(minHeight: 150)
            }
            Section("Waves") {
                WaveChart(waves: weatherWaypoints.map { $0.currentWeather?.waves ?? Wave() })
                    .frame(minHeight: 150)
            }
            Section("Current") {
                CurrentChart(currents: weatherWaypoints.map { $0.currentWeather?.current ?? Current() })
                    .frame(minHeight: 150)
            }
        }
    }
}
