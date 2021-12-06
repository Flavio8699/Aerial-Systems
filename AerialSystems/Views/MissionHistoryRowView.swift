//
//  MissionHistoryRowView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 19/11/2021.
//

import SwiftUI
import MapKit

struct MissionHistoryRowView: View {
    
    let mission: Mission
    @State var missionLocation: String = ""
    let images = ["field_sample", "field_sample_2", "field_sample", "field_sample_2", "field_sample", "field_sample_2", "field_sample", "field_sample_2"]
    @EnvironmentObject var popupHandler: PopupHandler
    @EnvironmentObject var staticData: StaticData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack (alignment: .leading, spacing: 30) {
            HStack (spacing: 30) {
                Text(mission.name).font(SFPro.title_light).foregroundColor(Color(.systemBlue))
                Spacer()
                HStack (spacing: 10) {
                    Image(systemName: "location.fill").foregroundColor(Color(.systemBlue))
                    
                    
                    Text(missionLocation).foregroundColor(Color(.systemGray))
                }
                HStack (spacing: 10) {
                    Image(systemName: "calendar").foregroundColor(Color(.systemBlue))
                    Text(mission.dateString).foregroundColor(Color(.systemGray))
                }
                Menu {
                    Button(action: {
                        
                    }) {
                        Label("Create draft from mission", systemImage: "plus")
                    }
                    Button(action: {
                        
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }.padding(.horizontal, 40)
            Text("Orthomosaic images").padding(.horizontal, 40)
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 30) {
                    ForEach(images, id: \.self) { image in
                        Button(action: {
                            popupHandler.missionImagePopup = MissionImage(image: image, availableIndices: staticData.indices.filter { index in
                                return mission.indices.contains(index.title)
                            })
                        }, label: {
                            Image(image).resizable().overlay {
                                //if image == images.first {
                                    ZStack {
                                        Image(systemName: "magnifyingglass").foregroundColor(colorScheme == .dark ? Color(.systemGray) : .white).font(.system(size: 40))
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.3))
                                //}
                            }
                        }).frame(width: 150, height: 150).cornerRadius(6)
                    }
                }.padding(.horizontal, 40)
            }
            Text("Activities images").padding(.horizontal, 40)
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 30) {
                    ForEach(images, id: \.self) { image in
                        Button(action: {
                            
                        }, label: {
                            Image(image).resizable().overlay {
                                //if image == images.first {
                                    ZStack {
                                        Image(systemName: "magnifyingglass").foregroundColor(colorScheme == .dark ? Color(.systemGray) : .white).font(.system(size: 40))
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.3))
                                //}
                            }
                        }).frame(width: 150, height: 150).cornerRadius(6)
                    }
                }.padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .addBorder(.white, cornerRadius: 14)
        .onAppear {
            if self.mission.locations.count > 0 {
                let location = CLLocation(latitude: self.mission.locations[0].coordinates.latitude, longitude: self.mission.locations[0].coordinates.longitude)

                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                        return
                    }

                    if let placemarks = placemarks, placemarks.count > 0 {
                        let pm = placemarks[0]
                        self.missionLocation = pm.locality ?? "N/D"
                    } else {
                        print("Problem with the data received from geocoder")
                    }
                })
            } else {
                self.missionLocation = "N/D"
            }
        }
    }
}
