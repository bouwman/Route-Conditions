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
    
    var body: some View {
        ZStack {
            Chart(currents) { current in
                if let speed = current.speed {
                    LineMark(x: .value("Time", current.date), y: .value("Speed", speed.value), series: .value("Current Speed", "A"))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.primary)
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
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
