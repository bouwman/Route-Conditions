//
//  WeatherBarItem.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 27.06.23.
//

import SwiftUI

struct WeatherBarItem: ToolbarContent {
    @Binding var weatherParameter: WeatherParameter
    
    @ToolbarContentBuilder var body: some ToolbarContent {
        ToolbarItem(id: "weather_selection", placement: .primaryAction) {
            Picker(selection: $weatherParameter) {
                ForEach(WeatherParameter.all) { attribute in
                    Label(attribute.string, systemImage: attribute.imageName)
                }
            } label: {
                Label(weatherParameter.string, systemImage: weatherParameter.imageName)
            }
        }
    }
}
