//
//  PinView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI
import CoreLocation

struct PinView: View {
    var spot: Spot
    @State var agreedToFirst = false
    @State var agreedToSecond = false
    @State var agreedToThird = false
    @State var wantedToReserve = false
    @State var isChecking = false
    @State var name = ""
    @State var make = ""
    @State var model = ""
    @State var color = ""
    
    @State var frameRange = DateRange(startDate: Date(), endDate: Date().addingTimeInterval(3600))
    
    @EnvironmentObject var reservationVM: ReservationsViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var hourDifference = 1.0
    @State var reservation: Reservation?
    
    @State var reservationTimeBlocker: Date?

    let isReservationPage: Bool
    
    @State var availabilityMessage = ""
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0){
                if let image = spot.image {
                    AsyncImage(url: URL(string: image)) { img in
                        img
                            .centerCropped()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
                        
                    } placeholder: {
                        ZStack{
                            Color.revLabel
                                .frame(width: UIScreen.main.bounds.width, height: 280)
                            ProgressView()
                        }
                            
                    }.frame(width: UIScreen.main.bounds.width)
                        .mask(
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                        )
                    
                }else{
                    Image("logo").mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                    )
                }
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20){
                        Text("\(spot.location.street), \(spot.location.city  )")
                            .font(.system(size: 35, weight: .semibold))
                        VStack(alignment: .leading){
                            HStack{
                                Text("Available\(availabilityMessage == "Today" ? "" : " until"): ")
                                    .font(.system(size: 22, weight: .semibold))
                                Text(availabilityMessage).font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.accentColor)
                                Spacer()
                            }
                            HStack{
                                Text("Time: ")
                                    .font(.system(size: 22, weight: .semibold))
                                Text(frameRange.startTimeString).font(.system(size: 20, weight: .semibold))
                                Text(" - ")
                                Text(frameRange.endTimeString).font(.system(size: 20, weight: .semibold))
                                Spacer()
                            }
                            HStack{
                                Text("Date: ")
                                    .font(.system(size: 22, weight: .semibold))
                                Text(frameRange.startDateString).font(.system(size: 20, weight: .semibold))
                                Text(" - ")
                                Text(frameRange.endDateString).font(.system(size: 20, weight: .semibold))
                                Spacer()
                            }
                        }.onChange(of: frameRange.startDate) { newValue in
                            if newValue > frameRange.endDate {
                                frameRange.endDate = newValue
                            }
                        }
                        .onChange(of: frameRange.endDate) { newValue in
                            if newValue < frameRange.startDate {
                                frameRange.startDate = newValue
                            }
                        }
                        ZStack(alignment: .leading){
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2)
                                .fill(Color("CustomGreen"))
                            Text("Notes: \(spot.notes)")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 20, weight: .semibold))
                                .padding(12)
                        }
                        Text("Rate: $\(spot.price, specifier: "%.2f")/hr")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Subtotal: $\(spot.price * Double(hourDifference), specifier: "%.2f")")
                            .font(.system(size: 20, weight: .semibold))
                        HStack(spacing: 0){
                            Text("Total (with tax): ")
                            Text("$\((spot.price * Double(hourDifference))*1.2, specifier: "%.2f")")
                                .foregroundColor(Color("CustomGreen"))
                        }.font(.system(size: 20, weight: .semibold))
                        if spot.isAvailable {
                            Button {
                                agreedToFirst.toggle()
                            } label: {
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                            .fill(!agreedToFirst && wantedToReserve ? .red :Color(UIColor.systemGray3))
                                        Text(agreedToFirst ? "X" : "")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(UIColor.label))
                                    }.frame(width: 30, height: 30)
                                    Text("I have read the renter’s notes and understand exactly where to park.")
                                        .foregroundColor(Color(UIColor.label))
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 12))
                                }
                            }.padding(.horizontal, 20)
                                .onChange(of: agreedToFirst) { newValue in
                                    wantedToReserve = false
                                }
                            Button {
                                agreedToSecond.toggle()
                            } label: {
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                            .fill(!agreedToSecond && wantedToReserve ? .red : Color(UIColor.systemGray3))
                                        Text(agreedToSecond ? "X" : "")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(UIColor.label))
                                    }.frame(width: 30, height: 30)
                                    Text("I correctly entered the details of the car that I will park at this address.")
                                        .foregroundColor(Color(UIColor.label))
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 12))
                                }
                            }.padding(.horizontal, 20)
                                .onChange(of: agreedToSecond) { newValue in
                                    wantedToReserve = false
                                }

                            Button {
                                agreedToThird.toggle()
                            } label: {
                                HStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                            .fill(!agreedToThird && wantedToReserve ? .red : Color(UIColor.systemGray3))
                                        Text(agreedToThird ? "X" : "")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(UIColor.label))
                                    }.frame(width: 30, height: 30)
                                    Text("I will leave before my end time to avoid a possible fee equivalent to 50% of the original total and potential towing.")
                                        .foregroundColor(Color(UIColor.label))
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 12))
                                }
                            }.padding(.horizontal, 20)
                                .onChange(of: agreedToThird) { newValue in
                                    wantedToReserve = false
                                }
                            customTextField(text: $make, placeholder: "Make", isPassword: false)
                            customTextField(text: $model, placeholder: "Model", isPassword: false)
                            customTextField(text: $color, placeholder: "Color", isPassword: false)
                            HStack{
                                Spacer()
                                Button {
                                    wantedToReserve = true
                                    isChecking = true
                                    if isChecking && agreedToFirst && agreedToSecond && agreedToThird && wantedToReserve {
                                        spotVM.isLoading = true
                                        reservationVM.reserveSpot(reservation: Reservation(spot: spot, frameRange:  DateRange(startDate: frameRange.startDate, endDate: frameRange.endDate), name: name, bookingUserID: userVM.currentUser!.uid ?? "", spotID: spot.sid)) { error in
                                            if let error = error {
                                                print("Error: \(error.localizedDescription)")
                                            }else{
                                                if let currentUser = userVM.currentUser {
                                                    userVM.upadateUserInfo(uid: currentUser.uid ?? "", fullname: currentUser.fullname, email: currentUser.email, phoneNumber: currentUser.phoneNumber, car: Car(make: make, model: model, color: color)) { error in
                                                        if let error = error {
                                                            print("Error: \(error.localizedDescription)")
                                                        }else{
                                                            dismiss()
                                                            spotVM.setSpotAvailability(for: false, spotID: spot.sid)
                                                            spotVM.isLoading = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Reserve")
                                        .foregroundColor(.revLabel)
                                        .font(.system(size: 25, weight: .bold))
                                        .padding(.vertical, 20)
                                        .padding(.horizontal, 80)
                                        .background(Color("CustomGreen").cornerRadius(20))
                                        .padding(20)
                                }

                                Spacer()
                            }
                        }
                    }.padding(20)
                }
                Spacer()
            }.ignoresSafeArea()
                .overlay(
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.revLabel)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill()
                            )
                            .padding(.leading)
                    })
                    , alignment: .topLeading
                )
        }.onAppear {
            
            if isReservationPage {
                frameRange = userVM.currentUser?.frameRange ?? DateRange(startDate: Date(), endDate: Date().addingTimeInterval(14400))
            }else{
                if reservationVM.allReservations.contains(where: {$0.spot.sid == spot.sid} ){
                    reservation = reservationVM.allReservations.first(where: {$0.spot.sid == spot.sid})
                    if reservation!.frameRange.endDate < Date().addingTimeInterval(14400) {
                        frameRange.endDate = reservation!.frameRange.endDate.addingTimeInterval(-900)
                    }else{
                        frameRange.endDate = Date().addingTimeInterval(14400)
                    }
                }else{
                    frameRange.endDate = Date().addingTimeInterval(14400)
                }
            }
            make = userVM.currentUser!.car.make
            model = userVM.currentUser!.car.model
            color = userVM.currentUser!.car.color
            
            availabilityChecker()
        }
        .onChange(of: frameRange) { newValue in
            self.hourDifference = computeDifference(from: newValue.startDate, to: newValue.endDate)
        }
    }
    func computeDifference(from fromDate: Date, to toDate: Date) -> Double {
        let delta = toDate - fromDate // `Date` - `Date` = `TimeInterval`
        if delta.doubleFromTimeInterval() >= 0  {
            return delta.doubleFromTimeInterval()
        }else{
            return 1
        }
    }
    
    func availabilityChecker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en")
        let today = dateFormatter.string(from: Date())
        let pickedDay = dateFormatter.string(from: frameRange.startDate)
        
        if reservationVM.allReservations.contains(where: {$0.spot.sid == spot.sid}) {
            availabilityMessage = reservationVM.allReservations.first(where: {$0.spot.sid == spot.sid})?.frameRange.startDate.addingTimeInterval(-900).formatted(date: .omitted, time: .shortened) ?? "error"
        }else{
            if spot.availabilityRange.filter({$0.day != ""}).isEmpty {
                availabilityMessage = "Today"
            }else{
                for day in spot.availabilityRange {
                    if isReservationPage {
                        if day.day == pickedDay {
                            availabilityMessage = day.endDate.addingTimeInterval(-900).formatted(date: .omitted, time: .shortened)
                        }else {
                            availabilityMessage = "\((spot.availabilityRange.first(where: {$0.day != ""})?.day)?.capitalized ?? "error") \(spot.availabilityRange.first(where: {$0.day != ""})?.endDate.addingTimeInterval(-900).formatted(date: .omitted, time: .shortened) ?? "error")"
                        }
                    }else{
                        if day.day == today {
                            availabilityMessage = day.endDate.addingTimeInterval(-900).formatted(date: .omitted, time: .shortened)
                        }else {
                            availabilityMessage = "from \((spot.availabilityRange.first(where: {$0.day != ""})?.day)?.capitalized ?? "error")"
                        }
                    }
                }
            }
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


