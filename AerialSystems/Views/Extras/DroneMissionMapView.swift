//
//  DroneMissionMapView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 11/03/2022.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import UIKit

struct DroneMissionMapView: UIViewRepresentable {
    
    var map: MKMapView
    let locationManager = CLLocationManager()
    @Binding var aircraftAnnotationView: MKAnnotationView?
    @Binding var mapType: MKMapType
    
    public init(map: MKMapView, aircraftAnnotationView: Binding<MKAnnotationView?>, mapType: Binding<MKMapType> = .constant(.satellite)) {
        self.map = map
        self._aircraftAnnotationView = aircraftAnnotationView
        self._mapType = mapType
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<DroneMissionMapView>) -> MKMapView {
        map.mapType = self.mapType
        map.delegate = context.coordinator
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<DroneMissionMapView>) {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                
                if let location = locationManager.location {
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: location.coordinate, span: span)
                    //map.showsUserLocation = true
                    map.setRegion(region, animated: true)
                }
            }
        }
        
        uiView.mapType = self.mapType
    }
    
    public class Coordinator: NSObject, MKMapViewDelegate {
        
        private var parent: DroneMissionMapView
        
        init(parent: DroneMissionMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? CustomAnnotation {
                switch annotation.identifier {
                case "aircraft":
                    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier)
                    
                    if annotationView == nil {
                        annotationView = DroneAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    }
                    
                    if annotationView != nil {
                        self.parent.aircraftAnnotationView = annotationView!
                        self.parent.aircraftAnnotationView!.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: Double(annotation.heading))))
                    }
                     
                    return annotationView
                case "photo":
                    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier)
                    
                    if annotationView == nil {
                        annotationView = PhotoAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    }
                    
                    return annotationView
                case "home":
                    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier)
                    
                    if annotationView == nil {
                        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    }
                    
                    return annotationView
                default:
                    return nil
                }
            } else {
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyLineOverlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyLineOverlay)
                renderer.strokeColor = .systemRed
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

class DroneAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.set(image: UIImage(systemName: "airplane", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))!, with: .systemRed)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
}

class PhotoAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.set(image: UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))!, with: .black)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
}
