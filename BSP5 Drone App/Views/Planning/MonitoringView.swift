//
//  PlanningTab_MonitoringView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 07/10/2021.
//

import SwiftUI

struct MonitoringView: View {
    
    @StateObject var viewModel: PlanningViewModel
    @State var openSheet = false
    
    var body: some View {
        HStack (alignment: .top, spacing: 15) {
            VStack (spacing: 0) {
                VStack (spacing: 30) {
                    Text("Indices").font(SFPro.title_light_25)
                    Text("Please choose the indices that you would like to capture during the mission.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                }.padding().padding(.bottom, 20)
                VStack (spacing: 10) {
                    ForEach(viewModel.indices, id: \.self) { index in
                        HStack (spacing: 15) {
                            Button(action: {
                                if viewModel.currentMission.indices.contains(index.title) {
                                    viewModel.currentMission.indices.removeAll { $0 == index.title }
                                } else {
                                    viewModel.currentMission.indices.append(index.title)
                                }
                            }, label: {
                                Image(systemName: viewModel.currentMission.indices.contains(index.title) ? "checkmark.circle.fill" : "circle").font(.system(size: 25)).foregroundColor(viewModel.currentMission.indices.contains(index.title) ? Color(.systemBlue) : Color(.systemGray3))
                                VStack (alignment: .leading, spacing: 3) {
                                    Text(index.title).foregroundColor(.black)
                                    Text(index.subtitle).font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                }
                                Spacer()
                            })
                            Image(systemName: "info.circle").font(.system(size: 25)).foregroundColor(Color(.systemBlue)).onTapGesture {
                                openSheet = true
                            }
                        }
                        if index != viewModel.indices.last {
                            Divider()
                        }
                    }
                }.padding([.horizontal, .bottom]).scrollOnOverflow()
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .addBorder(.white, cornerRadius: 14)
            
            VStack (spacing: 0) {
                VStack (spacing: 0) {
                    VStack (spacing: 30) {
                        Text("Activities").font(SFPro.title_light_25)
                        Text("Please choose the activites that you would like to have activated during the mission.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                    }.padding().padding(.bottom, 20)
                    VStack (spacing: 10) {
                        ForEach(viewModel.activites, id: \.self) { activity in
                            HStack (spacing: 10) {
                                Button(action: {
                                    if viewModel.currentMission.activities.contains(activity.title) {
                                        viewModel.currentMission.activities.removeAll { $0 == activity.title }
                                    } else {
                                        viewModel.currentMission.activities.append(activity.title)
                                    }
                                }, label: {
                                    Image(systemName: viewModel.currentMission.activities.contains(activity.title) ? "checkmark.circle.fill" : "circle").font(.system(size: 25)).foregroundColor(viewModel.currentMission.activities.contains(activity.title) ? Color(.systemBlue) : Color(.systemGray3))
                                    VStack (alignment: .leading, spacing: 3) {
                                        Text(activity.title).foregroundColor(.black)
                                        Text(activity.subtitle).font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    }
                                    Spacer()
                                })
                            }
                            if activity != viewModel.activites.last {
                                Divider()
                            }
                        }
                    }.padding([.horizontal, .bottom]).scrollOnOverflow()
                }
                .background(.white)
                .addBorder(.white, cornerRadius: 14)
                
                Spacer(minLength: 0)
                
                HStack {
                    Spacer()
                    CustomButton(label: "Next step", action: {
                        viewModel.currentTab = .drones_and_cameras
                    })
                }.padding(.top)
            }.frame(maxWidth: .infinity)
        }.padding()
        .sheet(isPresented: $openSheet) {
            NavigationView {
                VStack {
                    Text("test")
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Test title")
                .toolbar {
                    Button("Close") {
                        openSheet = false
                    }
                }
            }
            
        }
    }
}

