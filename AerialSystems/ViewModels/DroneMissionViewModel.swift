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
    @Published var alerts = [AlertMessage]()
    @Published var state: MissionState = .not_started
    @Published var lowBatteryPopup: Bool = false
    
    private var homeAnnotation = CustomAnnotation(identifier: "home")
    private var aircraftAnnotation = CustomAnnotation(identifier: "aircraft")
    @Published var aircraftAnnotationView: MKAnnotationView?
    var droneManager = DJIDroneManager.shared
    
    func configureMission() {
        if let currentMission = currentMission {
            let (top, right, bottom, left) = getCornerLocations(locations: currentMission.locations)
            
            let topLeft = CLLocationCoordinate2D(latitude: top, longitude: left)
            let bottomRight = CLLocationCoordinate2D(latitude: bottom, longitude: right)
            
            
            let coordinates = self.getListOfPhotoCoordinates(topLeft: topLeft, bottomRight: bottomRight)
            
            for coordinate in coordinates {
                let location = CustomAnnotation(identifier: "photo")
                location.coordinate = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.map.addAnnotation(location)
            }
            
            self.map.addOverlay(MKPolyline(coordinates: coordinates, count: coordinates.count))

            if let mission = self.createMission(altitude: 40, coordinates: coordinates, startAt: currentMission.nextWaypoint) {
                self.droneInformation.photosToTake = Int(mission.waypointCount)
                var elements = [DJIMissionControlTimelineElement]()
                
                elements.append(mission)
                elements.append(DJIGoHomeAction())
                
                let error = DJISDKManager.missionControl()?.scheduleElements(elements)
                if let error = error {
                    self.alerts.append(.init(message: "Error \(error.localizedDescription)"))
                }
                
                self.droneInformation.photosToTake += currentMission.nextWaypoint
                self.droneInformation.photosTaken += currentMission.nextWaypoint
                self.droneInformation.nextWaypointIndex += currentMission.nextWaypoint
            }
        }
    }
    
    func createMission(altitude: Float, coordinates: [CLLocationCoordinate2D], startAt: Int) -> DJIWaypointMission? {
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .safely
        mission.repeatTimes = 1
        
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
        self.homeAnnotation.coordinate = droneCoordinates
        
        self.map.addAnnotations([self.aircraftAnnotation, self.homeAnnotation])

        for coordinate in coordinates.suffix(coordinates.count-startAt) {
            let waypoint = DJIWaypoint(coordinate: coordinate)
            waypoint.altitude = altitude
            waypoint.heading = 0
            waypoint.actionRepeatTimes = 1
            waypoint.actionTimeoutInSeconds = 60
            waypoint.turnMode = .clockwise
            waypoint.gimbalPitch = -90
            waypoint.add(DJIWaypointAction(actionType: .shootPhoto, param: 0))
            
            mission.add(waypoint)
        }
        
        if let error = mission.checkParameters() {
            self.alerts.append(.init(message: "Error: \(error.localizedDescription)"))
            return error as? DJIWaypointMission
        }
        
        return DJIWaypointMission(mission: mission)
    }
    
    private func getListOfPhotoCoordinates(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, overlap: CGFloat = 0.4) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        let (x, y) = getSizeFromFOV(HFOV: 57.12, VFOV: 42.44, altitude: 120)
        
        let start = CLLocationCoordinate2DMake(addVerticalMeters(-y/2, at: topLeft.latitude), addHorizontalMeters(x/2, at: topLeft.longitude))
        coordinates.append(start)
        
        while coordinates.last!.longitude < addHorizontalMeters(-x/2, at: bottomRight.longitude) {
            while coordinates.last!.latitude > addVerticalMeters(y/2, at: bottomRight.latitude) {
                let lastCoordinate = coordinates.last!
                let newLocation = CLLocationCoordinate2DMake(addVerticalMeters(-(1-overlap) * y, at: lastCoordinate.latitude), lastCoordinate.longitude)
                coordinates.append(newLocation)
            }
            
            let lastCoordinate = coordinates.last!
            let bottomConnector = CLLocationCoordinate2DMake(lastCoordinate.latitude, addHorizontalMeters((1-overlap) * x, at: lastCoordinate.longitude))
            coordinates.append(bottomConnector)
            
            while coordinates.last!.latitude < addVerticalMeters(-y/2, at: topLeft.latitude) {
                let lastCoordinate = coordinates.last!
                let newLocation = CLLocationCoordinate2DMake(addVerticalMeters((1-overlap) * y, at: lastCoordinate.latitude), lastCoordinate.longitude)
                coordinates.append(newLocation)
            }
            
            let lastCoordinate2 = coordinates.last!
            let topConnector = CLLocationCoordinate2DMake(lastCoordinate2.latitude, addHorizontalMeters((1-overlap) * x, at: lastCoordinate2.longitude))
            coordinates.append(topConnector)
        }
        
        coordinates.removeLast()
        
        return coordinates
    }
    
    private func getSizeFromFOV(HFOV: CGFloat, VFOV: CGFloat, altitude: CGFloat) -> (CGFloat, CGFloat) {
        let x = tan(HFOV / 2 * CGFloat.pi / 180) * altitude
        let y = tan(VFOV / 2 * CGFloat.pi / 180) * altitude
        return (x, y)
    }
    
    private func addVerticalMeters(_ meters: CGFloat, at latitude: CLLocationDegrees) -> CLLocationDegrees {
        return latitude + (meters / 6378000) * (180 / CGFloat.pi);
    }
    
    private func addHorizontalMeters(_ meters: CGFloat, at longitude: CLLocationDegrees) -> CLLocationDegrees {
        return longitude + (meters / 6378000) * (180 / CGFloat.pi) / cos(longitude * CGFloat.pi / 180);
    }
    
    func startListeners() {
        if let currentMission = currentMission {
            // Mission execution state
            DJISDKManager.missionControl()?.waypointMissionOperator().addListener(toExecutionEvent: self, with: DispatchQueue.main) { event in
                if let progress = event.progress {
                    if progress.execState == .finishedAction && progress.isWaypointReached && progress.targetWaypointIndex + currentMission.nextWaypoint == self.droneInformation.nextWaypointIndex {
                        self.droneInformation.nextWaypointIndex += 1
                        self.droneInformation.photosTaken += 1
                    }
                }
            }
            
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
            
            // RTH Execution
            if let RTHkey = DJIFlightControllerKey(param: DJIFlightControllerParamGoHomeExecutionState) {
                DJISDKManager.keyManager()?.startListeningForChanges(on: RTHkey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                    if (newValue != nil) {
                        NotificationCenter.default.post(name: NSNotification.Name("dji.go.home.state"), object: nil, userInfo: ["state": newValue!.value])
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
                        let battery = newValue!.unsignedIntegerValue
                        self.droneInformation.batteryPercentageRemaining = battery
                        
                        if battery <= 30 && !lowBatteryPopup {
                            NotificationCenter.default.post(name: NSNotification.Name("dji.low.battery"), object: nil)
                            lowBatteryPopup = true
                        }
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
            
            // Drone velocity
            if let velocityKey = DJIFlightControllerKey(param: DJIFlightControllerParamVelocity) {
                DJISDKManager.keyManager()?.startListeningForChanges(on: velocityKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                    if let newValue = newValue, let value = newValue.value as? DJISDKVector3D {
                        self.droneInformation.speedVertical = abs(value.z)
                        self.droneInformation.speedHorizontal = max(abs(value.x), abs(value.y))
                    }
                }
            }
        }
    }
    
    func setupVideo() {
        droneManager.setupVideo()
    }
    
    func startMission() {
        DJISDKManager.missionControl()?.startTimeline()
        self.state = .started
    }
    
    func pauseMission() {
        DJISDKManager.missionControl()?.pauseTimeline()
        self.state = .paused
    }
    
    func resumeMission() {
        DJISDKManager.missionControl()?.resumeTimeline()
        self.state = .started
    }
    
    func stopMission() {
        DJISDKManager.missionControl()?.stopTimeline()
        DJISDKManager.missionControl()?.unscheduleEverything()
        if var mission = currentMission {
            mission.started = true
            mission.nextWaypoint = self.droneInformation.nextWaypointIndex
            mission.updateOrAdd { result in
                switch result {
                case .success():
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let error = DJISDKManager.missionControl()?.scheduleElement(DJIGoHomeAction())
                        if let error = error {
                            self.alerts.append(.init(message: "Error: \(error.localizedDescription)"))
                        }
                        DJISDKManager.missionControl()?.startTimeline()
                    }
                case .failure(let error):
                    self.alerts.append(.init(message: "Error \(error.localizedDescription)"))
                }
            }
        }
    }
    
    func stopListeners() {
        DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
    }
    
    // MARK: Retrieve images from SD card, download data and upload images to Firebase
    func getImages(amount: Int) {
        self.alerts.append(.init(message: "Retrieving images from drone..."))
        guard  let camera: DJICamera = droneManager.fetchCamera() else { return }
        let manager = camera.mediaManager!
            
        camera.setMode(.mediaDownload, withCompletion: { error in
            if let error = error {
                self.alerts.append(.init(message: "Error settings camera mode: \(error.localizedDescription)"))
            } else {
                manager.refreshFileList(of: DJICameraStorageLocation.sdCard, withCompletion:  { (error) in
                    if let error = error {
                        self.alerts.append(.init(message: "Error refreshing file list: \(error.localizedDescription)"))
                    } else {
                        guard let files = manager.sdCardFileListSnapshot() else { return }
                        
                        let images = files.filter { $0.mediaType == .JPEG || $0.mediaType == .TIFF }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.downloadImagesFromSDCard(images, amount: amount) { images in
                                self.alerts.append(.init(message: "Uploading images..."))
                                self.uploadImagesToFirebase(images)
                                camera.setMode(.shootPhoto)
                            }
                        }
                    }
                })
            }
        })
    }
    
    private func uploadImagesToFirebase(_ images: [DroneImage]) {
        if let currentMission = currentMission, let documentID = currentMission.id {
            DispatchQueue.main.async {
                var successfulImages = 0
                var counter: Int = 0
                
                for image in images {
                    if let data = image.data {
                        let filePath = "\(documentID)/\(image.name)"
                        
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpg"
                        
                        Storage.storage().reference().child(filePath).putData(data as Data, metadata: metaData) { metaData, error in
                            if let error = error {
                                self.alerts.append(.init(message: "Error uploading image: \(error.localizedDescription)"))
                            } else {
                                successfulImages += 1
                            }
                            
                            counter += 1
                            if images.count == counter {
                                self.alerts.append(.init(message: "\(successfulImages) images uploaded successfully"))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func downloadImagesFromSDCard(_ files: [DJIMediaFile], amount: Int, completion: @escaping ([DroneImage]) -> Void) {
        var counter: Int = 0
        var images = [DroneImage]()
        let files = Array(files.suffix(amount))
        
        func downloadImageData(_ file: DJIMediaFile) {
            file.fetchPreview { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    if let preview = file.preview, let data = preview.jpegData(compressionQuality: 1) {
                        let file = DroneImage(name: file.fileName, data: data)
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
            
            // Full image
            /*var imageData: Data?
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
            })*/
        }
        
        // Start downloading images
        downloadImageData(files[counter])
    }
}

struct DroneInformation {
    var altitudeInMeters: UInt = 0
    var batteryPercentageRemaining: UInt = 0
    var photosTaken: Int = 0
    var photosToTake: Int = 0
    var speedVertical: Double = 0
    var speedHorizontal: Double = 0
    var nextWaypointIndex: Int = 0
    var goHomeState: UInt?
}

struct AlertMessage {
    var id = UUID()
    var message: String
}
