//
//  ReservationCell.swift
//  Parked
//
//  Created by Natanael Jop on 04/10/2022.
//

import SwiftUI

struct ReservationCell: View {
    var reservation: Reservation
    var color: Color
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var reservationVM: ReservationsViewModel
    @EnvironmentObject var spotVM: SpotsViewModel
    @State var pickedSpot: Spot?
    var body: some View {
        VStack{
            VStack{
                HStack{
                    VStack(alignment: .leading){
                        Text(reservation.spot.location.street)
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(reservation.spot.location.city), \(reservation.spot.location.state) \(reservation.spot.location.zip_code)")
                    }
                    Spacer()
                }
                Rectangle()
                    .frame(height: 1)
                    .padding(.vertical, 8)
                HStack{
                    VStack(alignment: .leading){
                        Text("\(reservation.frameRange.startTimeString)")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(reservation.frameRange.startDateString)")
                    }
                    Spacer()
                    HStack(spacing: 15){
                        Circle()
                            .fill(color)
                            .frame(width: 8)
                        Circle()
                            .fill(color)
                            .frame(width: 8)
                        Circle()
                            .fill(color)
                            .frame(width: 8)
                        Circle()
                            .fill(color)
                            .frame(width: 8)
                        Circle()
                            .fill(color)
                            .frame(width: 8)
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        Text("\(reservation.frameRange.endTimeString)")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(reservation.frameRange.endDateString)")
                    }
                }
            }.padding(.horizontal, 25)
            HStack{
                Text("$\((reservation.spot.price*Double((computeDifference(from: reservation.frameRange.startDate, to: reservation.frameRange.endDate))))*1.2, specifier: "%.2f")")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button {
                    let url = URL(string: "maps://?saddr=&daddr=\(reservation.spot.convertedLocation.coordinate.latitude),\(reservation.spot.convertedLocation.coordinate.longitude)")
                    if UIApplication.shared.canOpenURL(url!) {
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text("Map it")
                        .foregroundColor(.black)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.white))
                }.disabled(spotVM.isLoading)

            }.padding(15)
                .padding(.horizontal, 10)
                .background(color.cornerRadius(10, corners: [.bottomLeft, .bottomRight]))
        }.sheet(item: $pickedSpot, content: { spot in
            PinView(spot: spot, isReservationPage: false)
        })
        .foregroundColor(Color(UIColor.label))
        .padding(.top, 25)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.revLabel)
                    .shadow(radius: 3, y: 3)
            )
            .padding(.vertical, 10)
    }
    
    func computeDifference(from fromDate: Date, to toDate: Date) -> Int {
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
