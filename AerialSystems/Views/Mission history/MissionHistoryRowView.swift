//
//  MissionHistoryRowView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 19/11/2021.
//

import SwiftUI
import MapKit
import FirebaseStorage
import SDWebImageSwiftUI

struct MissionHistoryRowView: View {
    
    let mission: Mission
    @State var images = [MissionImage]()
    @State var missionLocation: String = "N/D"
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
                        let mission = Mission(name: "Copy of \(mission.name)", locations: mission.locations, activities: mission.activities, indices: mission.indices, drone: mission.drone, camera: mission.camera, timestamp: .now, completed: false)
                        mission.updateOrAdd { result in
                            switch result {
                            case .success():
                                popupHandler.currentPopup = .success(message: "A new mission has been created from this mission!", button: "Close", action: popupHandler.close)
                            case .failure(let error):
                                popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                            }
                        }
                    }) {
                        Label("Create new mission from this mission", systemImage: "plus")
                    }
                    Button(role: .destructive, action: {
                        popupHandler.currentPopup = .deleteMission(action: {
                            mission.delete { result in
                                switch result {
                                case .success():
                                    popupHandler.currentPopup = .success(message: "The mission was deleted successfully!", button: "Ok", action: popupHandler.close)
                                case .failure(let error):
                                    popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                }
                            }
                        })
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }.padding(.horizontal, 40)
            Text("Orthomosaic images").padding(.horizontal, 40)
            ScrollView (.horizontal, showsIndicators: false) {
                LazyHStack (spacing: 30) {
                    ForEach(images, id: \.self) { image in
                        Button(action: {
                            popupHandler.missionImagePopup = image
                        }, label: {
                            WebImage(url: image.url).resizable()
                            .placeholder {
                                Color.black.opacity(0.3)
                            }
                            .indicator(.activity)
                            .overlay {
                                if image == images.first {
                                    ZStack {
                                        Image(systemName: "magnifyingglass").foregroundColor(colorScheme == .dark ? Color(.systemGray) : .white).font(.system(size: 40))
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.3))
                                }
                            }
                        }).frame(width: 150, height: 150).cornerRadius(6)
                    }
                }.padding(.horizontal, 40)
            }
            Text("Activities images").padding(.horizontal, 40)
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 30) {
                    /*ForEach(images, id: \.self) { image in
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
                    }*/
                }.padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .addBorder(.white, cornerRadius: 14)
        .onAppear {
            self.downloadImages()
            
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
            }
        }.onDisappear {
            images = []
        }
    }
    
    func downloadImages() {
        if let id = self.mission.id {
            let storage = Storage.storage()
            let storageReference = storage.reference().child(id)
            storageReference.listAll { (result, error) in
                var counter: Int = 1
                for image in result.items {
                    image.downloadURL { url, error in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            if let url = url {
                                images.append(MissionImage(name: "Image \(counter)", availableIndices: staticData.indices.filter { index in
                                    return mission.indices.contains(index.title)
                                }, url: url))
                                counter += 1
                            }
                        }
                    }
                }
            }
        }
    }
}
