//
//  RegisterView.swift
//  Parked
//
//  Created by Natanael Jop on 27/09/2022.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    
    var body: some View {
//        ScrollView{
            VStack(spacing: 30){
                cell(text: $email, placeholder: "Email", isPassword: false)
                cell(text: $password, placeholder: "Password", isPassword: true)
                Button {
                    userVM.logIn(email: email, password: password){
                        spotVM.fetchSpots()
                    }
                } label: {
                    ZStack{
                        Text("Start Parking!")
                            .font(.system(size: 25))
                            .foregroundColor(Color(UIColor.label))
                            .padding(15)
                            .padding(.horizontal)
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
                   
                }
//            }
        }.padding(40)
            .background(
                Color.revLabel.shadow(radius: 2, y: 3)
            )
    }
    @ViewBuilder
    func cell(text: Binding<String>, placeholder: String, isPassword: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10){
            Text(placeholder)
            VStack(alignment: .leading, spacing: 3){
                if isPassword {
                    SecureField("", text: text)
                }else{
                    TextField("", text: text)
                        .keyboardType(placeholder == "Phone Number" ? .decimalPad : .default)
                }
                Rectangle()
                    .fill(Color(UIColor.label))
                    .frame(height: 1.5)
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
