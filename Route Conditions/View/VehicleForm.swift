//
//  VehicleForm.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 22.06.23.
//

import SwiftUI
import Combine

struct VehicleForm: View {
    @Binding var vehicle: Vehicle
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Speed", selection: $vehicle.speed.value) {
                    ForEach(vehicle.type.speedRangeArray(unit: vehicle.unit), id:\.self) { speed in
                        Text(Measurement(value: Double(speed), unit: vehicle.unit).formatted(unit: vehicle.unit)).tag(Double(speed))
                    }
                }
                Picker("Unit", selection: $vehicle.unit) {
                    ForEach(UnitSpeed.all) { type in
                        Text(type.title).tag(type)
                    }
                }
            }
            .navigationTitle(vehicle.type.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VehicleForm(vehicle: .constant(Vehicle(averageSpeed: .init(value: 90, unit: .kilometersPerHour), type: .car)))
}
