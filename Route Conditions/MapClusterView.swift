//
//  MapClusterView.swift
//  Tides and Currents
//
//  Created by Tassilo Bouwman on 07/12/2022.
//

import SwiftUI
import MapKit

#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif

struct MapClusterView <T>: ViewRepresentable where T: MKAnnotation {
    
    @Binding var region: MKCoordinateRegion
    @Binding var items: [T]
    @Binding var selectedItem: T?
    
    let onLongPress: (CLLocationCoordinate2D) -> ()
    
    lazy var locationService = LocationManager(accuracy: .greatestFiniteMagnitude)
    
    func makeCoordinator() -> Coordinator {
        MapClusterView.Coordinator(self)
    }
    
    #if os(iOS)
    
    func makeUIView(context: Context) -> MKMapView {
        return makeMapView(context: context)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if selectedItem == nil {
            for annotation in uiView.selectedAnnotations {
                uiView.deselectAnnotation(annotation, animated: true)
            }
        }
        uiView.addAnnotations(items)
    }
    
    #endif

    #if os(macOS)
    
    func makeNSView(context: Context) -> some NSView {
        return makeMapView(context: context)
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        if selectedItem == nil {
            for annotation in nsView.selectedAnnotations {
                nsView.deselectAnnotation(annotation, animated: true)
            }
        }
        nsView.addAnnotations(items)
    }
    
    #endif
    
    private func makeMapView(context: Context) -> MKMapView {
        ///  creating a map
        let view = MKMapView()
        /// connecting delegate with the map
        view.delegate = context.coordinator
        view.setRegion(region, animated: false)
        view.mapType = .standard
        view.showsUserLocation = true
        
        let longPressed = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addPinBasedOnGesture(_:)))
        view.addGestureRecognizer(longPressed)
        
        // Add location button
        let trackingButton = MKUserTrackingButton(mapView: view)
        view.addSubview(trackingButton)
        
        trackingButton.layer.backgroundColor = UIColor.systemBackground.resolvedColor(with: UITraitCollection.current).cgColor
        trackingButton.layer.cornerRadius = 6
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16).isActive = true
        trackingButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16).isActive = true
        
        // Add compass
        view.showsCompass = false

        let compass = MKCompassButton(mapView: view)
        let compassYPosition = 16 + trackingButton.frame.size.height + 16
        let compassXPosition = -(16 - (abs(trackingButton.frame.size.width - compass.frame.size.width) / 2))
        view.addSubview(compass)
        
        compass.translatesAutoresizingMaskIntoConstraints = false
        compass.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: compassXPosition).isActive = true
        compass.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: compassYPosition).isActive = true
        compass.compassVisibility = .adaptive
        
        return view
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapClusterView
        
        init(_ parent: MapClusterView) {
            self.parent = parent
        }
        
        /// showing annotation on the map
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            return AnnotationView(annotation: annotation, reuseIdentifier: AnnotationView.ReuseID)
        }
        
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            parent.locationService.requestPermission()
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            if let cluster = view.annotation as? MKClusterAnnotation {
                
                // Deactivate select animation
                for layer in view.layer.sublayers ?? [] {
                    layer.removeAllAnimations()
                }
                mapView.deselectAnnotation(view.annotation, animated: false)
                
                // Zoom to cluster
                mapView.fitMapViewToAnnotations(annotations: cluster.memberAnnotations)
                
            } else if let item = view.annotation as? T {
                
                parent.selectedItem = item
            }
        }
        
        /// Limit the number of annotations shown
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            
        }
        
        @objc func addPinBasedOnGesture(_ gestureRecognizer: UIGestureRecognizer) {
            guard gestureRecognizer.state == .began else { return }
            let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            let map = gestureRecognizer.view as? MKMapView
            let newCoordinates = map?.convert(touchPoint, toCoordinateFrom: gestureRecognizer.view)
            
            guard let newCoordinates else { return }
            
            parent.onLongPress(newCoordinates)
        }
    }
}

/// here posible to customize annotation view
let clusterID = "clustering"

class AnnotationView: MKMarkerAnnotationView {
    
    static let ReuseID = "stationAnnotation"
    
    /// setting the key for clustering annotations
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = clusterID
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
    }
}

extension MKMapView {
    
    func fitMapViewToAnnotations(annotations: [MKAnnotation]) -> Void {
        
        let mapEdgePadding = UIEdgeInsets(top: 70, left: 70, bottom: 70, right: 70)
        var zoomRect = MKMapRect.null

        for annotation in annotations {
            let aPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
}
