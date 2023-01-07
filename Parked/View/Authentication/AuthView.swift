//
//  AuthView.swift
//  Parked
//
//  Created by Natanael Jop on 27/09/2022.
//

import SwiftUI

indirect enum AuthOptions {
    case none, login, register(opt: Binding<AuthOptions>), carSetup(fullname: Binding<String>, email: Binding<String>, password: Binding<String>, phoneNumber: Binding<String>)
    
    var view: AnyView {
        switch self {
        case .none:
            return AnyView(LoginView())
        case .login:
            return AnyView(LoginView())
        case .register(let opt):
            return AnyView(RegisterView(opt: opt))
        case .carSetup(let fullname, let email, let password, let phoneNumber):
            return AnyView(CarSetup(fullname: fullname, email: email, password: password, phoneNumber: phoneNumber))
        }
        
    }
    var description : String {
        switch self {
        case .none: return "none"
        case .login: return "login"
        case .register: return "register"
        case .carSetup: return "carSetup"
        }
      }
}

struct AuthView: View {
    @State var opt: AuthOptions = .none
    var body: some View {
        NavigationView(content: {
            ZStack{
                Color.revLabel.ignoresSafeArea()
                Image("backgroundImg").resizable().scaledToFill()
                ZStack(alignment: .topLeading) {
                    VStack{
                        HStack{
                            if opt.description != "none" {
                                Button(action: {
                                    opt = .none
                                }, label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color(UIColor.label))
                                }).padding(20)
                                    .padding(.horizontal, 10)
                                    .padding(.top, 50)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
                VStack {
                    Spacer()
                    if opt.description == "none" {Spacer()}
                    VStack{
                        if opt.description == "none" {
                            Button {
                                opt = .login
                                
                            } label: {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.revLabel)
                                        .shadow(radius: 3, y: 3)
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(lineWidth: 1)
                                        .fill(Color.revLabel)
                                    Text("Login")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color("CustomGreen"))
                                }
                               
                            }.frame(width: 300, height: 50)
                                .padding(.vertical)
                                .padding(.top, 70)
                            Button {
                                opt = .register(opt: $opt)
                            } label: {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color("CustomGreen"))
                                        .shadow(radius: 3, y: 3)
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(lineWidth: 1)
                                        .fill(Color.revLabel)
                                    Text("Register")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color.revLabel)
                                }
                               
                            }.frame(width: 300, height: 50)
                                
                        }else{
                            opt.view
                                .padding(30)
    //                            .padding(.bottom, 50)
                        }
                    }
                    Spacer()
                }
            }
        }).navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView().preferredColorScheme(.light)
    }
}
