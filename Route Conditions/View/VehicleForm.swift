//
//  VehicleForm.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 22.06.23.
//

import SwiftUI
import Combine

private let speedFormatter = MeasurementFormatter()

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimum = .init(integerLiteral: 1)
    formatter.maximum = .init(integerLiteral: Int.max)
    formatter.maximumFractionDigits = 1
    return formatter
}()

struct VehicleForm: View {
    @Binding var vehicle: Vehicle
    
    var body: some View {
        Form {
            HStack {
                #if !os(macOS)
                Text("Name")
                Spacer()
                #endif
                TextField("My Vehicle", text: $vehicle.name)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
            }
            HStack {
                #if !os(macOS)
                Text("Average Speed")
                Spacer()
                #endif
                TextField(vehicle.unit.title, text: $vehicle.speedString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            Picker("Unit", selection: $vehicle.unit) {
                ForEach(UnitSpeed.all) { type in
                    Text(type.title)
                }
            }
            Picker("Type", selection: $vehicle.type) {
                ForEach(VehicleType.all) { type in
                    Label(type.title, systemImage: type.imageName)
                }
            }
        }
    }
}

#Preview {
    VehicleForm(vehicle: .constant(Vehicle(name: "My Vehicle", averageSpeed: .init(value: 90, unit: .kilometersPerHour), type: .car)))
}
