//
//  DateRangeSlider.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 15.07.23.
//

import SwiftUI

struct DateRangeSlider: View {
    
    @Binding var lowerBound: Date
    @Binding var upperBound: Date
    let range: ClosedRange<Date>
    let height: CGFloat
    
    init(lowerBound: Binding<Date>, upperBound: Binding<Date>, range: ClosedRange<Date>, height: CGFloat) {
        self.height = height
        self.range = range
        self.localRange = range.lowerBound.timeIntervalSince1970...range.upperBound.timeIntervalSince1970
        self._lowerValue = State(initialValue: lowerBound.wrappedValue.timeIntervalSince1970)
        self._lowerBound = lowerBound
        self._upperBound = upperBound
    }
    
    @State private var lowerValue: Double
    @State private var localRealProgress: Double = 0
    @State private var localTempProgress: Double = 0
    @GestureState private var isActive: Bool = false
    
    private let localRange: ClosedRange<Double>
    private let knobPadding: CGFloat = 4
    
    private func string(in numberOfDays: Int) -> String {
        let day = Calendar.current.date(byAdding: .day, value: numberOfDays, to: range.lowerBound)!
        return day.formatted(Date.FormatStyle().weekday(.abbreviated))
    }
    
    var body: some View {
        GeometryReader { bounds in
            ZStack {
                HStack {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.secondary)
                            HStack {
                                Spacer()
                                Text("Today")
                                Spacer()
                                Text(string(in: 1))
                                Spacer()
                                Text(string(in: 2))
                                Spacer()
                                Text(string(in: 3))
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .font(.caption2)
                            .bold()
                            RoundedRectangle(cornerRadius: height)
                                .fill(.white)
                                .padding(knobPadding)
                                .offset(x: min(max(geo.size.width * CGFloat(localRealProgress + localTempProgress), 0), geo.size.width - height - knobPadding * 3))
                        }
                    }
                }
                .frame(width: isActive ? bounds.size.width * 1.04 : bounds.size.width, alignment: .center)
                .shadow(color: .black.opacity(0.1), radius: isActive ? 20 : 0, x: 0, y: 0)
                .animation(animation, value: isActive)
            }
            .frame(width: bounds.size.width, height: bounds.size.height, alignment: .center)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating($isActive) { value, state, transaction in
                    state = true
                }
                .onChanged { gesture in
                    localTempProgress = Double(gesture.translation.width / bounds.size.width)
                    lowerValue = max(min(getPrgValue(), localRange.upperBound), localRange.lowerBound)
                    lowerBound = Date(timeIntervalSince1970: lowerValue)
                }.onEnded { value in
                    localRealProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    localTempProgress = 0
                })
            .onChange(of: isActive) { oldValue, newValue in
                lowerValue = max(min(getPrgValue(), localRange.upperBound), localRange.lowerBound)
                lowerBound = Date(timeIntervalSince1970: lowerValue)
            }
            .onAppear {
                localRealProgress = getPrgPercentage(lowerValue)
            }
            .onChange(of: lowerValue) { oldValue, newValue in
                if !isActive {
                    localRealProgress = getPrgPercentage(newValue)
                }
            }
        }
        .frame(height: isActive ? height * 1.3 : height, alignment: .center)
    }
    
    private var animation: Animation {
        if isActive {
            return .spring()
        } else {
            return .spring(duration: 0.3, bounce: 0, blendDuration: 0.0)
        }
    }
    
    private func getPrgPercentage(_ value: Double) -> Double {
        let range = localRange.upperBound - localRange.lowerBound
        let correctedStartValue = lowerValue - localRange.lowerBound
        let percentage = correctedStartValue / range
        return percentage
    }
    
    private func getPrgValue() -> Double {
        return ((localRealProgress + localTempProgress) * (localRange.upperBound - localRange.lowerBound)) + localRange.lowerBound
    }
}

#Preview {
    DateRangeSlider(lowerBound: .constant(Calendar.current.startOfDay(for: Date.now)), upperBound: .constant(Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24 * 2))), range: Calendar.current.startOfDay(for: Date.now)...Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)), height: 44)
}
