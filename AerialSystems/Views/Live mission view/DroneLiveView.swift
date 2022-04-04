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
    @StateObject var droneMissionVM = DroneMissionViewModel()
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var droneManager: DJIDroneManager
    
    var body: some View {
        ZStack (alignment: .center) {
            if session.performingMission != nil {
                if fpvFullscreen {
                    self.getFPV()
                } else {
                    self.getMap()
                }
                VStack (spacing: 0) {
                    HStack {
                        Button(action: {
                            session.fullScreen.toggle()
                        }, label: {
                            HStack {
                                if session.fullScreen {
                                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    Text("Exit Fullscreen")
                                } else {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    Text("Fullscreen")
                                }
                            }
                        })
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .background(.black.opacity(0.6))
                        .cornerRadius(5)
                        Spacer()
                    }.padding(.vertical, 40).padding(.horizontal, 20)
                    Spacer()
                    HStack {
                        Spacer()
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
                    }.padding()
                    HStack (alignment: .bottom) {
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
                                Text("16")
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .background(.black.opacity(0.6))
                        .cornerRadius(5)
                        Spacer()
                        CustomButton(label: "Stop mission", color: .red, action: {
                            session.fullScreen = false
                            session.performingMission = nil
                            droneManager.resetVideo()
                        })
                    }.padding(20)
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
            
            droneManager.setupVideo()
            droneMissionVM.startListeners()
            droneMissionVM.currentMission = currentMission
            droneMissionVM.configureMission()
        }
    }
    
    func getMap() -> some View {
        DroneMissionMapView(map: droneMissionVM.map, aircraftAnnotationView: $droneMissionVM.aircraftAnnotationView, mapType: $session.map).onAppear {
            droneMissionVM.map.fitAll()
        }
    }
    
    func getFPV() -> some View {
        return droneManager.videoFeed
    }
}

struct DroneLiveView_Previews: PreviewProvider {
    static var previews: some View {
        DroneLiveView().environmentObject(SessionStore()).environmentObject(DJIDroneManager())
    }
}
