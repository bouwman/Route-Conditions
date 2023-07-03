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
    
    private let maxValue: Double = 6
    private let currentFormat = Measurement<UnitSpeed>.FormatStyle(width: .abbreviated, usage: .wind)
    
    var body: some View {
        ZStack {
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
                if let direction = current.compassDirection {
                    PointMark(x: .value("Date", current.date), y: .value("Direction", maxValue + 6))
                        .symbol {
                            Image(systemName: direction.imageName)
                        }
                }
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
            if currents.count == 0 || currents.first?.speed == nil {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}
