//
//  ManageSpots.swift
//  Parked
//
//  Created by Natanael Jop on 28/09/2022.
//

import SwiftUI

struct ManageSpots: View {
    @EnvironmentObject var reservationVM: ReservationsViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    @State var userSpots = [Spot]()
    @State var isActive = true
    @State var allReservations = [Reservation]()
    @State var allBookings = [Reservation]()
    @State var needHelp = false
    @State var pickedReservation: Reservation?
    
    var body: some View {
        NavigationView(content: {
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment: .leading, spacing: 30) {
                    HStack{
                        Text("Bookings")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }.padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 30) {
                            ForEach(reservationVM.reservations.filter({$0.spot.ownerID == userVM.currentUser?.uid}).filter({$0.frameRange.startDate > Date()})) { reservation in
                                bookingCell(reservation: reservation)
                                    .foregroundColor(.accentColor)
                            }
                        }.padding(.horizontal, 20)
                    }
                    HStack{
                        Text("Listings")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }.padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 20) {
                        if !userSpots.isEmpty {
                            ForEach($spotVM.allSpots.filter({$0.ownerID.wrappedValue == userVM.currentUser?.uid!})) { $spot in
                                NavigationLink {
                                    EditListingView(spot: spot)
                                } label: {
                                    listingCell(spot: spot, spotBinding: $spot)
                                }

                            }
                        }else{
                            Text("You don't have any spots.")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(Color(UIColor.label))
                        }
                    }.padding(.horizontal, 20)
                    HStack{
                        Text("History")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }.padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 20) {
                        if userVM.bookingHistory.isEmpty {
                            VStack{
                                Spacer()
                                Text("You don't have any parking history")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 22, weight: .semibold))
                                    .padding(30)
                                Spacer()
                            }
                        }else {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 20){
                                    ForEach(Array(Set(allBookings))) { reservation in
                                    historyCell(reservation: reservation)
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, 20)

                    Spacer()
                }.padding(.top)
            }
        }).background(Color(UIColor.systemGray6))
            .onAppear {
                DispatchQueue.main.async {
                    userSpots = spotVM.allSpots.filter({$0.ownerID == userVM.currentUser?.uid})
                    for i in reservationVM.allReservations {
                        if !allReservations.contains(where: {i.reservationID == $0.reservationID}) {
                            allReservations.append(i)
                        }
                    }
                    for i in userVM.bookingHistory {
                        if !allBookings.contains(where: {i.frameRange.startDate == $0.frameRange.startDate && i.frameRange.endDate == $0.frameRange.endDate}) {
//                            reservationVM
                            allBookings.append(i)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .overlay(
                ZStack {
                    if needHelp {
                        ZStack{
                            Color.black.opacity(0.4).ignoresSafeArea()
                            VStack(spacing: 20){
                                Text("Need help?")
                                    .font(.system(size: 20, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button {
                                    let renterPhone = "tel://\($pickedReservation.wrappedValue?.renter?.phoneNumber ?? "")"
                                    guard let url = URL(string: renterPhone) else { return }
                                    UIApplication.shared.open(url)
                                } label: {
                                    Text("Call Renter")
                                        .foregroundColor(.revLabel)
                                        .font(.system(size: 20, weight: .bold))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 50)
                                        .background(Color("CustomGreen").cornerRadius(20))
                                        .padding(20)
                                }
                                Button {
                                    let supportPhone = "tel://17140000000‬"
                                    guard let supportUrl = URL(string: supportPhone) else { return }
                                    UIApplication.shared.open(supportUrl)
                                } label: {
                                    Text("Call Support")
                                        .foregroundColor(.revLabel)
                                        .font(.system(size: 20, weight: .bold))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 50)
                                        .background(Color("CustomGreen").cornerRadius(20))
                                }

                            }.padding(30)
                                .overlay(
                                    Button(action: {
                                        needHelp = false
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(UIColor.label))
                                            .padding(20)
                                    })
                                    , alignment: .topLeading
                                )
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.revLabel)
                            ).padding(30)
                                
                        }
                    }
                }
            )
        
    }
    @ViewBuilder
    func bookingCell(reservation: Reservation) -> some View {
        VStack(alignment: .leading){
            HStack{
                Text(reservation.frameRange.startDate > Date() ? "Reserved" : "Active")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 30, weight: .bold))
                    .padding(.trailing, 60)
                Spacer()
                Text("$\(reservation.spot.price.rounded(), specifier: "%.2f")")
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 16, weight: .semibold))
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray4)))
            }
            Rectangle()
                .frame(height: 1.5)
            Text(reservation.spot.address)
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 5)
            Text("\(reservation.frameRange.startTimeString) - \(reservation.frameRange.endTimeString)")
                .padding(.horizontal, 5)
            Rectangle()
                .frame(height: 1.5)
            HStack {
                VStack(alignment: .leading){
                    Text(reservation.renter?.fullname ?? "error")
                    Text("\(reservation.renter?.car.model ?? "") \(reservation.renter?.car.make ?? "") \(reservation.renter?.car.color ?? "")")
                    Text(reservation.renter?.phoneNumber ?? "error")
                }.padding(.horizontal, 5)
                Spacer()
                if reservation.frameRange.startDate < Date() {
                    NavigationLink {
                        ChatView()
                    } label: {
                        Image(systemName: "bubble.left.fill")
                            .foregroundColor(Color(UIColor.label))
                            .font(.system(size: 30, weight: .semibold))
                    }
                }
            }
            
        }.foregroundColor(.white)
        .padding(20)
            .background(RoundedRectangle(cornerRadius: 10))
    }
    
    func historyCell(reservation: Reservation) -> some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                VStack(alignment: .leading){
                    Text(reservation.spot.address)
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.horizontal, 5)
                    Text("\(reservation.frameRange.startTimeString) - \(reservation.frameRange.endTimeString)")
                        .padding(.horizontal, 5)
                        .padding(.top)
                    Text("\(reservation.frameRange.startDateString) - \(reservation.frameRange.endDateString)")
                        .padding(.horizontal, 5)
                }
                Spacer()
                Text("$\(reservation.spot.price.rounded(),  specifier: "%.2f")")
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 20, weight: .semibold))
                    .padding(5)
            }
           
            Rectangle()
                .frame(height: 1.5)
            HStack {
                VStack(alignment: .leading){
                    Text(reservation.renter?.fullname ?? "error")
                    Text("\(reservation.renter?.car.model ?? "error") \(reservation.renter?.car.make ?? "error") \(reservation.renter?.car.color ?? "error")")
                    Text(reservation.renter?.phoneNumber ?? "error")
                }.padding(.horizontal, 5)
                Spacer()
                Button {
                    needHelp = true
                    pickedReservation = reservation
                } label: {
                    Text("Report")
                        .foregroundColor(Color(UIColor.label))
                        .font(.system(size: 17, weight: .semibold))
                        .padding(5)
                        .padding(.horizontal, 10)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.revLabel))
                }
            }
            
        }.foregroundColor(Color(UIColor.label))
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray4)))

    }
    
    func listingCell(spot: Spot, spotBinding: Binding<Spot>) -> some View {
        VStack(spacing: 30) {
            HStack {
                VStack(alignment: .leading){
                    Text(spot.address)
                        .font(.system(size: 18, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Toggle("", isOn: !spotBinding.isHidden)
                    .onChange(of: spotBinding.isHidden.wrappedValue) { newValue in
                        userVM.spotVM.setVisibility(for: newValue, spotID: spot.sid)
                    }
                    .labelsHidden()
            }
            HStack{
                Spacer()
                VStack(spacing: 10){
                    Text("$\(spot.price, specifier: "%.2f")/hr")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Rate")
                        .font(.system(size: 12))
                }
                Spacer()
                VStack(spacing: 10){
                    Text("24/7")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Available")
                        .font(.system(size: 12))
                }
                Spacer()
                VStack(spacing: 10){
                    Text("\(allReservations.filter({$0.spot.sid == spot.sid && $0.frameRange.endDate > Date()}).count)")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Bookings")
                        .font(.system(size: 12))
                }
                Spacer()
            }
        }.foregroundColor(Color(UIColor.label))
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray4)))
    }
}

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

struct ManageSpots_Previews: PreviewProvider {
    static var previews: some View {
        ManageSpots().environmentObject(UserViewModel()).environmentObject(SpotsViewModel())
    }
}


//spotVM.deleteSpot(spot: spot) { error in
//    if let error = error {
//        print("Error: \(error.localizedDescription)")
//    }else{
//        userVM.deleteUserSpot(spot: spot) { error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//            }else{
//                print("Działa!!!")
//            }
//        }
//    }
//}
