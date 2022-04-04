//
//  DroneMissionViewModel.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 11/03/2022.
//

import Foundation
import DJISDK
import MapKit

class DroneMissionViewModel: ObservableObject {
    
    let map = MKMapView()
    @Published var droneInformation = DroneInformation()
    @Published var currentMission: Mission?
    
    private var homeAnnotation = CustomAnnotation(identifier: "home")
    private var aircraftAnnotation = CustomAnnotation(identifier: "aircraft")
    @Published var aircraftAnnotationView: MKAnnotationView?

    
    func configureMission() {
        if let currentMission = currentMission {
            let (top, right, bottom, left) = getCornerLocations(locations: currentMission.locations)
            self.map.addOverlay(MKPolyline(coordinates: [.init(latitude: top, longitude: left), .init(latitude: top, longitude: right), .init(latitude: bottom, longitude: right), .init(latitude: bottom, longitude: left)], count: 4))
            
            let topLeft = CLLocationCoordinate2D(latitude: top, longitude: left)
            let bottomRight = CLLocationCoordinate2D(latitude: bottom, longitude: right)
            
            // TEST
            self.homeAnnotation.coordinate = topLeft
            self.aircraftAnnotation.coordinate = .init(latitude: 49.60490126703951, longitude: 6.072680099918782)
            self.aircraftAnnotation.heading = 123
            self.map.addAnnotations([self.aircraftAnnotation, self.homeAnnotation])
            
            let coordinates = self.getListOfPhotoCoordinates(topLeft: topLeft, bottomRight: bottomRight)
            
            for coordinate in coordinates {
                let location = CustomAnnotation(identifier: "photo")
                location.coordinate = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.map.addAnnotation(location)
            }
            
            self.map.addOverlay(MKPolyline(coordinates: coordinates, count: coordinates.count))
            
            if let mission = self.createMission(altitude: 120) {
                print(mission)
            }
        }
    }
    
    func createMission(altitude: Float) -> DJIWaypointMission? {
        let mission = DJIMutableWaypointMission()
        mission.exitMissionOnRCSignalLost = true
        mission.flightPathMode = .normal
        
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            return nil
        }
        
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            return nil
        }
        
        let droneLocation = droneLocationValue.value as! CLLocation
        let droneCoordinates = droneLocation.coordinate
        
        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
            return nil
        }
        
        mission.pointOfInterest = droneCoordinates
        self.aircraftAnnotation.coordinate = droneCoordinates

        let loc1 = CLLocationCoordinate2DMake(0, 0)
        let waypoint1 = DJIWaypoint(coordinate: loc1)
        waypoint1.altitude = altitude
        waypoint1.heading = 0
        waypoint1.actionRepeatTimes = 1
        waypoint1.actionTimeoutInSeconds = 60
        waypoint1.turnMode = .clockwise
        waypoint1.gimbalPitch = 0
        waypoint1.add(DJIWaypointAction(actionType: .shootPhoto, param: 0))
        
        mission.add(waypoint1)
        
        return DJIWaypointMission(mission: mission)
    }
    
    func getListOfPhotoCoordinates(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, overlap: CGFloat = 0.7) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        let (x, y) = getSizeFromFOV(HFOV: 57.12, VFOV: 42.44, altitude: 120)
        
        let start = CLLocationCoordinate2D(latitude: addVerticalMeters(-y/2, at: topLeft.latitude), longitude: addHorizontalMeters(x/2, at: topLeft.longitude))
        coordinates.append(start)
        
        while coordinates.last!.longitude < addHorizontalMeters(-x/2, at: bottomRight.longitude) {
            while coordinates.last!.latitude > addVerticalMeters(y/2, at: bottomRight.latitude) {
                let lastCoordinate = coordinates.last!
                let newLocation = CLLocationCoordinate2D(latitude: addVerticalMeters(-(1-overlap) * y, at: lastCoordinate.latitude), longitude: lastCoordinate.longitude)
                coordinates.append(newLocation)
            }
            
            let lastCoordinate = coordinates.last!
            let bottomConnector = CLLocationCoordinate2D(latitude: lastCoordinate.latitude, longitude: addHorizontalMeters((1-overlap) * x, at: lastCoordinate.longitude))
            coordinates.append(bottomConnector)
            
            while coordinates.last!.latitude < addVerticalMeters(-y/2, at: topLeft.latitude) {
                let lastCoordinate = coordinates.last!
                let newLocation = CLLocationCoordinate2D(latitude: addVerticalMeters((1-overlap) * y, at: lastCoordinate.latitude), longitude: lastCoordinate.longitude)
                coordinates.append(newLocation)
            }
            
            let lastCoordinate2 = coordinates.last!
            let topConnector = CLLocationCoordinate2D(latitude: lastCoordinate2.latitude, longitude: addHorizontalMeters((1-overlap) * x, at: lastCoordinate2.longitude))
            coordinates.append(topConnector)
        }
        
        coordinates.removeLast()
        
        return coordinates
    }
    
    func getSizeFromFOV(HFOV: CGFloat, VFOV: CGFloat, altitude: CGFloat) -> (CGFloat, CGFloat) {
        let x = tan(HFOV / 2 * CGFloat.pi / 180) * altitude
        let y = tan(VFOV / 2 * CGFloat.pi / 180) * altitude
        return (x, y)
    }
    
    func addVerticalMeters(_ meters: CGFloat, at latitude: CLLocationDegrees) -> CLLocationDegrees {
        return latitude + (meters / 6378000) * (180 / CGFloat.pi);
    }
    
    func addHorizontalMeters(_ meters: CGFloat, at longitude: CLLocationDegrees) -> CLLocationDegrees {
        return longitude + (meters / 6378000) * (180 / CGFloat.pi) / cos(longitude * CGFloat.pi / 180);
    }
    
    func startListeners() {
        // Drone location
        if let aircarftLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)  {
            DJISDKManager.keyManager()?.startListeningForChanges(on: aircarftLocationKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if newValue != nil {
                    let newLocationValue = newValue!.value as! CLLocation
                    
                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
                        self.aircraftAnnotation.coordinate = newLocationValue.coordinate
                    }
                }
            }
        }
        
        // Drone rotation
        if let aircraftHeadingKey = DJIFlightControllerKey(param: DJIFlightControllerParamCompassHeading) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: aircraftHeadingKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if (newValue != nil) {
                    self.aircraftAnnotation.heading = newValue!.doubleValue
                    if let aircraftAnnotationView = self.aircraftAnnotationView {
                        aircraftAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: Double(self.aircraftAnnotation.heading))))
                    }
                }
            }
        }
        
        // Drone battery percentage
        if let batteryLevelKey = DJIBatteryKey(param: DJIBatteryParamChargeRemainingInPercent)  {
            DJISDKManager.keyManager()?.getValueFor(batteryLevelKey, withCompletion: { [unowned self] (value: DJIKeyedValue?, error: Error?) in
                if error == nil, value != nil {
                    self.droneInformation.batteryPercentageRemaining = value!.unsignedIntegerValue
                }
            })
            
            DJISDKManager.keyManager()?.startListeningForChanges(on: batteryLevelKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if newValue != nil {
                    self.droneInformation.batteryPercentageRemaining = newValue!.unsignedIntegerValue
                }
            }
        }
        
        // Drone altitude in meters
        if let altitudeKey = DJIFlightControllerKey(param: DJIFlightControllerParamAltitudeInMeters) {
            DJISDKManager.keyManager()?.getValueFor(altitudeKey, withCompletion: { [unowned self] (value: DJIKeyedValue?, error: Error?) in
                if error == nil, value != nil {
                    self.droneInformation.altitudeInMeters = value!.unsignedIntegerValue
                }
            })
            
            DJISDKManager.keyManager()?.startListeningForChanges(on: altitudeKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if newValue != nil {
                    self.droneInformation.altitudeInMeters = newValue!.unsignedIntegerValue
                }
            }
        }
    }
}

struct DroneInformation {
    var altitudeInMeters: UInt = 0
    var batteryPercentageRemaining: UInt = 100
}
