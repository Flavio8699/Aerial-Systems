//
//  ContentView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 21/09/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import MapKit
import DJISDK

struct ContentView: View {
    
    @StateObject var droneManager = DJIDroneManager.shared
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var popupHandler: PopupHandler
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    if !session.loggedIn {
                        LoginView()
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                    } else {
                        VStack (alignment: .leading, spacing: 0) {
                            if !session.fullScreen {
                                Divider()
                            }
                            HStack (spacing: 0) {
                                if !session.fullScreen {
                                    VStack (spacing: 50) {
                                        Button(action: {
                                            session.currentTab = .planning
                                        }, label: {
                                            Image(systemName: "doc.plaintext").font(.system(size: 30)).foregroundColor(session.currentTab == .planning ? Color(.systemBlue) : Color(.systemGray))
                                        }).disabled(session.performingMission != nil)
                                        Button(action: {
                                            session.currentTab = .live
                                        }, label: {
                                            Image(systemName: "rectangle.grid.3x2").font(.system(size: 30)).foregroundColor(session.currentTab == .live ? Color(.systemBlue) : Color(.systemGray))
                                        })
                                        Button(action: {
                                            session.currentTab = .history
                                        }, label: {
                                            Image(systemName: "circle.hexagonpath").font(.system(size: 30)).foregroundColor(session.currentTab == .history ? Color(.systemBlue) : Color(.systemGray))
                                        }).disabled(session.performingMission != nil)
                                        Spacer()
                                        Button(action: {
                                            popupHandler.currentPopup = .logout(action: {
                                                try! Auth.auth().signOut()
                                                UserDefaults.standard.set(false, forKey: "loggedIn")
                                                NotificationCenter.default.post(name: NSNotification.Name("loggedIn"), object: nil)
                                                popupHandler.close()
                                            })
                                        }, label: {
                                            Image(systemName: "power").font(.system(size: 30)).foregroundColor(Color(.systemGray))
                                        })
                                        Button(action: {
                                            session.showSettings = true
                                        }, label: {
                                            Image(systemName: "gearshape").font(.system(size: 30)).foregroundColor(session.showSettings ? Color(.systemBlue) : Color(.systemGray))
                                        })
                                    }.frame(maxWidth: 80).padding(.vertical, 30)
                                    Divider().edgesIgnoringSafeArea(.bottom)
                                }
                                ZStack {
                                    Color(.systemGray6)
                                    switch session.currentTab {
                                    case .planning:
                                        PlanningView()
                                    case .live:
                                        DroneLiveView()
                                    case .history:
                                        MissionHistory()
                                    }
                                }.ignoresSafeArea(.all)
                            }
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(session.fullScreen)
                        }.frame(maxHeight: .infinity)
                    }
                }
                .navigationViewStyle(.stack)
                
                // Popups
                if popupHandler.isPopupOpen() {
                    VisualEffectBlur(blurStyle: .dark).ignoresSafeArea()
                    if let missionImage = popupHandler.missionImagePopup {
                        MissionImageView(missionImage: missionImage)
                    } else {
                        VStack (spacing: 20) {
                            switch popupHandler.currentPopup {
                            case .success(let message, let button, let action):
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color(.systemGreen)).font(.system(size: 65))
                                Text(message).multilineTextAlignment(.center)
                                CustomButton(label: button, entireWidth: true, action: action).padding(.top, 15)
                                
                            case .error(let message, let button, let action):
                                Image(systemName: "xmark.circle.fill").foregroundColor(Color(.systemRed)).font(.system(size: 65))
                                Text(message).multilineTextAlignment(.center)
                                CustomButton(label: button, entireWidth: true, action: action).padding(.top, 15)
                                
                            case .saveMission(let missionName, let action):
                                Image(systemName: "pencil.circle.fill").foregroundColor(Color(.systemGray)).font(.system(size: 65))
                                Text("Mission name:").multilineTextAlignment(.center)
                                InputField("", text: missionName)
                                HStack (spacing: 20) {
                                    CustomButton(label: "Close", entireWidth: true, action: popupHandler.close)
                                    CustomButton(label: "Save", color: colorScheme == .dark ? .white : .black, entireWidth: true, action: action)
                                }.padding(.top, 15)
                                
                            case .deleteMission(let action):
                                Image(systemName: "trash.circle.fill").foregroundColor(Color(.systemGray)).font(.system(size: 65))
                                Text("Are you sure you want to delete the mission?").multilineTextAlignment(.center)
                                HStack (spacing: 20) {
                                    CustomButton(label: "Cancel", entireWidth: true, action: popupHandler.close)
                                    CustomButton(label: "Delete", color: Color(.systemRed), entireWidth: true, action: action)
                                }.padding(.top, 15)
                                
                            case .logout(let action):
                                Image(systemName: "power").foregroundColor(Color(.systemGray)).font(.system(size: 65))
                                Text("Are you sure you want to logout? All unsaved progress will be lost.").multilineTextAlignment(.center)
                                HStack (spacing: 20) {
                                    CustomButton(label: "Cancel", entireWidth: true, action: popupHandler.close)
                                    CustomButton(label: "Logout", color: Color(.systemRed), entireWidth: true, action: action)
                                }.padding(.top, 15)
                                
                            case .messageAutoClose(let message, let closeAfter):
                                LoadingPopup(message: message, duration: closeAfter).onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + closeAfter) {
                                        popupHandler.close()
                                    }
                                }
                            
                            case .lowBattery(let action1, let action2):
                                Image(systemName: "exclamationmark.triangle").foregroundColor(Color(.systemGray)).font(.system(size: 65))
                                Text("The mission was paused because the battery percentage of your drone is critical. Please stop the mission to change batteries and continue afterwards.").multilineTextAlignment(.center)
                                HStack (spacing: 20) {
                                    CustomButton(label: "Resume", color: Color(.systemRed), entireWidth: true, action: action1)
                                    CustomButton(label: "Stop mission", entireWidth: true, action: action2)
                                }.padding(.top, 15)
                                
                            default:
                                Text("error")
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 35)
                        .background(Color(UIColor.systemBackground))
                        .addBorder(.white, cornerRadius: 14)
                        .frame(maxWidth: geometry.size.width*4/9)
                        .transition(.slide)
                    }
                }
            }.font(SFPro.body)
        }
        .sheet(isPresented: $session.showSettings) {
            if let user = session.user {
                NavigationView {
                    VStack {
                        Form {
                            Section(header: Text("GENERAL")) {
                                HStack {
                                    Text("Full name")
                                    Spacer()
                                    Text(user.fullname)
                                }
                                Picker(selection: $session.map, label: Text("Map")) {
                                    Text("Standard").tag(MKMapType.standard)
                                    Text("Satellite").tag(MKMapType.satellite)
                                }
                            }
                            Section(header: Text("ABOUT")) {
                                HStack {
                                    Text("Version")
                                    Spacer()
                                    Text("1.0")
                                }
                                HStack {
                                    Text("DJI Mobile SDK")
                                    Spacer()
                                    Text(DJISDKManager.sdkVersion())
                                }
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Settings")
                    .toolbar {
                        Button(action: {
                            session.showSettings = false
                        }, label: {
                            Text("Close")
                        })
                    }
                }
            }
        }
        .onAppear {
            session.listen()
            NotificationCenter.default.addObserver(forName: NSNotification.Name("loggedIn"), object: nil, queue: .main) { _ in
                self.session.loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
            }
            droneManager.registerWithSDK()
        }
    }
}

enum Tab {
    case planning
    case live
    case history
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionStore()).environmentObject(PopupHandler()).previewInterfaceOrientation(.landscapeLeft)
    }
}

struct SFPro {
    static let title_regular = Font.custom("SFProDisplay-Regular", size: 20)
    static let title_light = Font.custom("SFProDisplay-Light", size: 20)
    static let title_light_25 = Font.custom("SFProDisplay-Light", size: 25)
    static let body = Font.custom("SFProDisplay-Regular", size: 18)
    static let frontpage_title_regular = Font.custom("SFProDisplay-Regular", size: 34)
    static let subtitle = Font.custom("SFProDisplay-Regular", size: 16)
}
