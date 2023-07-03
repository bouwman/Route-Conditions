//
//  WindChart.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 01.07.23.
//

import SwiftUI
import Charts

struct WindChart: View {
    
    var winds: [Wind]
    
    private let maxValue: Double = 60
    private let windFormat = Measurement<UnitSpeed>.FormatStyle(width: .abbreviated, usage: .wind)
    
    var body: some View {
        ZStack {
            Chart(winds) { wind in
                if let speed = wind.speed {
                    AreaMark(x: .value("Area", wind.date), y: .value("Max Value", maxValue))
                        .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
                        .mask {
                            LineMark(x: .value("Time", wind.date), y: .value("Speed", speed.value), series: .value("Wind Speed", "A"))
                                .interpolationMethod(.monotone)
                                .foregroundStyle(.primary)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                }
                if let direction = wind.compassDirection {
                    PointMark(x: .value("Date", wind.date), y: .value("Direction", maxValue + 20))
                        .symbol {
                            Image(systemName: direction.imageName)
                        }
                }
            }
            .chartYScale(domain: [0, 100])
            .chartYAxis {
                AxisMarks(format: windFormat, values: [.init(value: 0, unit: .kilometersPerHour), .init(value: 30, unit: .kilometersPerHour), .init(value: 60, unit: .kilometersPerHour)])
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    if let date = value.as(Date.self) {
                        let hour = Calendar.current.component(.hour, from: date)
                        AxisValueLabel {
                            VStack(alignment: .leading) {
                                switch hour {
                                case 0, 12:
                                    Text(date, format: .dateTime.hour())
                                default:
                                    Text(date, format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
                                }
                                if value.index == 0 || hour == 0 {
                                    Text(date, format: .dateTime.month().day())
                                }
                            }
                        }
                        if hour == 0 {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        } else {
                            AxisGridLine()
                            AxisTick()
                        }
                    }
                }
            }
            if winds.count == 0 || winds.first?.speed == nil {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}

#Preview {
    List {
        Section("Wind") {
            WindChart(winds: windSamples)
                .frame(minHeight: 150)
        }
    }
}

var windSamples: [Wind] = {
    var samples: [Wind] = []
    
    for i in 0..<8 {
        let date = Date(timeIntervalSinceNow: Double(i) * 3600.0)
        let diration = Measurement(value: Double.random(in: 0...360), unit: UnitAngle.degrees)
        let speed = Measurement(value: Double.random(in: 2...35), unit: UnitSpeed.knots)
        let gusts = Measurement(value: Double.random(in: 20...35), unit: UnitSpeed.knots)
        
        samples.append(Wind(date: date, direction: diration, speed: speed, gust: gusts))
    }
    return samples
}()
