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
    
    var body: some View {
        ZStack {
            Chart(waves) { wave in
                if let height = wave.height {
                    LineMark(x: .value("Time", wave.date), y: .value("Height", height.value), series: .value("Wave Height", "A"))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.primary)
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
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
