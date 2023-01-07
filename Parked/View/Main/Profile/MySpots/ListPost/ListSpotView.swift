//
//  ListSpotView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI
import MapKit

struct DayOfAvailablity: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var timeStart = Date()
    var timeStartString: String {
        return ""
    }
    var timeFinish = Date()
    var timeFinishString: String {
        return ""
    }
    var isAvailable = false
}

struct ListSpotView: View {
    @Environment(\.dismiss) var dismiss
    @State var street = ""
    @State var city = ""
    @State var state = ""
    @State var zipcode = ""
    @State var notes = ""
    @State var page = 1
    @State var isAvailable = true
    @State var availabilityRange = [AvailabilityRange]()
    
    @State var week = [
        DayOfAvailablity(name: "Sunday"),
        DayOfAvailablity(name: "Monday"),
        DayOfAvailablity(name: "Tuesday"),
        DayOfAvailablity(name: "Wednesday"),
        DayOfAvailablity(name: "Thursday"),
        DayOfAvailablity(name: "Friday"),
        DayOfAvailablity(name: "Saturday")
    ]
    
    @EnvironmentObject var locationService: LocationService
    @StateObject var helper = Helper()
    
    var body: some View {
        ZStack{
            Color("CustomGreen")
            VStack{
                HStack{
                    Button {
                        withAnimation {
                            goBack()
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
                    Group {
                        if page == 1 {
                            ListSpotLocationView(street: $street, city: $city, state: $state, zipcode: $zipcode, notes: $notes, page: $page)
                        }else if page == 2 {
                            ListSpotPricingView(page: $page, week: $week, isAvailable: $isAvailable, availabilityRange: $availabilityRange, helper: helper)
                        }else if page == 3 {
                            ListSpotVerifyView(street: $street, city: $city, state: $state, zipcode: $zipcode, notes: $notes, page: $page, price: $helper.price, price2: $helper.price2, availabilityRange: $availabilityRange)
//                            ListSpotVerifyView(street: $street, city: $city, state: $state, zipcode: $zipcode, notes: $notes, page: $page, price: $helper.price, price2: $helper.price2)
                        }
                    }
                }.padding(.top, 60)
            }.padding(.top, 50)
        }.ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
    func goBack() {
        if page == 1 {
            dismiss()
        }else if page == 2 {
            page -= 1
        }else if page == 3 {
            page -= 1
        }
    }
}

struct ListSpotView_Previews: PreviewProvider {
    static var previews: some View {
        ListSpotView()
    }
}
