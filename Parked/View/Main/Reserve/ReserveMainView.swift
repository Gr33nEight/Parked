//
//  NewReserveMainView.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI
import MapKit

struct ReserveMainView: View {
    @State var startingDate = Date()
    @State var endingDate = Date().addingTimeInterval(3600)
    @State var searched = false
    @State var showCalendar = false
    @State var previousSearch = ""
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var spotsVM: SpotsViewModel
    @EnvironmentObject var reservationVM: ReservationsViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var searchedPin = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
    @State var clickedPin: Spot?
    @State var filteredPins = [Spot]()
    @State var showAlert = false
    @State var pickedReservation: Reservation?
    @State var clickedReservation: Reservation?
    
    var body: some View {
        ZStack(alignment: .top){
            Map(coordinateRegion: $searchedPin, annotationItems: filteredPins, annotationContent: { spot in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: spot.convertedLocation.coordinate.latitude, longitude: spot.convertedLocation.coordinate.longitude)) {
                    ZStack {
                        if spot.image == "mine" {
                            Circle()
                                .fill(.blue)
                                .frame(width: 35)
                        }else{
                            if spot.isApproved || !spot.isHidden {
                                Button(action: {
                                    let newSpot = Spot(image: spot.image, licenseImage: spot.licenseImage, location: spot.location, convertedLocation: spot.convertedLocation, availabilityRange: spot.availabilityRange, price: spot.price, notes: spot.notes, isAvailable: isAvailable(spot: spot), ownerID: spot.ownerID, sid: spot.sid, isApproved: spot.isApproved, isHidden: spot.isHidden)
                                    if spot.isAvailable {
                                        DispatchQueue.main.async {
                                            clickedPin = newSpot
                                        }
                                    }else{
                                        withAnimation {
                                            showAlert = true
                                            DispatchQueue.main.async {
                                                for i in reservationVM.reservations {
                                                    if i.spot.sid == newSpot.sid {
                                                        pickedReservation = i
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }, label: {
                                    CustomPointer(amount: spot.price, isAvailable: isAvailable(spot: spot))
                                })
                            }
                        }
                    }
                    .scaleEffect(0.25)
                }}).ignoresSafeArea()
            HStack{
                customTextField(corners: .allCorners)
                
                Button {
                    self.loadCurrentLocation()
                } label: {
                    Image(systemName: "paperplane")
                        .foregroundColor(Color(UIColor.label))
                }
                
                Button {
                    showCalendar.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(UIColor.label))
                        .padding(15)
                }
                
            }.overlay(
                ZStack{
                    if locationService.queryFragment != previousSearch && !showCalendar {
                        VStack(spacing: 0) {
                            HStack{
                                customTextField(corners: [.topLeft, .topRight, .bottomLeft])
                                Button {
                                    self.loadCurrentLocation()
                                } label: {
                                    Image(systemName: "paperplane")
                                        .foregroundColor(Color(UIColor.label))
                                }
                                Button {
                                    withAnimation {
                                        showCalendar.toggle()
                                    }
                                } label: {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(UIColor.label))
                                        .padding(15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.revLabel)
                                        )
                                }
                            }
                            VStack {
                                Group { () -> AnyView in
                                    switch locationService.status {
                                    case .noResults: return AnyView(
                                        HStack{
                                            Text("No Results!")
                                                .foregroundColor(Color(UIColor.label))
                                                .padding(.bottom, 20)
                                            Spacer()
                                        }.padding(.horizontal, 20)
                                            .padding(.top, 5)
                                    )
                                    case .error(let description): return AnyView(
                                        HStack{
                                            Text("Error: \(description)")
                                                .foregroundColor(Color(UIColor.label))
                                                .padding(.bottom, 20)
                                            Spacer()
                                        }.padding(.horizontal, 20)
                                            .padding(.top, 5)
                                    )
                                    default: return AnyView(EmptyView())
                                    }
                                }.foregroundColor(Color.gray)
                                
                                ForEach(locationService.searchResults, id: \.self) { completionResult in
                                    VStack(spacing: 20){
                                        HStack{
                                            Button {
                                                converAddressToCoordinates(address: completionResult.title)
                                            } label: {
                                                Text(completionResult.title)
                                            }.foregroundColor(.green)
                                            Spacer()
                                        }
                                        Divider()
                                    }.padding(.horizontal, 20)
                                        .padding(.top, 5)
                                }
                            }
                        }.background(Color.revLabel.cornerRadius(20, corners: [.allCorners]))
                    }
                    if showCalendar {
                        VStack{
                            VStack {
                                HStack{
                                    customTextField(corners: [.topLeft, .topRight])
                                    Button {
                                        self.loadCurrentLocation()
                                    } label: {
                                        Image(systemName: "paperplane")
                                            .foregroundColor(Color(UIColor.label))
                                    }
                                    Button {
                                        showCalendar.toggle()
                                    } label: {
                                        Image(systemName: "calendar")
                                            .foregroundColor(Color(UIColor.label))
                                            .padding(15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.revLabel)
                                            )
                                    }
                                }
                                VStack{
                                    HStack{
                                        Text("Start date:").fixedSize(horizontal: false, vertical: true)
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                        VStack(alignment: .trailing){
                                            DatePicker("label", selection: $startingDate, displayedComponents: [.date])
                                                .datePickerStyle(CompactDatePickerStyle())
                                                .labelsHidden()
                                            DatePicker("label", selection: $startingDate, displayedComponents: [.hourAndMinute])
                                                .datePickerStyle(CompactDatePickerStyle())
                                                .labelsHidden()
                                        }
                                    }.padding(.bottom)
                                    HStack {
                                        Text("End date:").fixedSize(horizontal: false, vertical: true)
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                        VStack(alignment: .trailing){
                                            DatePicker("label", selection: $endingDate, in: Date()... ,displayedComponents: [.date])
                                                .datePickerStyle(CompactDatePickerStyle())
                                                .labelsHidden()
                                            DatePicker("label", selection: $endingDate, in: Date()..., displayedComponents: [.hourAndMinute])
                                                .datePickerStyle(CompactDatePickerStyle())
                                                .labelsHidden()
                                        }
                                    }
                                    
                                    Button {
                                        userVM.currentUser?.frameRange = DateRange(startDate: startingDate, endDate: endingDate)
                                        searchPin()
                                        showCalendar = false
                                    } label: {
                                        Text("Search")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 50)
                                            .padding(.vertical, 15)
                                            .background(RoundedRectangle(cornerRadius: 15).fill(Color("CustomGreen")))
                                    }

                                }.padding(20)
                                    .onChange(of: startingDate) { newValue in
                                        if newValue > endingDate {
                                            endingDate = newValue
                                            print("to tez")
                                        }
                                    }
                                    .onChange(of: endingDate) { newValue in
                                        if newValue < startingDate {
                                            startingDate = newValue
                                            print("nie powinno sie wypisać")
                                        }
                                    }
                            }
                        }.background(Color.revLabel.cornerRadius(20, corners: [.allCorners]))
                    }
                }, alignment: .top
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.revLabel)
            )
            .padding(15)
            .padding(.horizontal, 15)
        }.onAppear{
            //            convertAdrToCdr()
            loadCurrentLocation()
            filteredPins = spotsVM.allSpots
            searchPin()
        }
        
        .onChange(of: locationService.locationStatus) { newValue in
            if newValue == .authorizedAlways || newValue == .authorizedWhenInUse || newValue == .restricted {
                loadCurrentLocationAfter()
            }
        }
        .fullScreenCover(item: $clickedPin) { pin in
            PinView(spot: pin, isReservationPage: true)
        }
        .overlay(
            ZStack{
                if showAlert {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20){
                        Text("This spot is will be reserved until: ")
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if let pickedReservation = pickedReservation {
                            Text("\(pickedReservation.frameRange.endDateString), \(pickedReservation.frameRange.endTimeString)")
                                .font(.system(size: 25, weight: .bold))
                        }
                    }.padding(30)
                        .overlay(
                            Button(action: {
                                showAlert = false
                                pickedReservation = nil
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
        )
    }
    @ViewBuilder
    func customTextField(corners: UIRectCorner) -> some View {
        HStack{
            Image(systemName: "magnifyingglass")
            ZStack(alignment: .leading){
                if locationService.queryFragment.isEmpty {
                    Text("Search...")
                }
                TextField("", text: $locationService.queryFragment)
                    .foregroundColor(Color(UIColor.label))
            }.foregroundColor(Color(UIColor.systemGray3))
            Spacer()
            if locationService.status == .isSearching {
                ProgressView()
            }
        }.padding(15)
            .background()
            .cornerRadius(20, corners: corners)
    }
    
    func converAddressToCoordinates(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
            }else{
                searchedPin = MKCoordinateRegion(center: placemarks?.first?.location?.coordinate ?? CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                withAnimation {
                    locationService.queryFragment = address
                    previousSearch = locationService.queryFragment
                }
                
            }
        }
    }
    func loadCurrentLocation() {
        DispatchQueue.main.async {
            if locationService.locationStatus == .authorizedWhenInUse || locationService.locationStatus == .authorizedAlways || locationService.locationStatus == .restricted {
                searchedPin = MKCoordinateRegion(center: locationService.lastLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
            }else{
                print(locationService.statusString)
            }
        }
    }
    func loadCurrentLocationAfter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if locationService.lastLocation?.coordinate != nil {
                searchedPin = MKCoordinateRegion(center: locationService.lastLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
            }else{
                print(locationService.statusString)
            }
        }
    }
    func searchPin() {
        var filtered = [Spot]()
        var startingDayName = ""
        var endingDayName = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en")
        startingDayName = dateFormatter.string(from: startingDate)
        endingDayName = dateFormatter.string(from: endingDate)
        
        for i in spotsVM.allSpots {
            for j in i.availabilityRange {
                if i.availabilityRange.count == 1 && i.availabilityRange.first!.day == "" {
                   filtered.append(i)
                }else if startingDayName == j.day || endingDayName == j.day {
                    if (convertIntoTime(j.startDate)...convertIntoTime(j.endDate)).contains(convertIntoTime(startingDate)) && (convertIntoTime(j.startDate)...convertIntoTime(j.endDate)).contains(convertIntoTime(startingDate)) {
                        filtered.append(i)
                    }

                }
            }
        }
        
        filteredPins = filtered
    }
    
    
    func isAvailable(spot: Spot) -> Bool {
            if reservationVM.allReservations.contains(where: {$0.spot.sid == spot.sid}) {
                let frameRange = reservationVM.allReservations.first(where: {$0.spot.sid == spot.sid})!.frameRange
                if (startingDate < frameRange.startDate && endingDate < frameRange.endDate) || startingDate > frameRange.endDate {
                    print("Cheker 2")
                    return true
                }else{
                    print("Cheker 3")
                    return false
                }
            }else{
                print("Cheker 5")
                return true
            }
        }
    func convertIntoTime(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        return Calendar.current.date(from: components)!
    }
}

struct NewReserveMainView_Previews: PreviewProvider {
    static var previews: some View {
        ReserveMainView()
            .environmentObject(LocationService())
            .preferredColorScheme(.dark)
    }
}
