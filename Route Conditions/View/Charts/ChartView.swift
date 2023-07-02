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
                    .padding(.vertical)
                    .frame(minHeight: 150)
            }
            Section("Wind") {
                WindChart(winds: weatherWaypoints.map { $0.currentWeather?.wind ?? Wind() })
                    .padding(.vertical)
                    .frame(minHeight: 150)
            }
            Section("Waves") {
                WaveChart(waves: weatherWaypoints.map { $0.currentWeather?.waves ?? Wave() })
                    .padding(.vertical)
                    .frame(minHeight: 150)
            }
            Section("Current") {
                CurrentChart(currents: weatherWaypoints.map { $0.currentWeather?.current ?? Current() })
                    .padding(.vertical)
                    .frame(minHeight: 150)
            }
        }
    }
}
