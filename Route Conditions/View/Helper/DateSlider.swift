//
//  DateSlider.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 30.06.23.
//

import SwiftUI

struct DateSlider: View {
    
    @Binding var date: Date
    let range: ClosedRange<Date>
    let height: CGFloat
    let onEditingChanged: (Bool) -> Void
    
    init(date: Binding<Date>, range: ClosedRange<Date>, height: CGFloat, onEditingChanged: @escaping (Bool) -> Void) {
        self.height = height
        self.onEditingChanged = onEditingChanged
        self.range = range
        self.localRange = range.lowerBound.timeIntervalSince1970...range.upperBound.timeIntervalSince1970
        self._value = State(initialValue: date.wrappedValue.timeIntervalSince1970)
        self._date = date
    }
    
    @State private var value: Double
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
                            Circle()
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
                    value = max(min(getPrgValue(), localRange.upperBound), localRange.lowerBound)
                    date = Date(timeIntervalSince1970: value)
                }.onEnded { value in
                    localRealProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    localTempProgress = 0
                })
            .onChange(of: isActive) { oldValue, newValue in
                value = max(min(getPrgValue(), localRange.upperBound), localRange.lowerBound)
                date = Date(timeIntervalSince1970: value)
                onEditingChanged(newValue)
            }
            .onAppear {
                localRealProgress = getPrgPercentage(value)
            }
            .onChange(of: value) { oldValue, newValue in
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
        let correctedStartValue = value - localRange.lowerBound
        let percentage = correctedStartValue / range
        return percentage
    }
    
    private func getPrgValue() -> Double {
        return ((localRealProgress + localTempProgress) * (localRange.upperBound - localRange.lowerBound)) + localRange.lowerBound
    }
}

struct VolumeSlider<T: BinaryFloatingPoint>: View {
    @Binding var value: T
    let inRange: ClosedRange<T>
    let activeFillColor: Color
    let fillColor: Color
    let emptyColor: Color
    let height: CGFloat
    let onEditingChanged: (Bool) -> Void
    
    // private variables
    @State private var localRealProgress: T = 0
    @State private var localTempProgress: T = 0
    @GestureState private var isActive: Bool = false
    
    var body: some View {
        GeometryReader { bounds in
            ZStack {
                HStack {
                    Image(systemName: "speaker.fill")
                        .font(.system(.title2))
                        .foregroundColor(isActive ? activeFillColor : fillColor)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .center) {
                            Capsule()
                                .fill(emptyColor)
                            Capsule()
                                .fill(isActive ? activeFillColor : fillColor)
                                .mask({
                                    HStack {
                                        Rectangle()
                                            .frame(width: max(geo.size.width * CGFloat((localRealProgress + localTempProgress)), 0), alignment: .leading)
                                        Spacer(minLength: 0)
                                    }
                                })
                        }
                    }
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isActive ? activeFillColor : fillColor)
                }
                .frame(width: isActive ? bounds.size.width * 1.04 : bounds.size.width, alignment: .center)
//                .shadow(color: .black.opacity(0.1), radius: isActive ? 20 : 0, x: 0, y: 0)
                .animation(animation, value: isActive)
            }
            .frame(width: bounds.size.width, height: bounds.size.height, alignment: .center)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating($isActive) { value, state, transaction in
                    state = true
                }
                .onChanged { gesture in
                    localTempProgress = T(gesture.translation.width / bounds.size.width)
                    value = max(min(getPrgValue(), inRange.upperBound), inRange.lowerBound)
                }.onEnded { value in
                    localRealProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    localTempProgress = 0
                })
            .onChange(of: isActive) { newValue in
                value = max(min(getPrgValue(), inRange.upperBound), inRange.lowerBound)
                onEditingChanged(newValue)
            }
            .onAppear {
                localRealProgress = getPrgPercentage(value)
            }
            .onChange(of: value) { newValue in
                if !isActive {
                    localRealProgress = getPrgPercentage(newValue)
                }
            }
        }
        .frame(height: isActive ? height * 2 : height, alignment: .center)
    }
    
    private var animation: Animation {
        if isActive {
            return .spring()
        } else {
            return .spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.6)
        }
    }
    
    private func getPrgPercentage(_ value: T) -> T {
        let range = inRange.upperBound - inRange.lowerBound
        let correctedStartValue = value - inRange.lowerBound
        let percentage = correctedStartValue / range
        return percentage
    }
    
    private func getPrgValue() -> T {
        return ((localRealProgress + localTempProgress) * (inRange.upperBound - inRange.lowerBound)) + inRange.lowerBound
    }
}
