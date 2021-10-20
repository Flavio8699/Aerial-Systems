//
//  ContentView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 21/09/2021.
//

import SwiftUI
import DJISDK
import FirebaseAuth

struct ContentView: View {
    
    @State private var currentTab: Tab = .planning
    @State private var settings: Bool = false
    @State private var loggedIn: Bool = UserDefaults.standard.bool(forKey: "loggedIn")
    let viewModel: BluetoothConnectorViewController = BluetoothConnectorViewController()

    var body: some View {
        NavigationView {
            if !loggedIn {
                LoginView()
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            } else {
                VStack (alignment: .leading, spacing: 0) {
                    Divider()
                    HStack (spacing: 0) {
                        VStack (spacing: 50) {
                            Button(action: {
                                currentTab = .planning
                            }, label: {
                                Image(systemName: "doc.plaintext").font(.system(size: 35)).foregroundColor(currentTab == .planning ? Color(.systemBlue) : Color(.systemGray))
                            })
                            Button(action: {
                                currentTab = .live
                            }, label: {
                                Image(systemName: "rectangle.grid.3x2").font(.system(size: 35)).foregroundColor(currentTab == .live ? Color(.systemBlue) : Color(.systemGray))
                            })
                            Button(action: {
                                currentTab = .postmission
                            }, label: {
                                Image(systemName: "circle.hexagonpath").font(.system(size: 35)).foregroundColor(currentTab == .postmission ? Color(.systemBlue) : Color(.systemGray))
                            })
                            Spacer()
                            Button(action: {
                                try! Auth.auth().signOut()
                                UserDefaults.standard.set(false, forKey: "loggedIn")
                                NotificationCenter.default.post(name: NSNotification.Name("loggedIn"), object: nil)
                            }, label: {
                                Image(systemName: "power").font(.system(size: 35)).foregroundColor(Color(.systemGray))
                            })
                            Button(action: {
                                settings = true
                            }, label: {
                                Image(systemName: "gearshape").font(.system(size: 35)).foregroundColor(settings ? Color(.systemBlue) : Color(.systemGray))
                            })
                        }.frame(maxWidth: 80).padding(.vertical, 30)
                        Divider()
                        ZStack {
                            Color(.systemGray6)
                            switch currentTab {
                            case .planning:
                                PlanningView().navigationTitle("Planning")
                            case .live:
                                VStack {
                                    Text("tab 2")
                                    Text("SDK Version: \(DJISDKManager.sdkVersion())")
                                    Button(action: {
                                        self.viewModel.searchBluetoothProducts()
                                    }, label: {
                                        Text("button")
                                    })
                                }
                                .navigationTitle("Tab 2")
                            case .postmission:
                                VStack {
                                    Text("tab 3")
                                }
                            }
                        }.ignoresSafeArea(.all)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }.frame(maxHeight: .infinity)
            }
        }.navigationViewStyle(.stack)
        .sheet(isPresented: $settings) {
            NavigationView {
                Text("test")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .navigationViewStyle(.stack)
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("loggedIn"), object: nil, queue: .main) { _ in
                self.loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
            }
        }
    }
}

struct Point: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

enum Tab {
    case planning
    case live
    case postmission
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}

struct SFPro {
    static let title = Font.custom("SFProDisplay-Medium", size: 22)
    static let body = Font.custom("SFProDisplay-Medium", size: 18)
    static let title_regular = Font.custom("SFProDisplay-Regular", size: 20)
    static let body_regular = Font.custom("SFProDisplay-Regular", size: 18)
    static let frontpage_title_regular = Font.custom("SFProDisplay-Regular", size: 34)
    static let callout_regular = Font.custom("SFProDisplay-Regular", size: 16)
    static let body_bold = Font.custom("SFProDisplay-Bold", size: 18)
}
