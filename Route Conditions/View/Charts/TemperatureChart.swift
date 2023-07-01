//
//  TemperatureChart.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 01.07.23.
//

import SwiftUI
import Charts

struct TemperatureChart: View {
    
    var temperatures: [Temperature]
    
    var body: some View {
        ZStack {
            Chart(temperatures) { temp in
                if let air = temp.air {
                    LineMark(x: .value("Time", temp.date), y: .value("Temperature", air.value), series: .value("Temperature", "A"))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.primary)
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                }
            }
            if temperatures.count == 0 || temperatures.first?.air == nil {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}

#Preview {
    List {
        Section("Temperature") {
            TemperatureChart(temperatures: allSamples)
                .padding(.vertical)
        }
        
        Section("Other") {
            TemperatureChart(temperatures: [Temperature()])
                .padding(.vertical)
        }
    }    
}

private let allSamples: [Temperature] = {
    let temp1 = Temperature(date: Date(), air: .init(value: 19.0, unit: .celsius), water: .init(value: 17.2, unit: .celsius))
    let temp2 = Temperature(date: Date(timeIntervalSinceNow: 1 * 60 * 60), air: .init(value: 19.0, unit: .celsius), water: .init(value: 17.2, unit: .celsius))
    let temp3 = Temperature(date: Date(timeIntervalSinceNow: 2 * 60 * 60), air: .init(value: 20.5, unit: .celsius), water: .init(value: 17.3, unit: .celsius))
    let temp4 = Temperature(date: Date(timeIntervalSinceNow: 3 * 60 * 60), air: .init(value: 23.1, unit: .celsius), water: .init(value: 17.5, unit: .celsius))
    let temp5 = Temperature(date: Date(timeIntervalSinceNow: 4 * 60 * 60), air: .init(value: 25.6, unit: .celsius), water: .init(value: 17.8, unit: .celsius))
    let temp6 = Temperature(date: Date(timeIntervalSinceNow: 5 * 60 * 60), air: .init(value: 24.3, unit: .celsius), water: .init(value: 18.1, unit: .celsius))
    let temp7 = Temperature(date: Date(timeIntervalSinceNow: 6 * 60 * 60), air: .init(value: 23.5, unit: .celsius), water: .init(value: 18.0, unit: .celsius))

    return [temp1, temp2, temp3, temp4, temp5, temp6, temp7]
}()
