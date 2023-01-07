//
//  ListSpotPricingView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI

class Helper: ObservableObject {
    @Published var price = "" {
            didSet {
                if price.count > characterLimit && oldValue.count <= characterLimit {
                    price = oldValue
                }
            }
        }
    @Published var price2 = "" {
            didSet {
                if price2.count > characterLimit && oldValue.count <= characterLimit {
                    price2 = oldValue
                }
            }
        }
    
    let characterLimit: Int

    init(limit: Int = 2){
        characterLimit = limit
    }
}

struct ListSpotPricingView: View {
    @Binding var page: Int
    @Binding var week: [DayOfAvailablity]
    @Binding var isAvailable: Bool
    @Binding var availabilityRange: [AvailabilityRange]
    
    @State var is24h = true
    @State var isChecking = false
    @State var showInfo = false
    @State var showSecondInfo = false
    

    @ObservedObject var helper: Helper
    
    var body: some View {
        ZStack {
            VStack{
                HStack{
                    Image(systemName: "dollarsign")
                        .font(.system(size: 30, weight: .bold))
                        .padding(.horizontal, 5)
                    Text("Pricing")
                        .font(.system(size: 25, weight: .bold))
                    Spacer()
                    HStack(spacing: 5){
                        Circle().fill(Color("CustomGreen")).frame(width: 20)
                        Circle().fill(Color("CustomGreen")).frame(width: 20)
                        Circle().fill(Color(UIColor.systemGray3)).frame(width: 20)
                    }
                }
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10){
                        HStack {
                            Text("Hourly Rate")
                                .font(.system(size: 20))
                                .padding(.leading, 3)
                            Button {
                                showInfo = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                            }.foregroundColor(Color(UIColor.label))
                        }
                        HStack{
                            Text("$")
                                .font(.system(size: 20))
                                .padding(.leading, 3)
                            ListSpotCustomTextField(isChecking: $isChecking, text: $helper.price, currentType: .constant(.none), placeholder: "")
                                .frame(width: 80)
                            Text(".")
                                .font(.system(size: 20))
                                .padding(.leading, 3)
                            ListSpotCustomTextField(isChecking: $isChecking, text: $helper.price2, currentType: .constant(.none), placeholder: "")
                                .frame(width: 80)
                        }
                        HStack{
                            Text("24/7 Availabilty? ")
                                .font(.system(size: 20))
                                .padding(.leading, 3)
                            Button {
                                showSecondInfo = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                            }.foregroundColor(Color(UIColor.label))
                            Toggle("", isOn: $is24h.animation())
                                .padding(.trailing,3)
                        }.padding(.top)
                    }.padding(.vertical, 30)
                    if !is24h {
                        VStack(spacing: 5){
                            ForEach(Array(zip(week, week.indices)), id:\.0) { day, idx in
                                dayCell(day: day, idx: idx)
                            }
                        }
                    }
                }
                ListSpotNextButton(function: {
                    UIApplication.shared.endEditing()
                    withAnimation {
                        if !helper.price.isEmpty && !helper.price2.isEmpty {
                            if !is24h {
                                if week.filter({$0.isAvailable}).isEmpty {
                                    is24h = true
                                } else {
                                    for day in week.filter({$0.isAvailable}) {
                                        availabilityRange.append(AvailabilityRange(day: day.name, startDate: day.timeStart, endDate: day.timeFinish))
                                    }
                                }
                            }
                            page += 1
                        }else{
                            isChecking = true
                        }
                    }
                }, isLast: false).padding(.top, 30)
                Spacer()
            }.padding(20)
                .padding(.top, 15)
            if showInfo {
                InfoView(showInfo: $showInfo, text: "Parked will collect a 20% service fee on this rate but you keep the rest!")
            }
            if showSecondInfo {
                InfoView(showInfo: $showSecondInfo, text: "When would you like your parking spot available to Buyers?")
            }
        }

    }
    @ViewBuilder
    func dayCell(day: DayOfAvailablity, idx: Int) -> some View {
        HStack(spacing: 10){
            Button {
                week[idx].isAvailable.toggle()
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemGray3))
                    Text(day.isAvailable ? "X" : "")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }.frame(width: 25, height: 25)
            }
            Text(day.name)
                .font(.system(size: 14, weight: .regular))
            HStack(alignment: .center){
                Spacer(minLength: 0)
                if day.isAvailable {
                    DatePicker("", selection: .constant(day.timeStart), displayedComponents: .hourAndMinute)
                    Spacer()
                    Text("to")
                    Spacer()
                    DatePicker("", selection: .constant(day.timeFinish), displayedComponents: .hourAndMinute)
                }
                
            }.scaleEffect(x: 0.8, y: 0.8)
                .onChange(of: day.timeStart) { newValue in
                    if newValue > day.timeFinish {
                        week[idx].timeFinish = newValue
                    }
                }
                .onChange(of: day.timeFinish) { newValue in
                    if newValue < day.timeStart {
                        week[idx].timeStart = newValue
                    }
                }
                
            
        }.onAppear {
            var startComp = DateComponents()
            startComp.hour = 9
            startComp.year = 2030
            var finishComp = DateComponents()
            finishComp.hour = 17
            finishComp.year = 2030
            let startDate = Calendar.current.date(from: startComp)
            let finishDate = Calendar.current.date(from: finishComp)
            week[idx].timeStart = startDate!
            week[idx].timeFinish = finishDate!
        }
    }
}
