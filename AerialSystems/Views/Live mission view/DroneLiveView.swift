//
//  DroneLiveView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 18/11/2021.
//

import SwiftUI
import DJISDK

struct DroneLiveView: View {
    
    @State var fpvFullscreen: Bool = false
    @StateObject var droneMissionVM = DroneMissionViewModel()
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var popupHandler: PopupHandler

    var body: some View {
        ZStack (alignment: .center) {
            if session.performingMission != nil {
                if fpvFullscreen {
                    self.getFPV()
                } else {
                    self.getMap()
                }
                VStack (spacing: 0) {
                    HStack (alignment: .top, spacing: 20) {
                        Button(action: {
                            session.fullScreen.toggle()
                        }, label: {
                            if session.fullScreen {
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .frame(width: 20, height: 20)
                            }
                        })
                        .foregroundColor(.primary)
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(5)
                        Spacer()
                        VStack (alignment: .trailing) {
                            HStack (spacing: 20) {
                                HStack {
                                    Text("Drone Battery:").bold()
                                    Text("\(droneMissionVM.droneInformation.batteryPercentageRemaining) %")
                                }
                                HStack {
                                    Text("Speed:").bold()
                                    VStack (alignment: .trailing) {
                                        HStack {
                                            Text(String(format: "%.2f", droneMissionVM.droneInformation.speedVertical))
                                            HStack {
                                                Spacer()
                                                Image(systemName: "arrow.up.and.down")
                                                Spacer()
                                            }.frame(maxWidth: 15)
                                        }
                                        HStack {
                                                Text(String(format: "%.2f", droneMissionVM.droneInformation.speedHorizontal))
                                            HStack {
                                                Spacer()
                                                Image(systemName: "arrow.left.and.right")
                                                Spacer()
                                            }.frame(maxWidth: 15)
                                        }
                                    }
                                    Text("m/s")
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
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack (alignment: .trailing) {
                                    ForEach(droneMissionVM.alerts.reversed(), id: \.id) { alert in
                                        Text(alert.message)
                                            .padding()
                                            .background(Color(UIColor.systemBackground).opacity(0.8))
                                            .cornerRadius(5)
                                            .onAppear {
                                                withAnimation(.default) {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                                        self.droneMissionVM.alerts.removeFirst()
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }.padding()
                    Spacer()
                    HStack (alignment: .bottom) {
                        ZStack (alignment: .topLeading) {
                            if fpvFullscreen {
                                self.getMap().aspectRatio(4/3, contentMode: .fit)
                            } else {
                                self.getFPV().aspectRatio(16/9, contentMode: .fit)
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
                        .frame(maxWidth: 350, maxHeight: 250)
                        .cornerRadius(5)
                        Spacer()
                        switch self.droneMissionVM.state {
                        case .not_started:
                            CustomButton(label: droneMissionVM.currentMission?.started ?? false ? "Resume" : "Take off", action: {
                                droneMissionVM.startMission()
                            })
                            
                        case .started:
                            CustomButton(label: "Pause mission", action: {
                                droneMissionVM.pauseMission()
                            })
                            
                            CustomButton(label: "Stop mission", color: .red, action: {
                                droneMissionVM.stopMission()
                            })
                            
                        case .paused:
                            CustomButton(label: "Resume mission", action: {
                                droneMissionVM.resumeMission()
                            })
                            
                            CustomButton(label: "Stop mission", color: .red, action: {
                                droneMissionVM.stopMission()
                            })
                            
                        case .stopped:
                            CustomButton(label: "TODO", color: .green, action: {
                                self.droneMissionVM.alerts.append(.init(message: "TODO: Resume mission after being stopped from the last reached Waypoint"))
                            })
                            
                        case .finished:
                            CustomButton(label: "Download images", color: .black, action: {
                                droneMissionVM.getImages(amount: Int(droneMissionVM.droneInformation.photosToTake))
                            })
                            
                            CustomButton(label: "Finish mission", action: {
                                if var mission = droneMissionVM.currentMission {
                                    mission.completed = true
                                    mission.timestamp = .now
                                    mission.nextWaypoint = self.droneMissionVM.droneInformation.nextWaypointIndex
                                    mission.updateOrAdd { result in
                                        switch result {
                                        case .success():
                                            droneMissionVM.droneManager.resetVideo()
                                            session.fullScreen = false
                                            session.performingMission = nil
                                            session.currentTab = .history
                                        case .failure(let error):
                                            popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                        }
                                    }
                                }
                            })
                            
                        default:
                            EmptyView()
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
            droneMissionVM.map.fitAll()
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("dji.go.home.state"), object: nil, queue: .main) { data in
                guard let userInfo = data.userInfo else { return }
                
                if let state = userInfo["state"] as? Int {
                    var text: String?
                    
                    if state == 1 {
                        text = "The aircraft is turning the heading direction to the home point."
                        self.droneMissionVM.state = .rth
                    } else if state == 2 {
                        text = "The aircraft is going up to the height for go-home command."
                        self.droneMissionVM.state = .rth
                    } else if state == 3 {
                        text = "The aircraft is flying horizontally to home point."
                        self.droneMissionVM.state = .rth
                    } else if state == 4 {
                        text = "The aircraft is going down after arriving at the home point."
                        self.droneMissionVM.state = .rth
                    } else if state == 5 {
                        text = "The aircraft is braking to avoid collision."
                        self.droneMissionVM.state = .rth
                    } else if state == 6 {
                        text = "The aircraft is bypassing over the obstacle."
                        self.droneMissionVM.state = .rth
                    } else if state == 7 {
                        text = "The go-home command is completed."
                        if self.droneMissionVM.droneInformation.photosTaken == self.droneMissionVM.droneInformation.photosToTake {
                            self.droneMissionVM.state = .finished
                        } else {
                            self.droneMissionVM.state = .stopped
                        }
                    } else if state == 8 {
                        text = "The go-home status is unknown."
                        self.droneMissionVM.state = .rth
                    }
                    
                    if let text = text {
                        withAnimation(Animation.default) {
                            self.droneMissionVM.alerts.append(AlertMessage(message: text))
                        }
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("dji.low.battery"), object: nil, queue: .main) { _ in
                droneMissionVM.pauseMission()
                popupHandler.currentPopup = .lowBattery(action1: {
                    // Resume
                    droneMissionVM.resumeMission()
                    popupHandler.close()
                }, action2: {
                    // Stop mission
                    droneMissionVM.stopMission()
                    popupHandler.close()
                })
            }
        }.onDisappear {
            droneMissionVM.stopListeners()
        }
    }
        
    func getMap() -> some View {
        DroneMissionMapView(map: droneMissionVM.map, aircraftAnnotationView: $droneMissionVM.aircraftAnnotationView, mapType: $session.map)
    }
    
    func getFPV() -> some View {
        return droneMissionVM.droneManager.videoFeed
    }
}
