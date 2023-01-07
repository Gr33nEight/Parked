//
//  EditListingView.swift
//  Parked
//
//  Created by Natanael Jop on 30/09/2022.
//

import SwiftUI
import MapKit

struct EditListingView: View {
    
    @State var spot: Spot
    
    @State var street = ""
    @State var city = ""
    @State var state = ""
    @State var zipcode = ""
    @State var notes = ""
    @State var price = ""
    @State var price2 = ""
    @State var isAvailable = true
    @State var week = [
        DayOfAvailablity(name: "Sunday"),
        DayOfAvailablity(name: "Monday"),
        DayOfAvailablity(name: "Tuesday"),
        DayOfAvailablity(name: "Wednesday"),
        DayOfAvailablity(name: "Thursday"),
        DayOfAvailablity(name: "Friday"),
        DayOfAvailablity(name: "Saturday")
    ]
    @State var isSaving = false
    @State var imageURL = ""
    @State var is24 = false
    @State var availabilityRange = [AvailabilityRange]()
    
    @State private var spotImage = UIImage()
    @State private var showSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false
    
    @EnvironmentObject var spotVM: SpotsViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject var helper = Helper()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .leading, spacing: 20){
                HStack{
                    Text("Address")
                        .font(.system(size: 26, weight: .semibold))
                    Spacer()
                }
                VStack{
                    ListSpotCustomTextField(isChecking: $isSaving, text: $street, currentType: .constant(.none), placeholder: street)
                    HStack(spacing: 10){
                        ListSpotCustomTextField(isChecking: $isSaving, text: $city, currentType: .constant(.none), placeholder: city)
                        ListSpotCustomTextField(isChecking: $isSaving, text: $state, currentType: .constant(.none), placeholder: state)
                        ListSpotCustomTextField(isChecking: $isSaving, text: $zipcode, currentType: .constant(.none), placeholder: zipcode)
                    }
                }
                HStack{
                    Text("Notes")
                        .font(.system(size: 26, weight: .semibold))
                    Spacer()
                }
                
                TextField("", text: $notes, axis: .vertical)
                    .foregroundColor(Color(UIColor.label))
                    .padding(20)
                    .background(
                        ZStack{
                            Color(UIColor.systemGray4).cornerRadius(10)
                            if isSaving && notes.isEmpty {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .fill(.red)
                                    .padding(1)
                            }
                        }.frame(minHeight: 130)
                        , alignment: .top
                    ).frame(minHeight: 130, alignment: .top)
                HStack{
                    Text("Hourly Rate")
                        .font(.system(size: 26, weight: .semibold))
                    Spacer()
                    
                }
                HStack{
                    Text("$")
                        .font(.system(size: 20))
                        .padding(.leading, 3)
                    ListSpotCustomTextField(isChecking: $isSaving, text: $helper.price, currentType: .constant(.none), placeholder: price)
                    Text(".")
                        .font(.system(size: 20))
                        .padding(.leading, 3)
                    ListSpotCustomTextField(isChecking: $isSaving, text: $helper.price2, currentType: .constant(.none), placeholder: price2)
                }
                HStack{
                    Text("24/7 Availability?")
                        .font(.system(size: 26, weight: .semibold))
                    Spacer(minLength: 0)
                    Toggle("", isOn: $is24.animation())
                        .labelsHidden()
                }
                if !is24 {
                    VStack(spacing: 5){
                        ForEach(Array(zip(week, week.indices)), id:\.0) { day, idx in
                            dayCell(day: day, idx: idx)
                        }
                    }
                }
                HStack{
                    Text("Spot Image")
                        .font(.system(size: 26, weight: .semibold))
                    Spacer()
                }
                
                VStack(alignment: .center, spacing: 20){
                    Button {
                        showSheet = true
                    } label: {
                        ZStack{
                            if imageURL != "" {
                                AsyncImage(url: URL(string: imageURL)) { img in
                                    img
                                        .resizable()
                                        .scaledToFit()
                                    
                                } placeholder: {
                                    ZStack{
                                        Color.revLabel
                                            .frame(height: 280)
                                        ProgressView()
                                    }
                                        
                                }.frame(width: UIScreen.main.bounds.width - 40)
                                    .cornerRadius(15)
                            }else if spotImage == UIImage(){
                                Color(UIColor.systemGray4).cornerRadius(10).frame(height: 120)
                                if isSaving {
                                    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(.red).padding(2)
                                }
                            }else {
                                Image(uiImage: self.spotImage)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            }
                        }
                    }
                    Button {
                        isSaving = true

                        if !is24 {
                            if week.filter({$0.isAvailable}).isEmpty {
                                is24 = true
                            } else {
                                for day in week.filter({$0.isAvailable}) {
                                    availabilityRange.append(AvailabilityRange(day: day.name, startDate: day.timeStart, endDate: day.timeFinish))
                                }
                            }
                        }

                        if !street.isEmpty && !city.isEmpty && !state.isEmpty && !zipcode.isEmpty && !notes.isEmpty && !price.isEmpty && !price2.isEmpty && !imageURL.isEmpty  {
                            spotVM.isLoading = true
                            converAddressToCoordinates(address: "\(street), \(city), \(zipcode)", completion: { (placemarks, error) in
                                guard
                                    let placemarks = placemarks,
                                    let location = placemarks.first?.location
                                else {
                                    print("error \(error!)")
                                    return
                                }
                                spotVM.updateSpot(spot: Spot(image: imageURL, licenseImage: spot.licenseImage, location: Location(street: street, city: city, state: state, zip_code: zipcode), convertedLocation: location, availabilityRange: availabilityRange, price: Double("\(helper.price).\(helper.price2)") ?? 0.0, notes: notes, isAvailable: isAvailable, ownerID: spot.ownerID, sid: spot.sid, isApproved: spot.isApproved, isHidden: spot.isHidden)) { error in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                    }else{
                                        dismiss()
                                        spotVM.isLoading = false
                                    }
                                }
                            })
                        }else{
                            print("Coś jest puste")
                        }
                    } label: {
                        Text("SAVE")
                            .foregroundColor(.revLabel)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.vertical, 20)
                            .padding(.horizontal, 80)
                            .background(Color("CustomGreen").cornerRadius(20))
                            .padding(20)
                    }.disabled(spotVM.isLoading)
                }
                
            }.padding(20)
        }.onAppear {
            for w in week.indices {
                
                if !spot.availabilityRange.contains(where: {$0.day == week[w].name}) {
                    week[w].isAvailable = false
                }else{
                    let found = spot.availabilityRange.first(where: {$0.day == week[w].name})
                    week[w].isAvailable = true
                    week[w].timeStart = found?.startDate ?? Date()
                    week[w].timeFinish = found?.endDate ?? Date()
                }
                
            }
        }
        
//        .onAppear {
//            var startComp = DateComponents()
//            startComp.year = 2030
//            startComp.hour = 9
//            var finishComp = DateComponents()
//            finishComp.year = 2030
//            finishComp.hour = 17
//            let startDate = Calendar.current.date(from: startComp)
//            let finishDate = Calendar.current.date(from: finishComp)
//
//            for range in spot.availabilityRange {
//                if range.day == week[idx].name {
//                    week[idx].isAvailable = true
//                    week[idx].timeStart = range.startDate
//                    week[idx].timeFinish = range.endDate
//                }else{
//                    week[idx].timeStart = startDate!
//                    week[idx].timeFinish = finishDate!
//                }
//            }
//        }
        
        .navigationTitle("Edit Listing")
            .background(Color(UIColor.systemGray6))
            .sheet(isPresented: $showSheet) {
                VStack{
                    Spacer()
                    Button {
                        showSheet = false
                        showCamera = true
                    } label: {
                        Text("Camera")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    Button {
                        showSheet = false
                        showLibrary = true
                    } label: {
                        Text("Photo Library")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    Spacer()
                    
                } .presentationDetents([.fraction(0.2)])
            }
            .sheet(isPresented: $showLibrary, onDismiss: {
                imageURL = ""
            }) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $spotImage)
            }
            .onAppear {
                street = spot.location.street
                city = spot.location.city
                state = spot.location.state
                zipcode = spot.location.zip_code
                notes = spot.notes
                helper.price = "\("\(spot.price)".components(separatedBy: ".").first ?? "")"
                price = "\("\(spot.price)".components(separatedBy: ".").first ?? "")"
                helper.price2 = "\("\(spot.price)".components(separatedBy: ".").last ?? "")"
                price2 = "\("\(spot.price)".components(separatedBy: ".").last ?? "")"
                isAvailable = spot.isAvailable
                imageURL = spot.image
                if spot.availabilityRange.filter({$0.day != ""}).isEmpty {
                    is24 = true
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
            
            
        }
    }
    
    func converAddressToCoordinates(address: String, completion: @escaping CLGeocodeCompletionHandler){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: completion)
    }
}

//struct EditListingView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditListingView().preferredColorScheme(.dark)
//    }
//}
