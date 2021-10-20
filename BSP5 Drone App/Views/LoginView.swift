//
//  LoginView.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 19/10/2021.
//

import SwiftUI

struct LoginView: View {

    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                HStack (spacing: 0) {
                    Spacer()
                    VStack (alignment: .leading, spacing: 15) {
                        Text("Sign in to Aerial Systems").font(SFPro.frontpage_title_regular)
                        Text("Please enter your credentials to proceed.").font(SFPro.body_regular).foregroundColor(Color(.systemGray))
                        if viewModel.error != "" {
                            Text(viewModel.error).font(SFPro.body_regular).foregroundColor(Color(.systemRed))
                        }
                        VStack (spacing: 25) {
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
                                HStack {
                                    Text("PASSWORD").font(.custom("SFProDisplay-Regular", size: 14)).foregroundColor(Color(.systemGray))
                                    Spacer()
                                    NavigationLink(destination: Text("test")) {
                                        Text("Forgot password?").font(SFPro.callout_regular).foregroundColor(Color(.systemGray))
                                    }
                                }
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
                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                viewModel.login()
                            }, label: {
                                HStack {
                                    Spacer()
                                    if viewModel.loading {
                                        ProgressView()
                                    } else {
                                        Text("Sign in")
                                    }
                                    Spacer()
                                }.padding(.horizontal, 45)
                                .padding(.vertical, 18)
                                .foregroundColor(.white)
                                .background(Color(.systemBlue))
                                .font(SFPro.title)
                                .cornerRadius(14)
                            })
                            HStack {
                                Text("Don't have an account?").foregroundColor(Color(.systemGray))
                                NavigationLink(destination: Text("register")) {
                                    Text("Sign up")
                                }
                            }.font(SFPro.callout_regular)
                        }.padding(.top, 35)
                    }.padding(.bottom, 35)
                    .frame(width: geometry.size.width/3)
                    .ignoresSafeArea(.keyboard)
                    Spacer()
                    Divider()
                    Image("dji").resizable().scaledToFill().frame(width: geometry.size.width/2)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }.navigationViewStyle(.stack)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().previewInterfaceOrientation(.landscapeLeft)
    }
}
