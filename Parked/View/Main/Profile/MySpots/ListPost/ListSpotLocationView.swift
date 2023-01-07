//
//  ListSpotLocationView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI

struct ListSpotLocationView: View {
    @Binding var street: String
    @Binding var city: String
    @Binding var state: String
    @Binding var zipcode: String
    @Binding var notes: String
    @Binding var page: Int

    @State var showInfo = false
    @State var isChecking: Bool = false
    @State var currentType: TextFieldFocusState = .none
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "house.fill")
                        .font(.system(size: 30, weight: .black))
                        .padding(.horizontal, 5)
                    Text("Location")
                        .font(.system(size: 25, weight: .bold))
                    Spacer()
                    HStack(spacing: 5){
                        Circle().fill(Color("CustomGreen")).frame(width: 20)
                        Circle().fill(Color(UIColor.systemGray3)).frame(width: 20)
                        Circle().fill(Color(UIColor.systemGray3)).frame(width: 20)
                    }
                }
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading){
                        VStack(alignment: .leading, spacing: 10){
                            Text("Address")
                                .font(.system(size: 20))
                                .padding(.leading, 3)
                            ListSpotCustomTextField(isChecking: $isChecking, text: $street, currentType: $currentType, type: .street, placeholder: "Street")
                                .overlay(
                                    CompleterView(currentType: $currentType, text: $street, type: .street, view: AnyView(ListSpotCustomTextField(isChecking: $isChecking, text: $street, currentType: $currentType, type: .street, placeholder: "Street")))
                                    , alignment: .top
                                )
                                .zIndex(9)
                                
                            HStack{
                                ListSpotCustomTextField(isChecking: $isChecking, text: $city, currentType: $currentType, type: .city, placeholder: "City")
                                    .overlay(
                                        CompleterView(currentType: $currentType, text: $city, type: .city, view: AnyView(ListSpotCustomTextField(isChecking: $isChecking, text: $city, currentType: $currentType, type: .city, placeholder: "City")))
                                        , alignment: .top
                                    )
                                ListSpotCustomTextField(isChecking: $isChecking, text: $state, currentType: $currentType, type: .state, placeholder: "State")
                                    .overlay(
                                        CompleterView(currentType: $currentType, text: $state, type: .state, view: AnyView(ListSpotCustomTextField(isChecking: $isChecking, text: $state, currentType: $currentType, type: .state, placeholder: "State")))
                                        , alignment: .top
                                    )
                                ListSpotCustomTextField(isChecking: $isChecking, text: $zipcode, currentType: $currentType, placeholder: "Zip Code")
                            }
                        }.padding(.vertical, 30)
                            .zIndex(10)
                        HStack {
                            Text("Notes")
                                .font(.system(size: 20))
                                .padding(.leading, 3)
                            Button {
                                showInfo = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                            }.foregroundColor(Color(UIColor.label))
                            
                        }
                        ZStack(alignment: .topLeading){
                            TextField("", text: $notes, axis: .vertical)
                                .foregroundColor(Color(UIColor.label))
                                .padding(20)
                                .background(
                                    ZStack{
                                        Color(UIColor.systemGray4).cornerRadius(10)
                                        if isChecking && notes.isEmpty {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 2)
                                                .fill(.red)
                                                .padding(1)
                                        }
                                    }.frame(minHeight: 130)
                                    , alignment: .top
                                )
                        }
                        
                    }
                }
                Spacer()
                Spacer()
                ListSpotNextButton(function: {
                    UIApplication.shared.endEditing()
                    if !zipcode.isEmpty && !notes.isEmpty && !state.isEmpty && !city.isEmpty && !street.isEmpty {
                        withAnimation {
                            page += 1
                        }
                    }else{
                        withAnimation {
                            isChecking = true
                        }
                    }
                }, isLast: false)
                
                Spacer()
            }.padding(25)
                .padding(.top, 15)
            if showInfo {
                InfoView(showInfo: $showInfo, text: "Specify where to park, what to avoid, or any other information your Buyer should know")
            }
        }

    }
}
