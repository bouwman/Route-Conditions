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
    
    var body: some View {
        ZStack {
            Chart(winds) { wind in
                if let speed = wind.speed {
                    AreaMark(x: .value("Area", wind.date), y: .value("Max Value", 60))
                        .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
                        .mask {
                            LineMark(x: .value("Time", wind.date), y: .value("Height", speed.value), series: .value("Wind Speed", "A"))
                                .interpolationMethod(.monotone)
                                .foregroundStyle(.primary)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                }
            }
            .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
            if winds.count == 0 || winds.first?.speed == nil {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}
