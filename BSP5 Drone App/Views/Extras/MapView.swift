//
//  MapView.swift
//  BSP5 Drone App
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
    
    func makeCoordinator() -> MapView.Coordinator {
        return MapView.Coordinator(parent: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        map.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.50458781521201, longitude: 5.94840754072138), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.mapType = self.mapType
        map.delegate = context.coordinator
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addAnnotation(_:)))
        map.addGestureRecognizer(longPressGesture)
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
        
        uiView.mapType = self.mapType
        updateMap(locations: self.locations, mapView: uiView)
        if self.zoomIn {
            uiView.fitAll()
            DispatchQueue.main.async {
                self.zoomIn = false
            }
        }
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
            let identifier = "customPin"

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
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, size: CGFloat) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.set(image: UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: size))!, with: .systemBlue)
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
