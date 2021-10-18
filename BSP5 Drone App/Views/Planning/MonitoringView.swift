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
        VStack (spacing: 0) {
            PlanningHeaderView(viewModel: viewModel)
            HStack (alignment: .top, spacing: 15) {
                VStack (spacing: 0) {
                    VStack (spacing: 30) {
                        Text("Indices").font(SFPro.title_regular)
                        Text("Please choose the indices that you would like to capture during the mission.").font(SFPro.body_regular).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                    }.padding()
                    VStack (spacing: 10) {
                        ForEach(viewModel.indices, id: \.self) { index in
                            HStack (spacing: 10) {
                                Button(action: {
                                    if viewModel.selectedIndices.contains(index) {
                                        viewModel.selectedIndices.removeAll { $0 == index }
                                    } else {
                                        viewModel.selectedIndices.append(index)
                                    }
                                }, label: {
                                    Image(systemName: viewModel.selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle").font(SFPro.title_regular).foregroundColor(viewModel.selectedIndices.contains(index) ? Color(.systemBlue) : Color(.systemGray3))
                                    VStack (alignment: .leading, spacing: 3) {
                                        Text(index.title).font(SFPro.body_regular).foregroundColor(.black)
                                        Text(index.subtitle).font(SFPro.callout_regular).foregroundColor(Color(.systemGray))
                                    }
                                    Spacer()
                                })
                                Image(systemName: "info.circle").font(SFPro.title_regular).foregroundColor(Color(.systemBlue)).onTapGesture {
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
                            Text("Activities").font(SFPro.title_regular)
                            Text("Please choose the activites that you would like to have activated during the mission.").font(SFPro.body_regular).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                        }.padding()
                        VStack (spacing: 10) {
                            ForEach(viewModel.activites, id: \.self) { activity in
                                HStack (spacing: 10) {
                                    Button(action: {
                                        if viewModel.selectedActivites.contains(activity) {
                                            viewModel.selectedActivites.removeAll { $0 == activity }
                                        } else {
                                            viewModel.selectedActivites.append(activity)
                                        }
                                    }, label: {
                                        Image(systemName: viewModel.selectedActivites.contains(activity) ? "checkmark.circle.fill" : "circle").font(SFPro.title_regular).foregroundColor(viewModel.selectedActivites.contains(activity) ? Color(.systemBlue) : Color(.systemGray3))
                                        VStack (alignment: .leading, spacing: 3) {
                                            Text(activity.title).font(SFPro.body_regular).foregroundColor(.black)
                                            Text(activity.subtitle).font(SFPro.callout_regular).foregroundColor(Color(.systemGray))
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
                            withAnimation(.linear) {
                                viewModel.currentTab = .drones_and_cameras
                            }
                        })
                    }.padding(.top)
                }.frame(maxWidth: .infinity)
            }.padding()
        }.sheet(isPresented: $openSheet) {
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

