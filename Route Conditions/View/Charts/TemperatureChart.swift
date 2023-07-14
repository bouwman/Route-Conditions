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
    private let maxValue: Double = 40
    private let tempFormat = Measurement<UnitTemperature>.FormatStyle(width: .abbreviated, usage: .weather)
    
    var body: some View {
        if temperatures.count == 0 || temperatures.first?.air == nil {
            Text("No Data")
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            Chart(temperatures) { temp in
                if let air = temp.air {
                    // TODO: Adapt max value based on unit settings
                    AreaMark(x: .value("Area", temp.date), y: .value("Max Value", maxValue))
                        .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
                        .mask {
                            LineMark(x: .value("Time", temp.date), y: .value("Temperature Value", air.value), series: .value("Temperature Series", "A"))
                                .interpolationMethod(.monotone)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                    
                }
                if let symbol = temp.symbolName, Calendar.current.component(.hour, from: temp.date) % 3 == 0 {
                    PointMark(x: .value("Date", temp.date), y: .value("Symbol", maxValue + 10))
                        .symbol {
                            Image(systemName: symbol)
                                .symbolRenderingMode(.multicolor)
                        }
                }
            }
            .chartYScale(domain: [0, maxValue + 10])
            .chartYAxis {
                AxisMarks(values: [0, 20, maxValue])
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    if let date = value.as(Date.self) {
                        let hour = Calendar.current.component(.hour, from: date)
                        AxisValueLabel {
                            VStack(alignment: .leading) {
                                switch hour {
                                case 0, 12:
                                    Text(date, format: .dateTime.hour())
                                default:
                                    Text(date, format: .dateTime.hour())
                                }
                                if value.index == 0 || hour == 0 {
                                    Text(date, format: .dateTime.month().day())
                                }
                            }
                        }
                        if hour == 0 {
                            AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        } else {
                            AxisTick()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        Section("Temperature") {
            TemperatureChart(temperatures: tempSamples)
                .padding(.vertical)
        }
        
        Section("Other") {
            TemperatureChart(temperatures: [Temperature()])
                .padding(.vertical)
        }
    }
}

private let tempSamples: [Temperature] = {
    let temp1 = Temperature(date: Date(), air: .init(value: 19.0, unit: .celsius), water: .init(value: 17.2, unit: .celsius), symbolName: "sun.max")
    let temp2 = Temperature(date: Date(timeIntervalSinceNow: 1 * 60 * 60), air: .init(value: 19.0, unit: .celsius), water: .init(value: 17.2, unit: .celsius), symbolName: "sun.max.fill")
    let temp3 = Temperature(date: Date(timeIntervalSinceNow: 2 * 60 * 60), air: .init(value: 20.5, unit: .celsius), water: .init(value: 17.3, unit: .celsius), symbolName: "sun.max.fill")
    let temp4 = Temperature(date: Date(timeIntervalSinceNow: 3 * 60 * 60), air: .init(value: 23.1, unit: .celsius), water: .init(value: 17.5, unit: .celsius), symbolName: "sun.max.fill")
    let temp5 = Temperature(date: Date(timeIntervalSinceNow: 4 * 60 * 60), air: .init(value: 25.6, unit: .celsius), water: .init(value: 17.8, unit: .celsius), symbolName: "sun.max.fill")
    let temp6 = Temperature(date: Date(timeIntervalSinceNow: 5 * 60 * 60), air: .init(value: 24.3, unit: .celsius), water: .init(value: 18.1, unit: .celsius), symbolName: "sun.max.fill")
    let temp7 = Temperature(date: Date(timeIntervalSinceNow: 6 * 60 * 60), air: .init(value: 23.5, unit: .celsius), water: .init(value: 18.0, unit: .celsius), symbolName: "sun.max.fill")
    
    return [temp1, temp2, temp3, temp4, temp5, temp6, temp7]
}()
