//
//  DroneMissionViewModel.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 11/03/2022.
//

import Foundation
import DJISDK
import MapKit
import FirebaseStorage

class DroneMissionViewModel: ObservableObject {
    
    let map = MKMapView()
    @Published var droneInformation = DroneInformation()
    @Published var currentMission: Mission?
    
    private var homeAnnotation = CustomAnnotation(identifier: "home")
    private var aircraftAnnotation = CustomAnnotation(identifier: "aircraft")
    @Published var aircraftAnnotationView: MKAnnotationView?
    @Published var droneManager = DJIDroneManager.shared
    @Published var downloadedImages = [DroneImage]()
    
    func test() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://conservationnation.org/wp-content/uploads/2020/02/bengal-tiger-hero.jpg")!) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                let filePath = "6Y2yDqQBQ5XP8jxepMkc/image.jpg" // path where you wanted to store img in storage
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                let storageRef = Storage.storage().reference()
                    storageRef.child(filePath).putData(data as Data, metadata: metaData) { metaData, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }else{
                            print(metaData)
                        }
                    }
            }
        }
        task.resume()
    }
    
    func configureMission() {
        if let currentMission = currentMission {
            let (top, right, bottom, left) = getCornerLocations(locations: currentMission.locations)
            
            let topLeft = CLLocationCoordinate2D(latitude: top, longitude: left)
            let bottomRight = CLLocationCoordinate2D(latitude: bottom, longitude: right)
            
            // TEST
//            self.homeAnnotation.coordinate = topLeft
//            self.aircraftAnnotation.coordinate = .init(latitude: 49.60490126703951, longitude: 6.072680099918782)
//            self.aircraftAnnotation.heading = 123
            self.map.addAnnotations([self.aircraftAnnotation, self.homeAnnotation])
            
            let coordinates = self.getListOfPhotoCoordinates(topLeft: topLeft, bottomRight: bottomRight)
            droneInformation.photosToTake = coordinates.count
            
            for coordinate in coordinates {
                let location = CustomAnnotation(identifier: "photo")
                location.coordinate = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.map.addAnnotation(location)
            }
            
            self.map.addOverlay(MKPolyline(coordinates: coordinates, count: coordinates.count))

            if let mission = self.createMission(altitude: 120, coordinates: coordinates) {
                let takeoff_error = DJISDKManager.missionControl()?.scheduleElement(DJITakeOffAction())
                
                if takeoff_error != nil {
                    NSLog("Error scheduling element \(String(describing: takeoff_error))")
                    return;
                }
                
                let mission_error = DJISDKManager.missionControl()?.scheduleElement(mission)
                
                if mission_error != nil {
                    NSLog("Error scheduling element \(String(describing: mission_error))")
                    return;
                }
            }
        }
    }
    
    func createMission(altitude: Float, coordinates: [CLLocationCoordinate2D]) -> DJIWaypointMission? {
        let mission = DJIMutableWaypointMission()
        mission.exitMissionOnRCSignalLost = true
        mission.flightPathMode = .normal
        mission.finishedAction = .noAction
        
        
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
        

        for coordinate in coordinates {
            let waypoint = DJIWaypoint(coordinate: coordinate)
            waypoint.altitude = altitude
            waypoint.heading = 0
            waypoint.actionRepeatTimes = 1
            waypoint.actionTimeoutInSeconds = 60
            waypoint.turnMode = .clockwise
            waypoint.gimbalPitch = 0
            waypoint.add(DJIWaypointAction(actionType: .shootPhoto, param: 0))
            
            mission.add(waypoint)
        }
        
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
        // Timeline events listener (start, pause, resume and stop mission)
        /*DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            switch event {
            case .started:
                self.startMission()
            case .stopped:
                self.stopMission()
            case .paused:
                self.pauseMission()
            case .resumed:
                self.resumeMission()
            default:
                break
            }
        })*/
        
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
        
        // Home location
        if let homeLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamHomeLocation) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: homeLocationKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if (newValue != nil) {
                    let newLocationValue = newValue!.value as! CLLocation
                    
                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
                        self.homeAnnotation.coordinate = newLocationValue.coordinate
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
    
    func listFiles(amount: Int) {
        guard  let camera: DJICamera = droneManager.fetchCamera() else { return }
        let manager = camera.mediaManager!
            
        camera.setMode(.mediaDownload, withCompletion: { error in
            if error != nil {
                NSLog("ERROR: setting camera mode: \(String(describing: error?.localizedDescription))")
            } else {
                manager.refreshFileList(of: DJICameraStorageLocation.sdCard, withCompletion:  { (error) in
                    if error != nil {
                        NSLog("ERROR: refreshing file list: \(String(describing: error?.localizedDescription))")
                    } else {
                        guard let files = manager.sdCardFileListSnapshot() else { return }
                        
                        let images = files.filter { $0.mediaType == .JPEG || $0.mediaType == .TIFF }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.downloadImages(images, amount: amount) { images in
                                self.downloadedImages = images
                            }
                        }
                    }
                })
            }
        })
    }
    
    func downloadImages(_ files: [DJIMediaFile], amount: Int, completion: @escaping ([DroneImage]) -> Void) {
        var counter: Int = 0
        var images = [DroneImage]()
        let files = Array(files.suffix(amount))
        
        func downloadImageData(_ file: DJIMediaFile) {
            var imageData: Data?
            file.fetchData(withOffset: 0, update: DispatchQueue.main, update: {(_ data: Data?, _ isComplete: Bool, _ error: Error?) -> Void in
                if error != nil {
                    NSLog("ERROR: downloading media data: \(String(describing: error?.localizedDescription))")
                } else {
                    if let _ = imageData, let data = data {
                        imageData?.append(data)
                    } else {
                        imageData = data
                    }
                    
                    if isComplete {
                        if let imageData = imageData {
                            let file = DroneImage(name: file.fileName, data: imageData)
                            images.append(file)
                            
                            counter += 1
                            if files.count > counter {
                                downloadImageData(files[counter])
                            } else {
                                completion(images)
                            }
                        }
                    }
                }
            })
        }
        
        // Start downloading images
        downloadImageData(files[counter])
    }
    
    func setupVideo() {
        droneManager.setupVideo()
    }
    
    func startMission() {
        DJISDKManager.missionControl()?.startTimeline()
    }
    
    func pauseMission() {
        DJISDKManager.missionControl()?.pauseTimeline()
    }
    
    func resumeMission() {
        DJISDKManager.missionControl()?.resumeTimeline()
    }
    
    func stopMission() {
        DJISDKManager.missionControl()?.stopTimeline()
    }
}

struct DroneInformation {
    var altitudeInMeters: UInt = 0
    var batteryPercentageRemaining: UInt = 100
    var photosTaken: Int = 0
    var photosToTake: Int = 0
}
