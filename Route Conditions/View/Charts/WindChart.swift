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
                    LineMark(x: .value("Time", wind.date), y: .value("Speed", speed.value), series: .value("Wind Speed", "A"))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.primary)
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
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
