//
//  Waypoint.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import MapKit

extension HasLocation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Collection where Element: Waypoint {
    var mapRect: MKMapRect {
        // let mapEdgePadding = UIEdgeInsets(top: 70, left: 70, bottom: 70, right: 70)
        var zoomRect = MKMapRect.null

        for annotation in self {
            let aPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
                
        return zoomRect
    }
    
    var region: MKCoordinateRegion {
        var region = MKCoordinateRegion(mapRect)
        
        region.span.latitudeDelta += 5
        region.span.longitudeDelta += 5
        
        return region
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        map { $0.coordinate }
    }
    
    var points: [MKMapPoint] {
        map { MKMapPoint($0.coordinate) }
    }
}

