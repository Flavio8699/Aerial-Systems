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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 50) {
                Text("Image 25").foregroundColor(.white).font(SFPro.title_light_25).bold()
                HStack (alignment: .center, spacing: 50) {
                    Spacer()
                    Image(missionImage.image).resizable().frame(width: geometry.size.width/3, height: geometry.size.height/2).cornerRadius(14)
                    VStack (spacing: 0) {
                        VStack (spacing: 15) {
                            Text("Indices").font(SFPro.title_light_25)
                            Text("Please select an indice to analyse the image.").multilineTextAlignment(.center).foregroundColor(Color(.systemGray)).fixedSize(horizontal: false, vertical: true)
                        }.padding()
                        ForEach(missionImage.availableIndices, id: \.self) { index in
                            HStack (spacing: 15) {
                                Button(action: {
                                    if selectedIndices.contains(index) {
                                        selectedIndices.removeAll { $0 == index }
                                    } else {
                                        selectedIndices.append(index)
                                    }
                                }, label: {
                                    Image(systemName: selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle").font(SFPro.title_regular).foregroundColor(selectedIndices.contains(index) ? Color(.systemBlue) : Color(.systemGray3))
                                    VStack (alignment: .leading, spacing: 3) {
                                        Text(index.title).foregroundColor(colorScheme == .dark ? .white : .black).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                                        Text(index.subtitle).font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    }
                                    Spacer()
                                })
                                Image(systemName: "info.circle").font(SFPro.title_regular).foregroundColor(Color(.systemBlue)).onTapGesture {
                                    indexInfo = index
                                }
                            }
                            if index != missionImage.availableIndices.last {
                                Divider()
                            }
                        }.scrollOnOverflow()
                        Spacer(minLength: 0)
                        Divider()
                        CustomButton(label: "Save image", action: {
                            
                        }).padding()
                    }
                    .frame(width: geometry.size.width/3, height: geometry.size.height/2)
                    .background(Color(UIColor.systemBackground))
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
            }
            .padding(.vertical).frame(height: geometry.size.height*4/5)
            .alignmentGuide(VerticalAlignment.center, computeValue: { $0[.bottom] })
            .position(x: geometry.size.width/2, y: geometry.size.height/2)
        }
        .sheet(item: $indexInfo) { index in
            IndexInfoSheetView(index: index)
        }
    }
}
