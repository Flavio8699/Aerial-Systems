//
//  SummaryView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 22/10/2021.
//

import SwiftUI
import MapKit
import DJISDK

struct SummaryView: View {
    
    let map = MKMapView()
    @StateObject var viewModel: PlanningViewModel
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var popupHandler: PopupHandler
    @EnvironmentObject var staticData: StaticData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack (alignment: .top, spacing: 20) {
            VStack (spacing: 15) {
                VStack (spacing: 30) {
                    Text("Zone to scan").font(SFPro.title_light_25)
                    Text("Please review the zone to scan before any save or mission start.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                }
                MapView(map: map, locations: $viewModel.currentMission.locations, mapType: $session.map, zoomIn: $viewModel.zoomIn, annotationSize: 10).onAppear {
                    map.fitAll(padding: 20)
                    map.isPitchEnabled = false
                    map.isZoomEnabled = false
                    map.isRotateEnabled = false
                    map.isScrollEnabled = false
                }.cornerRadius(14)
            }.padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .addBorder(.white, cornerRadius: 14)
                
            VStack (spacing: 15) {
                VStack (spacing: 30) {
                    Text("Summary").font(SFPro.title_light_25)
                    Text("Please review the planning before any save or mission start.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                }.padding()
                VStack (spacing: 10) {
                    VStack (spacing: 10) {
                        if let indices = viewModel.currentMission.indices.summary(), indices != "" {
                            HStack (spacing: 10) {
                                VStack (alignment: .leading, spacing: 3) {
                                    Text("Indices").foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text(indices).font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                }
                                Spacer()
                                Text("Monitoring").foregroundColor(Color(.systemGray))
                            }
                            Divider()
                        }
                        if let activities = viewModel.currentMission.activities.summary(), activities != "" {
                            HStack (spacing: 10) {
                                VStack (alignment: .leading, spacing: 3) {
                                    Text("Activites").foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text(activities).font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                }
                                Spacer()
                                Text("Monitoring").foregroundColor(Color(.systemGray))
                            }
                            Divider()
                        }
                        if let drone = staticData.drones.first(where: { $0.name == viewModel.currentMission.drone }) {
                            HStack (spacing: 10) {
                                VStack (alignment: .leading, spacing: 3) {
                                    Text(drone.name).foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text("Flight time: \(drone.flight_time) minutes").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    Text("Hovering Accuracy: \(drone.hovering_accuracy)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                }
                                Spacer()
                                Text("Drone").foregroundColor(Color(.systemGray))
                            }
                            Divider()
                        }
                        if let camera = staticData.cameras.first(where: { $0.name == viewModel.currentMission.camera }) {
                            HStack (spacing: 10) {
                                VStack (alignment: .leading, spacing: 3) {
                                    Text(camera.name).foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text("Lens: \(camera.lens)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    Text("FOV: \(camera.fov)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    Text("Spectral bands: \(camera.spectral_bands)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                }
                                Spacer()
                                Text("Camera").foregroundColor(Color(.systemGray))
                            }
                        }
                    }
                    Divider()
                    HStack (spacing: 15) {
                        CustomButton(label: "Save", color: colorScheme == .dark ? .white : .black, entireWidth: true, action: {
                            popupHandler.currentPopup = .saveMission(missionName: $viewModel.currentMission.name, action: {
                                viewModel.currentMission.timestamp = .now
                                viewModel.currentMission.updateOrAdd { result in
                                    switch result {
                                    case .success():
                                        popupHandler.currentPopup = .success(message: "The mission has been saved", button: "Close", action: popupHandler.close)
                                    case .failure(let error):
                                        popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                    }
                                }
                            })
                        })
                        CustomButton(label: viewModel.currentMission.started ? "Resume" : "Launch", entireWidth: true, action: {
                            if viewModel.currentMission.locations.count > 2 {
                                if let _ = DJISDKManager.product() {
                                    session.performingMission = viewModel.currentMission
                                    popupHandler.currentPopup = .messageAutoClose(message: "Preparing mission...", closeAfter: 1.5)
                                } else {
                                    popupHandler.currentPopup = .error(message: "No product connected! Please connect your drone.", button: "Close", action: popupHandler.close)
                                }
                            } else {
                                popupHandler.currentPopup = .error(message: "You need at least 3 locations on the map!", button: "Close", action: popupHandler.close)
                            }
                        })
                    }.padding(.vertical)
                }.padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .addBorder(.white, cornerRadius: 14)
        }.padding(20)
    }
}
