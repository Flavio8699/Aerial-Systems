//
//  DronesCamerasView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 18/10/2021.
//

import SwiftUI

struct DronesCamerasView: View {
    
    @StateObject var viewModel: PlanningViewModel
    @StateObject var bluetoothConnector: BluetoothConnectorViewController = BluetoothConnectorViewController()
    @State var openSheet = false
    
    var body: some View {
        VStack (spacing: 0) {
            PlanningHeaderView(viewModel: viewModel)
            HStack (alignment: .top, spacing: 15) {
                VStack (spacing: 0) {
                    VStack (spacing: 30) {
                        Text("Drones").font(SFPro.title_regular)
                        Text("Please choose the drones that you would like to use during the mission.").font(SFPro.body_regular).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                    }.padding()
                    VStack (spacing: 10) {
                        Text("no drones")
                        Divider()
                        Button(action: {
                            openSheet = true
                        }, label: {
                            HStack {
                                Text("Add a new drone")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(Color(.systemGray))
                            }
                        })
                    }.padding([.horizontal, .bottom]).scrollOnOverflow()
                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .addBorder(.white, cornerRadius: 14)
                
                VStack (spacing: 0) {
                    VStack (spacing: 0) {
                        VStack (spacing: 30) {
                            Text("Cameras").font(SFPro.title_regular)
                            Text("Please choose the drone compatible cameras that you will use during the mission.").font(SFPro.body_regular).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                        }.padding()
                        VStack (spacing: 10) {
                            Text("test2")
                        }.padding([.horizontal, .bottom]).scrollOnOverflow()
                    }
                    .background(.white)
                    .addBorder(.white, cornerRadius: 14)
                    
                    Spacer(minLength: 0)
                    
                    HStack {
                        Spacer()
                        CustomButton(label: "Next step", action: {
                            withAnimation(.linear) {
                                viewModel.currentTab = .summary
                            }
                        })
                    }.padding(.top)
                }.frame(maxWidth: .infinity)
            }.padding()
        }.sheet(isPresented: $openSheet) {
            NavigationView {
                VStack {
                    Button(action: {
                        self.bluetoothConnector.searchBluetoothProducts()
                    }, label: {
                        Text("Search for products")
                    })
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Add a new drone")
                .toolbar {
                    Button("Close") {
                        openSheet = false
                    }
                }
            }
            
        }
    }
}

