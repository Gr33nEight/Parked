//
//  LoginView.swift
//  Parked
//
//  Created by Natanael Jop on 27/09/2022.
//

import SwiftUI

struct RegisterView: View {
    @State var fullname = ""
    @State var email = ""
    @State var password = ""
    @State var phoneNumber = ""
    
    @Binding var opt: AuthOptions
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    
    var body: some View {
        VStack{
//            ScrollView{
                VStack(spacing: 30){
                    cell(text: $fullname, placeholder: "Full Name", isPassword: false, keyboardType: .namePhonePad)
                    cell(text: $email, placeholder: "Email", isPassword: false, keyboardType: .emailAddress)
                    cell(text: $password, placeholder: "Password", isPassword: true, keyboardType: .default)
                    cell(text: $phoneNumber, placeholder: "Phone Number", isPassword: false, keyboardType: .phonePad)
                   
                }
//            }
            Button {
                opt = .carSetup(fullname: $fullname, email: $email, password: $password, phoneNumber: $phoneNumber)
            } label: {
                ZStack{
                    Text("Register")
                        .font(.system(size: 25))
                        .foregroundColor(Color(UIColor.label))
                        .padding(10)
                        .padding(.horizontal, 25)
                }.background(
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.revLabel)
                            .shadow(radius: 3, y: 3)
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 1)
                            .fill(Color(UIColor.label))
                    }
                )
               
            }.padding(.top)
        }
        .padding(40)
            .background(
                Color.revLabel.shadow(radius: 2, y: 3)
            )
    }
    @ViewBuilder
    func cell(text: Binding<String>, placeholder: String, isPassword: Bool, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 10){
            Text(placeholder)
            VStack(alignment: .leading, spacing: 3){
                if isPassword {
                    SecureField("", text: text)
                }else{
                    TextField("", text: text)
                        .keyboardType(keyboardType)
                }
                Rectangle()
                    .fill(Color(UIColor.label))
                    .frame(height: 1.5)
            }
        }
    }
}

