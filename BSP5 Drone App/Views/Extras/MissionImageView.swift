//
//  MissionImageView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 19/11/2021.
//

import SwiftUI

struct MissionImageView: View {
    
    let missionImage: MissionImage
    @State var indexInfo: Index? = nil
    @State var selectedIndices = [Index]()
    @EnvironmentObject var popupHandler: PopupHandler
    @EnvironmentObject var staticData: StaticData
    
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 100) {
                Spacer()
                Text("Image 25").foregroundColor(.white).font(SFPro.title_light_25).bold()
                HStack (spacing: 50) {
                    Spacer()
                    Image(missionImage.image).resizable().frame(width: geometry.size.width/3, height: geometry.size.width/3).cornerRadius(14)
                    VStack (spacing: 0) {
                        VStack (spacing: 30) {
                            Text("Indices").font(SFPro.title_light_25)
                            Text("Please select an indice to analyse the image.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).padding(.horizontal, 30)
                        }.padding().padding(.bottom, 20)
                        VStack (spacing: 10) {
                            ForEach(missionImage.availableIndices, id: \.self) { index in
                                HStack (spacing: 15) {
                                    Button(action: {
                                        if selectedIndices.contains(index) {
                                            selectedIndices.removeAll { $0 == index }
                                        } else {
                                            selectedIndices.append(index)
                                        }
                                    }, label: {
                                        Image(systemName: selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle").font(.system(size: 25)).foregroundColor(selectedIndices.contains(index) ? Color(.systemBlue) : Color(.systemGray3))
                                        VStack (alignment: .leading, spacing: 3) {
                                            Text(index.title).foregroundColor(.black)
                                            Text(index.subtitle).font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                        }
                                        Spacer()
                                    })
                                    Image(systemName: "info.circle").font(.system(size: 25)).foregroundColor(Color(.systemBlue)).onTapGesture {
                                        indexInfo = index
                                    }
                                }
                                if index != missionImage.availableIndices.last {
                                    Divider()
                                }
                            }
                        }.padding([.horizontal, .bottom]).scrollOnOverflow()
                        Divider()
                        Spacer(minLength: 0)
                        CustomButton(label: "Save image", action: {
                            
                        }).padding()
                    }
                    .frame(width: geometry.size.width/3, height: geometry.size.width/3)
                    .background(.white)
                    .addBorder(.white, cornerRadius: 14)
                    Spacer()
                }
                Button(action: {
                    popupHandler.close()
                }, label: {
                    Text("Close")
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 3)
                    )
                })
                Spacer()
            }
        }
        .sheet(item: $indexInfo) { index in
            IndexInfoSheetView(index: index)
        }
    }
}
