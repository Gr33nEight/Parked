//
//  PinView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI
import CoreLocation

struct UpcomingView: View {
    var reservation: Reservation
    @State var agreedToFirst = false
    @State var agreedToSecond = false

    @EnvironmentObject var reservationVM: ReservationsViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    @Environment(\.dismiss) var dismiss
    
    let isActive: Bool
    
    @State var timeLeft = ""
    @State var extendedHours = 0
    @State var extendedMinutes = 0
    @State var newDate = Date()
    @State var needHelp = false
    
    @State var timeBlocker = 24
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0){
                if let image = reservation.spot.image {
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
                        Text("\(reservation.spot.location.street), \(reservation.spot.location.city  )")
                            .font(.system(size: 35, weight: .semibold))
                        if !isActive {
                            Text("Date: \(reservation.frameRange.startDateString) - \(reservation.frameRange.endDateString)")
                                .font(.system(size: 22, weight: .semibold))
                            Text("Time: \(reservation.frameRange.startTimeString) - \(reservation.frameRange.endTimeString)")
                                .font(.system(size: 22, weight: .semibold))
                        }else{
                            Text("Time Remaining")
                                .font(.system(size: 22, weight: .semibold))
                            HStack{
                                Spacer()
                                Text(timeLeft)
                                    .font(.system(size: 70, weight: .bold))
                                Spacer()
                            }
                        }
                        Text("Rate: $\(reservation.spot.price, specifier: "%.2f")/hr")
                            .font(.system(size: 20, weight: .semibold))
                        if !isActive {
                            Text("Subtotal: $\(reservation.spot.price*Double(reservation.spot.timeDifference ?? 1), specifier: "%.2f")")
                                .font(.system(size: 20, weight: .semibold))
                            HStack(spacing: 0){
                                Text("Total (with tax): ")
                                Text("$\((reservation.spot.price*Double(reservation.spot.timeDifference ?? 1))*1.2, specifier: "%.2f")")
                                    .foregroundColor(Color("CustomGreen"))
                            }.font(.system(size: 20, weight: .semibold))
                        }else{
                            ExtendTimeView(extendedHours: $extendedHours, extendedMinutes: $extendedMinutes, blocker: timeBlocker)
                        }
                        if !isActive {
                            ZStack(alignment: .leading){
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                                    .fill(Color("CustomGreen"))
                                Text("Notes: \(reservation.spot.notes)")
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(12)
                                    .padding(.bottom)
                            }.padding(.vertical)
                            HStack{
                                Spacer()
                                Button {
                                    spotVM.isLoading = true
                                    reservationVM.deleteReservation(reservationID: reservation.reservationID ?? "") { error in
                                        if let error = error {
                                            print("Error: \(error.localizedDescription)")
                                        } else {
                                            spotVM.setSpotAvailability(for: true, spotID: reservation.spot.sid)
                                            if !userVM.reservationHistory.contains(where: {$0.frameRange == reservation.frameRange}) {
                                                userVM.addResrvationToHistory(reservation: reservation) { error in
                                                    if let error = error {
                                                        print("Error: \(error.localizedDescription)")
                                                    }else{
                                                        dismiss()
                                                        spotVM.isLoading = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Cancel")
                                        .foregroundColor(.revLabel)
                                        .font(.system(size: 25, weight: .bold))
                                        .padding(.vertical, 20)
                                        .padding(.horizontal, 100)
                                        .background(Color.red.cornerRadius(20))
                                        .padding(20)
                                }.disabled(spotVM.isLoading)
                                
                                Spacer()
                            }
                        }else{
                            HStack{
                                Spacer()
                                Button {
                                    spotVM.isLoading = true
                                    newDate = reservation.frameRange.endDate.addingTimeInterval((Double(extendedHours)*3600)+(Double(extendedMinutes)*60))
                                    reservationVM.extendTimeOfReservation(reservation: reservation, newDate: newDate) { error in
                                        if let error = error {
                                            print("Error: \(error.localizedDescription)")
                                        }else{
                                            timeLeft = computeDifference(from: Date(), to: newDate)
                                            dismiss()
                                            spotVM.isLoading = false
                                        }
                                    }
                                } label: {
                                    Text("Extend")
                                        .foregroundColor(.revLabel)
                                        .font(.system(size: 25, weight: .bold))
                                        .padding(.vertical, 20)
                                        .padding(.horizontal, 100)
                                        .background(Color.accentColor.cornerRadius(20))
                                        .padding(.horizontal)
                                }.disabled(spotVM.isLoading)
                                
                                Spacer()
                            }
                        }
                        if isActive {
                            ZStack(alignment: .leading){
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                                    .fill(Color("CustomGreen"))
                                Text("Notes: \(reservation.spot.notes)")
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(12)
                                    .padding(.bottom)
                            }.padding(.vertical)
                            HStack{
                                Spacer()
                                Button {
                                    withAnimation {
                                        needHelp = true
                                    }
                                } label: {
                                    Text("Trouble Parking?")
                                        .foregroundColor(Color("CustomGreen"))
                                        .font(.system(size: 25, weight: .bold))
                                        .padding(.vertical, 20)
                                        .padding(.horizontal, 20)
                                        .background(Color(UIColor.systemGray3).cornerRadius(20))
                                        .padding(.horizontal)
                                }
                                Spacer()
                            }
                            
                        }
                    }.padding(20)
                }
                Spacer()
            }
            if needHelp {
                ZStack{
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20){
                        Text("Need help?")
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            let renterPhone = "tel://\(reservation.renter?.phoneNumber ?? "")"
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
        }.ignoresSafeArea()
            .overlay(
                HStack{
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
                    Spacer()
                    if isActive {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.revLabel)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill()
                                )
                                .padding(.trailing)
                        })
                    }
                }
                , alignment: .top
            )
            .onAppear {
                newDate = reservation.frameRange.endDate
                timeLeft = computeDifference(from: Date(), to: newDate)
                
                var allReservationWithSid = [Reservation]()
                
                for res in reservationVM.allReservations {
                    if res.spot.sid == reservation.spot.sid {
                        allReservationWithSid.append(res)
                    }
                }
                
                let theclosestOne = allReservationWithSid.filter({$0.reservationID != reservation.reservationID}).min(by: {$0.frameRange.endDate < $1.frameRange.endDate})
                
                if theclosestOne != nil {
                    timeBlocker = computeDifferenceInt(from: reservation.frameRange.endDate, to: theclosestOne!.frameRange.startDate)-1
                }else{
                    timeBlocker = 24
                }
            }
            .onReceive(timer) { _ in
                timeLeft = computeDifference(from: Date(), to: newDate)
            }
    }
    func computeDifference(from fromDate: Date, to toDate: Date) -> String {
        let delta = toDate - fromDate // `Date` - `Date` = `TimeInterval`
        if delta >= 0  {
            return delta.stringFromTimeInterval()
        }else{
            return ""
        }
    }
    func computeDifferenceInt(from fromDate: Date, to toDate: Date) -> Int {
        let delta = toDate - fromDate // `Date` - `Date` = `TimeInterval`
        if delta.doubleFromTimeInterval() <= 1 {
            return 1
        }else if delta.doubleFromTimeInterval() >= 0  {
            return Int(delta.doubleFromTimeInterval().rounded())
        }else{
            return 1
        }
    }
}

struct ExtendTimeView: View {
    @Binding var extendedHours: Int
    @Binding var extendedMinutes: Int
    var blocker: Int
    var body: some View {
        HStack(spacing: 0){
            Text("Extend:")
                .font(.system(size: 20, weight: .semibold))
                .padding(.trailing)
            Picker("", selection: $extendedHours) {
                ForEach(0...(blocker), id:\.self){
                    Text("\($0)")
                }
            }.pickerStyle(.wheel)
                .frame(width: 50)
                .clipped()
            Text(":")
            Picker("", selection: $extendedMinutes) {
                ForEach(0...(blocker > 0 ? 59 : 0), id:\.self){
                    Text("\($0)")
                }
            }.pickerStyle(.wheel)
                .frame(width: 50)
                .clipped()
            Spacer()
        }
    }
}

extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
    }
}
