//
//  WaveChart.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 01.07.23.
//

import SwiftUI
import Charts

struct WaveChart: View {
    
    var waves: [Wave]
    
    private let maxValue: Double = 6
    
    var body: some View {
        ZStack {
            Chart(waves) { wave in
                if let height = wave.height {
                    AreaMark(x: .value("Area", wave.date), y: .value("Max Value", maxValue))
                        .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
                        .mask {
                            LineMark(x: .value("Time", wave.date), y: .value("Height", height.value), series: .value("Wave Height", "A"))
                                .interpolationMethod(.monotone)
                                .foregroundStyle(.primary)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                }
                if let direction = wave.compassDirection {
                    PointMark(x: .value("Date", wave.date), y: .value("Direction", maxValue + 1))
                        .symbol {
                            Image(systemName: direction.imageName)
                        }
                }
            }
            .chartYScale(domain: [0, maxValue + 2])
            .chartYAxis {
                AxisMarks(values: [0, 3, 6])
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
            if waves.count == 0 || waves.first?.height == nil {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}
