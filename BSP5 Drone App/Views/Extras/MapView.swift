//
//  MapView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    let map = MKMapView()
    let locationManager = CLLocationManager()
    var firstRun: Bool = true
    @Binding var locations: [CLLocationCoordinate2D]
    
    public init(locations: Binding<[CLLocationCoordinate2D]> = .constant([])) {
        self._locations = locations
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return MapView.Coordinator(parent: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        map.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.50458781521201, longitude: 5.94840754072138), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.mapType = .satellite
        map.delegate = context.coordinator
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        /*map.showsUserLocation = true
        let status = CLLocationManager.authorizationStatus()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            let location: CLLocationCoordinate2D = locationManager.location!.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
            let region = MKCoordinateRegion(center: location, span: span)
            map.setRegion(region, animated: true)
        }*/
        
        updateMap(locations: self.locations, mapView: uiView)
    }
    
    func updateMap(locations: [CLLocationCoordinate2D], mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        
        for (i, point) in locations.enumerated() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = point
            annotation.title = String(i)
            mapView.addAnnotation(annotation)
        }
        
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(MKPolygon(coordinates: locations, count: locations.count))
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }

            let customAnnotationView = self.customAnnotationView(in: mapView, for: annotation)
            return customAnnotationView
        }
        
        private func customAnnotationView(in mapView: MKMapView, for annotation: MKAnnotation) -> CustomAnnotationView {
            let identifier = "customPin"

            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let customAnnotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
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
                    self.parent.locations.remove(at: index!)
                    self.parent.locations.insert(.init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), at: index!)
                    mapView.removeAnnotation(annotation)
                    self.parent.updateMap(locations: self.parent.locations, mapView: mapView)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.25)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 2
            return renderer
        }
    }
}

class CustomAnnotationView: MKAnnotationView {
    private let annotationFrame = CGRect(x: 0, y: 0, width: 35, height: 35)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        self.backgroundColor = .clear
        self.set(image: UIImage(systemName: "circle.fill")!, with: .systemBlue)
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
