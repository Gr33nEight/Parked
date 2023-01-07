//
//  AccountSettings.swift
//  Parked
//
//  Created by Natanael Jop on 04/10/2022.
//

import SwiftUI

struct AccountSettings: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State var fullname = ""
    @State var email = ""
    @State var phoneNumber = ""
    @State var make = ""
    @State var model = ""
    @State var color = ""
    
    @State var password = ""
    @State var newPassword = ""
    @State var confPassword = ""
    
    var body: some View {
        ZStack{
            Color("CustomGreen")
            VStack{
                HStack{
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }.foregroundColor(.black)
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                }.padding(20)
                ZStack{
                    Color.revLabel.cornerRadius(20, corners: [.topLeft, .topRight])
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 15){
                            Text("Profile")
                                .font(.largeTitle)
                                .bold()
                            Rectangle()
                                .frame(height: 1)
                            Text("Personal")
                                .font(.system(size: 20, weight: .semibold))
                            VStack(spacing: 15){
                                customTextField(text: $fullname, placeholder: "Full name", isPassword: false)
                                customTextField(text: $email, placeholder: "Email", isPassword: false)
                                customTextField(text: $phoneNumber, placeholder: "Phone number", isPassword: false)
                            }
                            Text("Security")
                                .font(.system(size: 20, weight: .semibold))
                            VStack(spacing: 15){
                                customTextField(text: $password, placeholder: "Password", isPassword: true)
                                customTextField(text: $newPassword, placeholder: "New Password", isPassword: true)
                                customTextField(text: $confPassword, placeholder: "Confirm Password", isPassword: true)
                            }
                            Text("Car")
                                .font(.system(size: 20, weight: .semibold))
                            customTextField(text: $make, placeholder: "Make", isPassword: false)
                            HStack(spacing: 15){
                                customTextField(text: $model, placeholder: "Model", isPassword: false)
                                customTextField(text: $color, placeholder: "Color", isPassword: false)
                            }
                            Button {
                                if let user = userVM.currentUser {
                                    if user.fullname == fullname && user.email == email && user.phoneNumber == phoneNumber && user.car.make == make && user.car.model == model && user.car.color == color {
                                        dismiss()
                                    }else{
                                        userVM.upadateUserInfo(uid: userVM.currentUser?.uid ?? "", fullname: fullname, email: email, phoneNumber: phoneNumber, car: Car(make: make, model: model, color: color)) { error in
                                            if let error = error {
                                                print("Error: \(error.localizedDescription)")
                                            }else{
                                                dismiss()
                                                DispatchQueue.main.async {
                                                    self.userVM.fetchUser()
                                                }
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("Save")
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .padding(.horizontal, 30)
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor))
                                    Spacer()
                                }.padding(.vertical)
                            }

                        }
                        .padding(25)
                        .padding(.top)
                    }
                }.padding(.top, 30)
            }.padding(.top, 50)
        }.ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                fullname = userVM.currentUser?.fullname ?? ""
                email = userVM.currentUser?.email ?? ""
                phoneNumber = userVM.currentUser?.phoneNumber ?? ""
                make = userVM.currentUser?.car.make ?? ""
                model = userVM.currentUser?.car.model ?? ""
                color = userVM.currentUser?.car.color ?? ""
            }

    }
    @ViewBuilder
    func customTextField(text: Binding<String>, placeholder: String, isPassword: Bool) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .fill(Color(UIColor.label))
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.revLabel)
            VStack(alignment: .leading, spacing: 3){
                Text(placeholder)
                    .font(.system(size: 12))
                    .foregroundColor(Color(UIColor.systemGray2))
                if isPassword {
                    SecureField("", text: text)
                        .font(.system(size: 15))
                }else{
                    TextField("", text: text)
                        .font(.system(size: 15))
                }
            }.padding(10)
        }
    }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings()
    }
}
