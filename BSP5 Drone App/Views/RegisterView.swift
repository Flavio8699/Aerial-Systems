//
//  RegisterView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 28/10/2021.
//

import SwiftUI

struct RegisterView: View {

    @StateObject var viewModel = RegisterViewModel()
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var popupHandler: PopupHandler
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                HStack (spacing: 0) {
                    Spacer()
                    VStack (alignment: .leading, spacing: 15) {
                        Text("Sign up to Aerial Systems").font(SFPro.frontpage_title_regular)
                        Text("Please enter your credentials to proceed.").foregroundColor(Color(.systemGray))
                        VStack (spacing: 25) {
                            VStack (alignment: .leading, spacing: 5) {
                                Text("FULL NAME").font(.custom("SFProDisplay-Regular", size: 14)).foregroundColor(Color(.systemGray))
                                TextField("", text: $viewModel.fullName)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 13)
                                    .foregroundColor(.black.opacity(0.8))
                                    .background(Color("TextFieldBackground"))
                                    .addBorder(Color("TextFieldBorder"), width: 1.5, cornerRadius: 6)
                            }
                            
                            VStack (alignment: .leading, spacing: 5) {
                                Text("EMAIL ADDRESS").font(.custom("SFProDisplay-Regular", size: 14)).foregroundColor(Color(.systemGray))
                                TextField("", text: $viewModel.email)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 13)
                                    .foregroundColor(.black.opacity(0.8))
                                    .background(Color("TextFieldBackground"))
                                    .addBorder(Color("TextFieldBorder"), width: 1.5, cornerRadius: 6)
                            }
                            
                            VStack (alignment: .leading, spacing: 5) {
                                Text("PASSWORD").font(.custom("SFProDisplay-Regular", size: 14)).foregroundColor(Color(.systemGray))
                                HStack {
                                    if viewModel.passwordVisible {
                                        TextField("", text: $viewModel.password)
                                    } else {
                                        SecureField("", text: $viewModel.password)
                                    }
                                    Button(action: {
                                        viewModel.passwordVisible.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.passwordVisible ? "eye.slash.fill" : "eye.fill")
                                    })
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 13)
                                .foregroundColor(.black.opacity(0.8))
                                .background(Color("TextFieldBackground"))
                                .addBorder(Color("TextFieldBorder"), width: 1.5, cornerRadius: 6)
                            }
                            CustomButton(label: "Create Account", loading: viewModel.loading, entireWidth: true) {
                                viewModel.loading = true
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                session.register(email: viewModel.email, password: viewModel.password) { result in
                                    switch result {
                                    case .success():
                                        popupHandler.currentPopup = .success(message: "Your account has been created.", button: "Sign in", action: {
                                            popupHandler.close()
                                            self.presentationMode.wrappedValue.dismiss()
                                        })
                                    case .failure(let error):
                                        popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                    }
                                    viewModel.loading = false
                                }
                            }
                            HStack {
                                Text("Already have an account?").foregroundColor(Color(.systemGray))
                                Button(action: {
                                    self.presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    Text("Sign in")
                                })
                            }.font(SFPro.subtitle)
                        }.padding(.top, 35)
                    }.padding(.bottom, 35)
                    .frame(width: geometry.size.width/3)
                    .ignoresSafeArea(.keyboard)
                    Spacer()
                    Divider()
                    Image("dji").resizable().scaledToFill().frame(width: geometry.size.width/2)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView().previewInterfaceOrientation(.landscapeLeft)
    }
}