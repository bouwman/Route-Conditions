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
                    AreaMark(x: .value("Area", wave.date), y: .value("Max Value", 6))
                        .foregroundStyle(.linearGradient(colors: [.blue, .cyan, .yellow, .red, .darkBrown], startPoint: .bottom, endPoint: .top))
                        .mask {
                            LineMark(x: .value("Time", wave.date), y: .value("Height", height.value), series: .value("Wave Height", "A"))
                                .interpolationMethod(.monotone)
                                .foregroundStyle(.primary)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                }
            }
            .chartYScale(domain: [0, 6])
            if waves.count == 0 || waves.first?.height == nil {
                Text("No Data")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}
