//
//  ProfileMainView.swift
//  Parked
//
//  Created by Natanael Jop on 20/09/2022.
//

import SwiftUI

struct ProfileMainView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.openURL) var openURL
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20){
                    Text("Become a Renter").font(.system(size: 20, weight: .semibold))
                    Grid {
                        GridRow {
                            gridItem(image: "plus", text: "List", destination: AnyView(ListSpotView()))
                            gridItem(image: "clipboard", text: "Manage", destination: AnyView(ManageSpots()))
                        }.padding(5)
                        GridRow {
                            gridItem(image: "creditcard", text: "Payout", destination: AnyView(ListSpotView()))
                            Button {
                                openURL(URL(string: "https://www.apple.com")!)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.revLabel)
                                        .shadow(radius: 2, y: 3)
                                    VStack{
                                        Image(systemName: "megaphone.fill")
                                            .font(.system(size: 60, weight: .regular))
                                            .foregroundColor(Color(UIColor.label))
                                            .padding(5)
                                        Text("Promote")
                                            .foregroundColor(Color(UIColor.label))
                                            .fontWeight(.semibold)
                                    }.padding(10)
                                }
                            }
                                
                        }.padding(5)
                    }
                    Text("Account Settings").font(.system(size: 20, weight: .semibold))
                    VStack(spacing: 20){
                        cell(text: "Parking History", caption: "Update information and manage your account", destination: AnyView(ParkingHistoryView()))
                        Rectangle().frame(height: 0.4)
                        cell(text: "Payment Methods", caption: "Manage payment methods and DoorDash Credits", destination: AnyView(TermsView()))
                        Rectangle().frame(height: 0.4)
                        cell(text: "Account Settings", caption: "Check or edit your account's settings", destination: AnyView(AccountSettings()))
                        VStack(spacing: 20){
                            Rectangle().frame(height: 0.4)
                            cell(text: "Privacy", caption: "Learn about Privacy and manage settings", destination: AnyView(PrivacyView()))
                            Rectangle().frame(height: 0.4)
                            cell(text: "Terms & Conditions", caption: "Read about terms and conditions", destination: AnyView(TermsView()))
                            Rectangle().frame(height: 0.3)
                            cell(text: "Contact Us", caption: "Contact with us", destination: AnyView(ContactUsView()))
                            Rectangle().frame(height: 0.3)
                        }
                        Button {
                            userVM.logOut()
                        } label: {
                            HStack{
                                VStack(alignment: .leading, spacing: 8){
                                    Text("Log Out")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.system(size: 18))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.label))
                                    .fontWeight(.bold)
                            }
                        }
                        Rectangle().frame(height: 0.3)
                    }.padding(.horizontal, 10)
                }.padding(20)
            }.navigationTitle("Natanael Jop")
                .background(Color(UIColor.systemGray6))
        }
    }
    @ViewBuilder
    func gridItem(image: String, text: String, destination: AnyView) -> some View {
        NavigationLink {
            destination
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.revLabel)
                    .shadow(radius: 2, y: 3)
                VStack{
                    Image(systemName: image)
                        .font(.system(size: 60, weight: .regular))
                        .foregroundColor(Color(UIColor.label))
                        .padding(5)
                    Text(text)
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(.semibold)
                }.padding(10)
            }
        }
    }
    func cell(text: String, caption: String, destination: AnyView) -> some View {
        NavigationLink { destination } label: {
            HStack{
                VStack(alignment: .leading, spacing: 8){
                    Text(text)
                        .foregroundColor(Color(UIColor.label))
                        .font(.system(size: 18))
                    Text(caption)
                        .foregroundColor(Color(UIColor.systemGray))
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 14))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
            }
        }
    }
}

