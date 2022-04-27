//
//  DroneLiveView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 18/11/2021.
//

import SwiftUI
import DJISDK
import DJIWidget

struct DroneLiveView: View {
    
    @State var fpvFullscreen: Bool = false
    @State var missionStarted: Bool = false
    @State var missionPaused: Bool = false
    @StateObject var droneMissionVM = DroneMissionViewModel()
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ZStack (alignment: .center) {
            if session.performingMission != nil {
                if fpvFullscreen {
                    self.getFPV()
                } else {
                    self.getMap()
                }
                VStack (spacing: 0) {
                    HStack (spacing: 20) {
                        Button(action: {
                            session.fullScreen.toggle()
                        }, label: {
                            HStack {
                                if session.fullScreen {
                                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    Text("Exit Fullscreen").bold()
                                } else {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    Text("Fullscreen").bold()
                                }
                            }
                        })
                        .foregroundColor(.primary)
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(5)
                        Spacer()
                        HStack (spacing: 20) {
                            HStack {
                                Text("Drone Battery:").bold()
                                Text("\(droneMissionVM.droneInformation.batteryPercentageRemaining) %")
                            }
                            HStack {
                                Text("Speed:").bold()
                                Text("33 km/h")
                            }
                            HStack {
                                Text("Altitude:").bold()
                                Text("\(droneMissionVM.droneInformation.altitudeInMeters) m")
                            }
                            HStack {
                                Text("Identification Photos:").bold()
                                Text("\(droneMissionVM.droneInformation.photosTaken)/\(droneMissionVM.droneInformation.photosToTake)")
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(5)
                    }.padding()
                    HStack {
                        /*ForEach(droneMissionVM.downloadedImages, id: \.self) { image in
                            if let data = image.data {
                                VStack {
                                    //Image(uiImage: UIImage(data: data)!).resizable().frame(width: 50, height: 50)
                                    Text(image.name)
                                }
                            }
                        }*/
                    }
                    Spacer()
                    HStack (alignment: .bottom, spacing: 20) {
                        ZStack (alignment: .topLeading) {
                            Color(.systemGray6)
                            if fpvFullscreen {
                                self.getMap()
                            } else {
                                self.getFPV()
                            }
                            Button(action: {
                                fpvFullscreen.toggle()
                            }, label: {
                                Image(systemName: "arrow.up.left.square")
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                                    .padding(5)
                                    .background(.black.opacity(0.6))
                                    .cornerRadius(5)
                            }).padding()
                        }
                        .frame(width: 400, height: 250)
                        .cornerRadius(5)
                        Spacer()
                        if missionStarted {
                            CustomButton(label: missionPaused ? "Resume mission" : "Pause mission", action: {
                                if missionPaused {
                                    missionPaused = false
                                    droneMissionVM.resumeMission()
                                } else {
                                    missionPaused = true
                                    droneMissionVM.pauseMission()
                                }
                            })
                            CustomButton(label: "Stop mission", color: .red, action: {
                                /*session.fullScreen = false
                                session.performingMission = nil
                                droneManager.resetVideo()*/
                                missionStarted = false
                                droneMissionVM.stopMission()
                            })
                        } else {
                            CustomButton(label: "Take off", action: {
                                missionStarted = true
                                droneMissionVM.startMission()
                            })
                        }
                    }.padding()
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(Color(.systemGray)).font(.system(size: 65))
                    Text("You did not start a mission!").font(SFPro.title_light_25)
                    Text("Please start a mission in the planning section before using the live view.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray))
                }
            }
        }
        .navigationTitle("Live mission view")
        .onAppear {
            guard let currentMission = session.performingMission else { return }
            
            droneMissionVM.currentMission = currentMission
            droneMissionVM.setupVideo()
            droneMissionVM.startListeners()
            droneMissionVM.configureMission()
        }
    }
    
    func getMap() -> some View {
        DroneMissionMapView(map: droneMissionVM.map, aircraftAnnotationView: $droneMissionVM.aircraftAnnotationView, mapType: $session.map).onAppear {
            droneMissionVM.map.fitAll()
        }
    }
    
    func getFPV() -> some View {
        return droneMissionVM.droneManager.videoFeed
    }
}

