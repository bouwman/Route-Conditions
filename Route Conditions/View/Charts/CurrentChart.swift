//
//  CurrentChart.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 01.07.23.
//

import SwiftUI
import Charts

struct CurrentChart: View {
    
    var currents: [Current]
    
    private let maxValue: Double = 4
    private let currentFormat = Measurement<UnitSpeed>.FormatStyle(width: .abbreviated, usage: .wind)
    
    var body: some View {
        if currents.count == 0 || currents.first?.speed == nil {
            Text("No Data")
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            Chart(currents) { current in
                if let speed = current.speed {
                    AreaMark(x: .value("Area", current.date), y: .value("Max Value", maxValue))
                        .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
                        .mask {
                            LineMark(x: .value("Time", current.date), y: .value("Speed", speed.value), series: .value("Current Speed", "A"))
                                .interpolationMethod(.monotone)
                                .foregroundStyle(.primary)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                }
                if let direction = current.compassDirection, Calendar.current.component(.hour, from: current.date) % 3 == 0  {
                    PointMark(x: .value("Date", current.date), y: .value("Direction", maxValue + 0.5))
                        .symbol {
                            Image(systemName: direction.imageName)
                        }
                }
            }
            .chartYScale(domain: [0, maxValue + 1])
            .chartYAxis {
                AxisMarks(format: currentFormat, values: [.init(value: 0, unit: .knots), .init(value: 2, unit: .knots), .init(value: 4, unit: .knots)])
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
