//
//  MapView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import UIKit

struct MapView: UIViewRepresentable {
    
    var map: MKMapView
    let locationManager = CLLocationManager()
    @Binding var locations: [Location]
    @Binding var mapType: MKMapType
    @Binding var zoomIn: Bool
    var annotationSize: CGFloat
    
    public init(map: MKMapView, locations: Binding<[Location]> = .constant([]), mapType: Binding<MKMapType> = .constant(.satellite), zoomIn: Binding<Bool> = .constant(false), annotationSize: CGFloat = 20) {
        self.map = map
        self._locations = locations
        self._mapType = mapType
        self._zoomIn = zoomIn
        self.annotationSize = annotationSize
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        map.mapType = self.mapType
        map.delegate = context.coordinator
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addAnnotation(_:)))
        map.addGestureRecognizer(longPressGesture)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.504555167575, longitude: 5.94839559876671), span: span)
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                
                if let location = locationManager.location {
                    region = MKCoordinateRegion(center: location.coordinate, span: span)
                    //map.showsUserLocation = true
                }
            }
        }
        map.setRegion(region, animated: true)

        uiView.mapType = self.mapType
        updateMap(locations: self.locations, mapView: uiView)
        if self.zoomIn {
            uiView.fitAll()
            DispatchQueue.main.async {
                self.zoomIn = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func updateMap(locations: [Location], mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        
        let locationsSorted = sortAnnotations(locations: locations)
    
        for location in locationsSorted {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinates.toLocation()
            annotation.title = String(location.id)
            mapView.addAnnotation(annotation)
        }
        
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(MKPolygon(coordinates: locationsSorted.map { $0.coordinates.toLocation() }, count: locationsSorted.count))
    }
    
    public class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        
        private var parent: MapView
        public var overlays: [Overlay] = []
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }
            return self.customAnnotationView(in: mapView, for: annotation)
        }
        
        @objc func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
            if gestureRecognizer.state == .began {
                DispatchQueue.main.async {
                    let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
                    guard let coordinates = (gestureRecognizer.view as? MKMapView)?.convert(touchPoint, toCoordinateFrom: gestureRecognizer.view) else {
                        return
                    }
                    self.parent.locations.append(.init(id: self.parent.locations.count+1, coordinates: .init(latitude: coordinates.latitude, longitude: coordinates.longitude)))
                }
            }
        }
        
        private func customAnnotationView(in mapView: MKMapView, for annotation: MKAnnotation) -> CustomAnnotationView {
            let identifier = "location"

            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let customAnnotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier, size: parent.annotationSize)
                customAnnotationView.canShowCallout = false
                customAnnotationView.isDraggable = true
                return customAnnotationView
            }
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            guard let annotation = view.annotation else { return }
            let index = Int((annotation.title ?? "")!)
            
            if newState == .starting {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            
            if newState == .ending {
                DispatchQueue.main.async {
                    self.parent.locations.removeAll(where: { $0.id == index })
                    self.parent.locations.append(.init(id: index ?? self.parent.locations.count+1, coordinates: .init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)))
                    mapView.removeAnnotation(annotation)
                    //self.parent.updateMap(locations: self.parent.locations, mapView: mapView)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygonOverlay = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygonOverlay)
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 2
                return renderer
            } else if let polyLineOverlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyLineOverlay)
                renderer.strokeColor = .systemGray
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

class CustomAnnotationView: MKAnnotationView {
    init(annotation: MKAnnotation?, reuseIdentifier: String?, size: CGFloat, color: UIColor = .systemBlue) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.set(image: UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: size))!, with: color)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
}

extension MKAnnotationView {
    public func set(image: UIImage, with color : UIColor) {
        let view = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        view.tintColor = color
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        guard let graphicsContext = UIGraphicsGetCurrentContext() else { return }
        view.layer.render(in: graphicsContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = image
    }
}

extension MKMapView {
    func fitAll(padding: CGFloat = 100) {
        var zoomRect = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), animated: true)
    }
}

struct Overlay {
        
    public static func == (lhs: Overlay, rhs: Overlay) -> Bool {
        // maybe to use in the future for comparison of full array
        lhs.shape.coordinate.latitude == rhs.shape.coordinate.latitude &&
        lhs.shape.coordinate.longitude == rhs.shape.coordinate.longitude &&
        lhs.fillColor == rhs.fillColor
    }
    
    var shape: MKOverlay
    var fillColor: UIColor?
    var strokeColor: UIColor?
    var lineWidth: CGFloat

    public init(
        shape: MKOverlay,
        fillColor: UIColor? = nil,
        strokeColor: UIColor? = nil,
        lineWidth: CGFloat = 0
    ) {
        self.shape = shape
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }
}
