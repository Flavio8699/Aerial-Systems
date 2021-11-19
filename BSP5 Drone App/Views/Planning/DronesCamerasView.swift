//
//  DronesCamerasView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 18/10/2021.
//

import SwiftUI

struct DronesCamerasView: View {
    
    @StateObject var viewModel: PlanningViewModel
    @State var selected = false
    @EnvironmentObject var staticData: StaticData
    
    var body: some View {
        HStack (alignment: .top, spacing: 30) {
            VStack (spacing: 0) {
                VStack (spacing: 30) {
                    Text("Drones").font(SFPro.title_light_25)
                    Text("Please choose the drones that you would like to use during the mission.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                }.padding()
                VStack (spacing: 10) {
                    ForEach(staticData.drones, id: \.self) { drone in
                        Button(action: {
                            viewModel.currentMission.drone = drone.name
                        }, label: {
                            HStack (spacing: 15) {
                                Image(drone.image).resizable().scaledToFit().frame(width: 150, height: 150)
                                VStack (alignment: .leading) {
                                    Text(drone.name).foregroundColor(.black)
                                    Text("Flight time: \(drone.flight_time) minutes").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    Text("Hovering Accuracy: \(drone.hovering_accuracy)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                }.multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 0)
                                Image(systemName: viewModel.currentMission.drone == drone.name ? "checkmark.circle.fill" : "circle").font(.system(size: 25)).foregroundColor(viewModel.currentMission.drone == drone.name ? Color(.systemBlue) : Color(.systemGray3))
                            }
                        })
                        if drone != staticData.drones.last {
                            Divider()
                        }
                    }
                }.padding([.horizontal, .bottom])
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .addBorder(.white, cornerRadius: 14)
            
            VStack (spacing: 0) {
                VStack (spacing: 0) {
                    VStack (spacing: 30) {
                        Text("Cameras").font(SFPro.title_light_25)
                        Text("Please choose the drone compatible cameras that you will use during the mission.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                    }.padding()
                    VStack (spacing: 10) {
                        ForEach(staticData.cameras, id: \.self) { camera in
                            Button(action: {
                                viewModel.currentMission.camera = camera.name
                            }, label: {
                                HStack (spacing: 15) {
                                    Image(camera.image).resizable().scaledToFit().frame(width: 150, height: 150)
                                    VStack (alignment: .leading) {
                                        Text(camera.name).foregroundColor(.black)
                                        Text("Lens: \(camera.lens)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                        Text("FOV: \(camera.fov)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                        Text("Spectral bands: \(camera.spectral_bands)").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    }.multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                    Image(systemName: viewModel.currentMission.camera == camera.name ? "checkmark.circle.fill" : "circle").font(.system(size: 25)).foregroundColor(viewModel.currentMission.camera == camera.name ? Color(.systemBlue) : Color(.systemGray3))
                                }
                            })
                            if camera != staticData.cameras.last {
                                Divider()
                            }
                        }
                    }.padding([.horizontal, .bottom])
                }
                .background(.white)
                .addBorder(.white, cornerRadius: 14)
                
                Spacer(minLength: 0)
                
                HStack {
                    Spacer()
                    CustomButton(label: "Next step", action: {
                        viewModel.currentTab = .summary
                    })
                }.padding(.top)
            }.frame(maxWidth: .infinity)
        }.padding(30)
    }
}
