//
//  CarSetup.swift
//  Parked
//
//  Created by Natanael Jop on 10/10/2022.
//

import SwiftUI

struct CarSetup: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    
    @Binding var fullname: String
    @Binding var email: String
    @Binding var password: String
    @Binding var phoneNumber: String
    
    @State var color = ""
    @State var make = ""
    @State var model = ""
    @State var isChecked = false
    @State var wantsToStart = false
    
    var body: some View {
        VStack{
                VStack(spacing: 30){
                    cell(text: $color, placeholder: "Color", isPassword: false, keyboardType: .default)
                    cell(text: $make, placeholder: "Make", isPassword: false, keyboardType: .default)
                    cell(text: $model, placeholder: "Model", isPassword: false, keyboardType: .default)
                   
                }
            Button {
                isChecked.toggle()
            } label: {
                HStack(spacing: 0){
                    ZStack{
                        Rectangle().stroke(lineWidth: 2)
                            .fill(!isChecked && wantsToStart ? .red : Color(UIColor.label))
                            .frame(width: 15, height: 15)
                        Image(systemName: isChecked ? "checkmark" : "")
                            .font(.system(size: 10, weight: .bold))
                    }.padding(.horizontal, 10)
                    Text("I have read and accept the ")
                    NavigationLink {
                        TermsView()
                    } label: {
                        Text("Terms and Conditions")
                    }.foregroundColor(.blue)

                }.foregroundColor(Color(UIColor.label))
                    .font(.system(size: 7))
            }.padding(.top)

            Button {
                wantsToStart = true
                if isChecked {
                    userVM.signUp(email: email, password: password, fullname: fullname, phoneNumber: phoneNumber, car: Car(make: make, model: model, color: color)) {
                        spotVM.fetchSpots()
                    }
                }
            } label: {
                ZStack{
                    Text("Start Parking!")
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

struct CarSetup_Previews: PreviewProvider {
    static var previews: some View {
        CarSetup(fullname: .constant(""), email: .constant(""), password: .constant(""), phoneNumber: .constant("")).environmentObject(UserViewModel()).environmentObject(SpotsViewModel())
    }
}
