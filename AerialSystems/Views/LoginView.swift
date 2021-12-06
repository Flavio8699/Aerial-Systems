//
//  LoginView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 19/10/2021.
//

import SwiftUI

struct LoginView: View {

    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var popupHandler: PopupHandler
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                HStack (spacing: 0) {
                    Spacer()
                    VStack (alignment: .leading, spacing: 15) {
                        Text("Sign in to Aerial Systems").font(SFPro.frontpage_title_regular)
                        Text("Please enter your credentials to proceed.").foregroundColor(Color(.systemGray))
                        VStack (spacing: 25) {
                            VStack (alignment: .leading, spacing: 5) {
                                Text("EMAIL ADDRESS").font(.custom("SFProDisplay-Regular", size: 14)).foregroundColor(Color(.systemGray))
                                InputField("", text: $viewModel.email)
                            }
                            
                            VStack (alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("PASSWORD").font(.custom("SFProDisplay-Regular", size: 14)).foregroundColor(Color(.systemGray))
                                    Spacer()
                                    Button(action: {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                        session.passwordReset(email: viewModel.email) { result in
                                            switch result {
                                            case .success():
                                                popupHandler.currentPopup = .success(message: "Please check your email inbox.", button: "Ok", action: popupHandler.close)
                                            case .failure(let error):
                                                popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                            }
                                        }
                                    }, label: {
                                        Text("Forgot password?").font(SFPro.subtitle).foregroundColor(Color(.systemGray))
                                    })
                                }
                                InputField("", text: $viewModel.password, type: viewModel.passwordVisible ? .text : .password, icon: viewModel.passwordVisible ? "eye.slash.fill" : "eye.fill", iconAction: {
                                    viewModel.passwordVisible.toggle()
                                })
                            }
                            CustomButton(label: "Sign in", loading: viewModel.loading, entireWidth: true) {
                                viewModel.loading = true
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                session.login(email: viewModel.email, password: viewModel.password) { result in
                                    switch result {
                                    case .success():
                                        UserDefaults.standard.set(true, forKey: "loggedIn")
                                        NotificationCenter.default.post(name: NSNotification.Name("loggedIn"), object: nil)
                                    case .failure(let error):
                                        popupHandler.currentPopup = .error(message: error.localizedDescription, button: "Ok", action: popupHandler.close)
                                    }
                                    viewModel.loading = false
                                }
                            }
                            HStack {
                                Text("Don't have an account?").foregroundColor(Color(.systemGray))
                                NavigationLink(destination: RegisterView()) {
                                    Text("Sign up")
                                }
                            }.font(SFPro.subtitle)
                        }.padding(.top, 35)
                    }.padding(.bottom, 35)
                    .frame(width: geometry.size.width/3)
                    .ignoresSafeArea(.keyboard)
                    Spacer()
                    Divider()
                    Image("dji").resizable().scaledToFill().frame(width: geometry.size.width/2)
                }
                .navigationBarTitle("Sign in", displayMode: .inline)
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().previewInterfaceOrientation(.landscapeLeft).environmentObject(SessionStore()).environmentObject(PopupHandler()).preferredColorScheme(.dark)
    }
}
