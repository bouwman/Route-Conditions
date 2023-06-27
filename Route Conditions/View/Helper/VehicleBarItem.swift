//
//  VehicleBarItem.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 27.06.23.
//

import SwiftUI

struct VehicleBarItem: ToolbarContent {
    @Binding var vehicle: Vehicle
    
    @ToolbarContentBuilder var body: some ToolbarContent {
        ToolbarItem(id: "vehicle_selection", placement: .secondaryAction) {
            Picker(selection: $vehicle) {
                ForEach(Vehicle.allSamples()) { vehicle in
                    Label(vehicle.type.title, systemImage: vehicle.type.imageName)
                }
            } label: {
                Label(vehicle.type.title, systemImage: vehicle.type.imageName)
            }
        }
    }
}
