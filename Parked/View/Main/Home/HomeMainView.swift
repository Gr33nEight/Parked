//
//  NewHomeMainView.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI
import MapKit

struct HomeMainView: View {
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var spotsVM: SpotsViewModel
    @EnvironmentObject var bottomBarVM: BottomBarViewModel
    @EnvironmentObject var reservationVM: ReservationsViewModel
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.1095348, longitude: 18.4091847), span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
    @State var showSheet = false
    @State var sortedNearby = [Spot]()
    @State var showPinView = false
    @State var showUpcoming = false
    @State var showAlert = false
    @State var clickedSpot: Spot?
    @State var pickedReservation: Reservation?
    @State var clickedReservation: Reservation?
    @State var filteredPins = [Spot]()
    
    var body: some View {
        VStack{
            Map(coordinateRegion: $region, annotationItems: filteredPins, annotationContent: { spot in
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
                                    if isAvailable(spot: spot) {
                                        DispatchQueue.main.async {
                                            clickedSpot = newSpot
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
                }
                
            }).edgesIgnoringSafeArea(.top)
            BottomSheetView(isOpen: $showSheet, maxHeight: UIScreen.main.bounds.height - 80) {
                VStack(spacing: 10){
                    HStack{
                        if let user = userVM.currentUser {
                            Text("Welcome \(user.fullname)")
                                .font(.largeTitle)
                                .bold()
                        }
                        Spacer()
                    }
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20){
                            HStack{
                                Text("Nearby")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            if sortedNearby.count > 1 {
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack{
                                        if locationService.lastLocation?.coordinate != nil {
                                            ForEach(Array(zip(sortedNearby.prefix(6), sortedNearby.prefix(6).indices)), id:\.0){ spot, i in
                                                if spot.image != "mine" && spot.isApproved {
                                                    Button {
                                                        DispatchQueue.main.async {
                                                            clickedSpot = spot
                                                        }
                                                    } label: {
                                                        nearbyCell(spot: spot, i: i)
                                                    }.onAppear {
                                                        print(spot.isApproved)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                HStack{
                                    Spacer()
                                    Text("There isn't any spot nearby.")
                                        .font(.system(size: 17, weight: .semibold))
                                        .padding(30)
                                    Spacer()
                                }
                            }
                            Button {
                                bottomBarVM.pickedOption = .reservations
                            } label: {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green)
                                    Text("Save Your Spot")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 18)
                                }
                            }.padding(.vertical, 2)
                                .padding(.top, 5)
                            
                            HStack{
                                Text("Active")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            if !reservationVM.reservations.filter({$0.frameRange.startDate < $0.frameRange.endDate}).filter({$0.frameRange.startDate...$0.frameRange.endDate ~= Date()}).isEmpty {
                                ScrollView(.vertical, showsIndicators: false){
                                    LazyVStack {
                                        ForEach(reservationVM.reservations.filter({$0.frameRange.startDate < $0.frameRange.endDate}).filter({$0.frameRange.startDate...$0.frameRange.endDate ~= Date()})) { reservation in
                                            Button {
                                                clickedReservation = reservation
                                            } label: {
                                                ReservationCell(reservation: reservation, color: .accentColor)
                                            }.onDisappear {
                                                if reservation.frameRange.endDate < Date() {
                                                    reservationVM.deleteReservation(reservationID: reservation.reservationID ?? "") { error in
                                                        if let error = error {
                                                            print("Error: \(error.localizedDescription)")
                                                        } else {
                                                            spotsVM.setSpotAvailability(for: true, spotID: reservation.spot.sid)
                                                            if !userVM.reservationHistory.contains(where: {$0.frameRange == reservation.frameRange}) {
                                                                userVM.addResrvationToHistory(reservation: reservation) { error in
                                                                    if let error = error {
                                                                        print("Error: \(error.localizedDescription)")
                                                                    }else{
                                                                        print("działa")
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                HStack{
                                    Spacer()
                                    Text("You don't have any active reservations.")
                                        .font(.system(size: 17, weight: .semibold))
                                        .multilineTextAlignment(.center)
                                        .padding(30)
                                    Spacer()
                                }
                            }
                            
                            HStack{
                                Text("Upcoming")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            if !reservationVM.reservations.filter({$0.frameRange.endDate > Date()}).filter({!($0.frameRange.startDate...$0.frameRange.endDate).contains(Date())}).isEmpty {
                                ScrollView(.vertical, showsIndicators: false){
                                    LazyVStack {
                                        ForEach(reservationVM.reservations.filter({$0.frameRange.endDate > Date()}).filter({!($0.frameRange.startDate...$0.frameRange.endDate).contains(Date())})) { reservation in
                                            Button {
                                                clickedReservation = reservation
                                            } label: {
                                                ReservationCell(reservation: reservation, color: .accentColor.opacity(0.3))
                                            }
                                            
                                        }
                                    }
                                }
                            }else{
                                HStack{
                                    Spacer()
                                    Text("You don't have any upcoming reservations.")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 17, weight: .semibold))
                                        .padding(30)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                }.padding(.top, showSheet ? 20 : 0)
                    .padding(20)
                    .background(Color(UIColor.systemGray6))
                    .onAppear{
                        loadCurrentLocation()
                        sortNearby()
                    }
                
                    .onChange(of: locationService.locationStatus) { newValue in
                        if newValue == .authorizedAlways || newValue == .authorizedWhenInUse || newValue == .restricted {
                            loadCurrentLocationAfter()
                            sortNearby()
                        }
                    }
            }
        }.onAppear{
            loadCurrentLocation()
            sortNearby()
            filterPins()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for reservation in reservationVM.allReservations {
                    if reservation.frameRange.endDate < Date().addingTimeInterval(900) {
                        reservationVM.deleteReservation(reservationID: reservation.reservationID ?? "") { error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                            } else {
                                spotsVM.setSpotAvailability(for: true, spotID: reservation.spot.sid)
                                if !userVM.reservationHistory.contains(where: {$0.frameRange == reservation.frameRange}) {
                                    userVM.addResrvationToHistory(reservation: reservation) { error in
                                        if let error = error {
                                            print("Error: \(error.localizedDescription)")
                                        }else{
                                            print("works")
                                        }
                                    }
                                }
                            }
                        }
                    } 
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                reservationVM.fetchAllReservations()
                if !reservationVM.allReservations.isEmpty {
                    for spot in spotsVM.allSpots {
                        if spot.sid != "" {
                            if reservationVM.allReservations.contains(where: {
                                return $0.spot.sid == spot.sid}){
                                spotsVM.setSpotAvailability(for: false, spotID: spot.sid)
                            } else {
                                spotsVM.setSpotAvailability(for: true, spotID: spot.sid)
                            }
                        }
                    }
                }else{
                    for spot in spotsVM.allSpots {
                        if spot.sid != "" {
                            spotsVM.setSpotAvailability(for: true, spotID: spot.sid)
                        }
                    }
                }
            }
            
        }
        
        .onChange(of: locationService.locationStatus) { newValue in
            if newValue == .authorizedAlways || newValue == .authorizedWhenInUse || newValue == .restricted {
                loadCurrentLocationAfter()
                sortNearby()
            }
        }
        .onChange(of: spotsVM.allSpots, perform: { _ in
            self.filterPins()
            self.sortNearby()
        })
        
        .fullScreenCover(item: $clickedSpot) { spot in
            PinView(spot: spot, isReservationPage: false)
        }
        .fullScreenCover(item: $clickedReservation) { reservation in
            UpcomingView(reservation: reservation, isActive: (reservation.frameRange.startDate...reservation.frameRange.endDate ~= Date()))
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
    func nearbyCell(spot: Spot, i: Int) -> some View {
        HStack{
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: 35, height: 35)
                Text("\(i)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading){
                Text(spot.location.street)
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 15, weight: .semibold))
                VStack(alignment: .leading){
                    Text(spot.location.city)
                    Text("Available\(availabilityChecker(spot:spot) == "Today" ? "" : " until"): \(availabilityChecker(spot:spot))")
                    HStack{
                        if locationService.lastLocation?.coordinate != nil {
                            if locationService.lastLocation!.distance(from: spot.convertedLocation) < 1000 {
                                Text("\(Measurement(value: locationService.lastLocation!.distance(from: spot.convertedLocation) , unit: .meters).converted(to: UnitLength.meters).value, specifier: "%.2f") m")
                            }else {
                                Text("\(Measurement(value: locationService.lastLocation!.distance(from: spot.convertedLocation) , unit: .meters).converted(to: UnitLength.kilometers).value, specifier: "%.2f") km")
                            }
                        }
                        Spacer()
                        Text("$\(spot.price, specifier: "%.2f")/hr")
                            .foregroundColor(.green)
                    }
                } .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(UIColor.systemGray2))
            }
        }.padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.revLabel)
            )
        
    }
  
    func filterPins() {
        let startingDate = Date()
        let endingDate = Date().addingTimeInterval(14400)
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
    
    func convertIntoTime(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        return Calendar.current.date(from: components)!
    }
    
    func sortNearby() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if locationService.lastLocation?.coordinate != nil {
                sortedNearby = filteredPins.filter({$0.isAvailable}).filter({$0.isApproved}).filter({!$0.isHidden}).sorted(by: {
                    (locationService.lastLocation!.distance(from: $0.convertedLocation)) < (locationService.lastLocation!.distance(from: $1.convertedLocation))
                })
            }
        }
    }
    func loadCurrentLocation() {
        DispatchQueue.main.async {
            if locationService.locationStatus == .authorizedWhenInUse || locationService.locationStatus == .authorizedAlways || locationService.locationStatus == .restricted {
                region = MKCoordinateRegion(center: locationService.lastLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                if spotsVM.allSpots.contains(where: {$0.image == "mine"}){
                }else{
                    spotsVM.allSpots.append(Spot(image: "mine", licenseImage: "", location: Location(street: "", city: "", state: "", zip_code: ""), convertedLocation: locationService.lastLocation!, availabilityRange: [AvailabilityRange(day: "", startDate: Date(), endDate: Date())], price: 0.0, notes: "", isAvailable: true, ownerID: "", sid: "", isApproved: true, isHidden: false))
                }
            }else{
                print(locationService.statusString)
            }
        }
    }
    func loadCurrentLocationAfter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if locationService.lastLocation?.coordinate != nil {
                region = MKCoordinateRegion(center: locationService.lastLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                if spotsVM.allSpots.contains(where: {$0.image == "mine"}){
                }else{
                    spotsVM.allSpots.append(Spot(image: "mine", licenseImage: "", location: Location(street: "", city: "", state: "", zip_code: ""), convertedLocation: locationService.lastLocation!, availabilityRange: [AvailabilityRange(day: "", startDate: Date(), endDate: Date())], price: 0.0, notes: "", isAvailable: true, ownerID: "", sid: "", isApproved: true, isHidden:false))
                }
            }else{
                print(locationService.statusString)
            }
        }
    }
    func isAvailable(spot: Spot) -> Bool {

            if reservationVM.allReservations.contains(where: {$0.spot.sid == spot.sid}) {
                let frameRange = reservationVM.allReservations.first(where: {$0.spot.sid == spot.sid})!.frameRange
                if (Date() < frameRange.startDate && Date().addingTimeInterval(14400) < frameRange.endDate) || Date() > frameRange.endDate {
                    return true
                }else{
                    return false
                }
            }else{
                return true
            }
        
    }
    func availabilityChecker(spot: Spot) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en")
        let today = dateFormatter.string(from: Date())
        
        if reservationVM.allReservations.contains(where: {$0.spot.sid == spot.sid}) {
            return reservationVM.allReservations.first(where: {$0.spot.sid == spot.sid})?.frameRange.startDate.addingTimeInterval(-900).formatted(date: .omitted, time: .shortened) ?? "error"
        }else{
            if spot.availabilityRange.filter({$0.day != ""}).isEmpty {
                return "Today"
            }else{
                for day in spot.availabilityRange {
                    if day.day == today {
                        return day.endDate.addingTimeInterval(-900).formatted(date: .omitted, time: .shortened)
                    }else {
                        return "from \((spot.availabilityRange.first(where: {$0.day != ""})?.day)?.capitalized ?? "error")"
                    }
                }
            }
        }
        return ""
    }
}


extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

struct NewHomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}
