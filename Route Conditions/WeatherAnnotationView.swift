//
//  WeatherAnnotationView.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 21.05.23.
//

import Foundation
import MapKit

class WeatherAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.clusteringIdentifier = "weather"
        self.displayPriority = .defaultLow
        self.subtitleVisibility = .visible
        self.titleVisibility = .visible
        self.animatesWhenAdded = true
        
        guard let weatherItem = annotation as? WeatherItem else { return }
        guard let imageName = weatherItem.windDirectionImageName else { return }
        
        self.glyphImage = UIImage(systemName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
