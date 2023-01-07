//
//  UserViewModel.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {

    @Published var userSession: Firebase.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var userSpots = [Spot]()
    @Published var reservationHistory = [Reservation]()
    @Published var bookingHistory = [Reservation]()
    @Published var spotVM = SpotsViewModel()
    
    var isLoggedIn: Bool {
        return userSession != nil
    }
    
    var usersDB = Firestore.firestore().collection("users")
    var auth = Auth.auth()
    
    init() {
        userSession = Auth.auth().currentUser
        self.fetchUser()
        self.fetchUserSpots()
        self.fetchReservationHistory()
        self.fetchBookingHistory()
    }
    
    func fetchUser() {
        guard let uid = userSession?.uid else {
            self.isLoading = false
            return
        }
        self.isLoading = true
        usersDB.document(uid).getDocument { doc, error in
            if let error = error {
                print("Error \(error.localizedDescription)")
                self.isLoading = false
            } else {
                if let doc = doc, doc.exists {
                    let uid = doc.data()?["uid"] as? String
                    let fullname = doc.data()?["fullname"] as? String
                    let email = doc.data()?["email"] as? String
                    let phoneNumber = doc.data()?["phoneNumber"] as? String
                    let make = doc.data()?["make"] as? String
                    let model = doc.data()?["model"] as? String
                    let color = doc.data()?["color"] as? String
                    
                    self.currentUser = User(fullname: fullname ?? "error", email: email ?? "", phoneNumber: phoneNumber ?? "", uid: uid, car: Car(make: make ?? "error", model: model ?? "error", color: color ?? "error"))
                    self.isLoading = false
                }else {
                    self.isLoading = false
                    self.userSession = nil
                    
                }
            }
            
        }
    }
    
    func logIn(email: String, password: String, completion: @escaping () -> Void){
        self.isLoading = true
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.isLoading = false
                print("Error: \(error.localizedDescription)")
            } else {
                switch result {
                case .none:
                    print("Some error occured")
                    self.isLoading = false
                case .some(_):
                    guard let user = result?.user else {return}
                    self.userSession = user
                    self.fetchUser()
                    self.isLoading = false
                    completion()
                }
            }
        }
    }
    
    func signUp(email: String, password: String, fullname: String, phoneNumber: String, car: Car ,completion: @escaping () -> Void){
        isLoading = true
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }else{
                guard let user = result?.user else { return }
                self.addUser(uid: user.uid, fullname: fullname, email: email, phoneNumber: phoneNumber, car: car) { error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }else{
                        self.userSession = user
                        self.fetchUser()
                        self.isLoading = false
                        completion()
                    }
                }
            }
        }
    }
    
    func addUser(uid: String, fullname: String, email: String, phoneNumber: String, car: Car, completion: ((Error?) -> Void)?) {
        
        let data = [
            "uid" : uid,
            "fullname" : fullname,
            "email" : email,
            "phoneNumber": phoneNumber,
            "make": car.make,
            "model": car.model,
            "color": car.color
        ]
        
        usersDB.document(uid).setData(data, completion: completion)
    }
    
    func upadateUserInfo(uid: String, fullname: String, email: String, phoneNumber: String, car: Car, completion: ((Error?) -> Void)?){
        let data = [
            "uid" : uid,
            "fullname" : fullname,
            "email" : email,
            "phoneNumber": phoneNumber,
            "make": car.make,
            "model": car.model,
            "color": car.color
        ]
        
        usersDB.document(uid).setData(data, merge: true, completion: completion)
    }
    
    func logOut() {
        self.userSession = nil
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: ", signOutError)
        }
    }

    func addSpot(spot: Spot, sid: String, completion: ((Error?) -> Void)?) {
        guard let uid = userSession?.uid else { return }
        let tempSpot = Spot(image: spot.image, licenseImage: spot.licenseImage, location: spot.location, convertedLocation: spot.convertedLocation, availabilityRange: spot.availabilityRange, price: spot.price, notes: spot.notes, isAvailable: spot.isAvailable, ownerID: currentUser?.uid ?? "", sid: sid, isApproved: false, isHidden: spot.isHidden)
        var availabilityRangeArray = [[:]]
        for i in tempSpot.availabilityRange {
            availabilityRangeArray.append([
                "day": i.day,
                "startDate" : Timestamp(date: i.startDate),
                "endDate" : Timestamp(date: i.endDate)
            ])
        }
        
        let data = [
            "id" : tempSpot.id.uuidString,
            "sid": tempSpot.id.uuidString,
            "image" : tempSpot.image,
            "licenseImage" : tempSpot.licenseImage,
            "location" : [
                "street" : tempSpot.location.street,
                "city" : tempSpot.location.city,
                "state" : tempSpot.location.state,
                "zipcode" : tempSpot.location.zip_code
            ],
            "address" : tempSpot.address,
            "convertedLocation" : GeoPoint(latitude: tempSpot.convertedLocation.coordinate.latitude, longitude: tempSpot.convertedLocation.coordinate.longitude),
            "availabilityRange": availabilityRangeArray,
            "price" : tempSpot.price,
            "notes" : tempSpot.notes,
            "isAvailable" : tempSpot.isAvailable,
            "ownerID": tempSpot.ownerID,
            "isApproved": false
        ] as Any
        
//        usersDB.document(uid)setData(["userSpots" : [data]], mergeFields: ["userSpots"])

        usersDB.document(uid).updateData(["userSpots" : FieldValue.arrayUnion([data])], completion: completion)
    }
    
    func fetchUserSpots() {
        guard let uid = userSession?.uid else { return }
        usersDB.document(uid).getDocument { doc, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                let user = doc?.data() as? [String : Any] ?? [:]
                let spots = user["userSpots"] as? [[String : Any]]
                if let spots = spots {
                    var temp = [Spot]()
                    for spot in spots {
                        let location = spot["location"] as? [String : Any] ?? [:]
                        let availabilityRange = spot["availabilityRange"] as? [[String : Any]] ?? [[:]]
                        
                        /// spot
                        let sid = spot["sid"] as? String ?? ""
                        let image = spot["image"] as? String ?? ""
                        let licenseImage = spot["licenseImage"] as? String ?? ""
                        let notes = spot["notes"] as? String ?? ""
                        let price = spot["price"] as? Double ?? 0.0
                        let isAvailable = spot["isAvailable"] as? Bool ?? false
                        let ownerID = spot["ownerID"] as? String ?? ""
                        let isApproved = spot["isApproved"] as? Bool ?? false
                        let isHidden = spot["isHidden"] as? Bool ?? false
                        
                        /// convertedLocation
                        let latitude = (spot["convertedLocation"] as? GeoPoint)?.latitude ?? 0.0
                        let longitude = (spot["convertedLocation"] as? GeoPoint)?.longitude ?? 0.0
                        let convertedLocation = CLLocation(latitude: latitude, longitude: longitude)
                        
                        /// location
                        let street = location["street"] as? String ?? ""
                        let city = location["city"] as? String ?? ""
                        let state = location["state"] as? String ?? ""
                        let zipcode = location["zipcode"] as? String ?? ""
                        let locationFinal = Location(street: street, city: city, state: state, zip_code: zipcode)
                        
                        /// availabilityRange
                        var availabilityRangeArray = [AvailabilityRange]()
                        for i in availabilityRange {
                            let startDate = (i["startDate"] as? Timestamp)?.dateValue() ?? Date()
                            let endDate = (i["endDate"] as? Timestamp)?.dateValue() ?? Date()
                            let day = i["day"] as? String ?? ""
                            availabilityRangeArray.append(AvailabilityRange(day: day, startDate: startDate, endDate: endDate))
                        }
                        let availabilityRangeFinal = availabilityRangeArray
                        
    
                        let spot = Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: ownerID, sid: sid, isApproved: false, isHidden: isHidden)
                        
                        temp.append(spot)
                    }
                    self.userSpots = temp
                    self.userSpots = self.userSpots.filter({$0.notes != ""})
                }
                
            }
        }
    }
    
    func addResrvationToHistory(reservation: Reservation, completion: ((Error?) -> Void)?) {
        guard let uid = userSession?.uid else { return }
        var availabilityRangeArray = [[:]]
        for i in reservation.spot.availabilityRange {
            availabilityRangeArray.append([
                "day": i.day,
                "startDate" : Timestamp(date: i.startDate),
                "endDate" : Timestamp(date: i.endDate)
            ])
        }
        
        let data = [
            "id" : reservation.reservationID ?? "",
            "sid": reservation.spot.sid,
            "image" : reservation.spot.image,
            "licenseImage" : reservation.spot.licenseImage,
            "location" : [
                "street" : reservation.spot.location.street,
                "city" : reservation.spot.location.city,
                "state" : reservation.spot.location.state,
                "zipcode" : reservation.spot.location.zip_code
            ],
            "address" : reservation.spot.address,
            "convertedLocation" : GeoPoint(latitude: reservation.spot.convertedLocation.coordinate.latitude, longitude: reservation.spot.convertedLocation.coordinate.longitude),
            "availabilityRange": availabilityRangeArray,
            "price" : reservation.spot.price,
            "notes" : reservation.spot.notes,
            "isAvailable" : reservation.spot.isAvailable,
            "frameRange": [
                "startDate" : Timestamp(date: reservation.frameRange.startDate),
                "endDate" : Timestamp(date: reservation.frameRange.endDate)
            ],
            "name": reservation.name,
            "spotOwnerID": reservation.spot.ownerID,
            "bookingUserID": reservation.bookingUserID,
            "isApproved": reservation.spot.isApproved
        ] as Any
        
//        usersDB.document(uid)setData(["userSpots" : [data]], mergeFields: ["userSpots"])

        usersDB.document(reservation.spot.ownerID).updateData(["bookingHistory" : FieldValue.arrayUnion([data])], completion: completion)
        usersDB.document(reservation.bookingUserID).updateData(["reservationHistory" : FieldValue.arrayUnion([data])], completion: completion)
    }
    
    func fetchReservationHistory() {
        guard let uid = userSession?.uid else { return }
        usersDB.document(uid).getDocument { doc, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                let user = doc?.data() as? [String : Any] ?? [:]
                let reservation = user["reservationHistory"] as? [[String : Any]]
                if let reservations = reservation {
                    var temp = [Reservation]()
                    for reservation in reservations {
                        let location = reservation["location"] as? [String : Any] ?? [:]
                        let availabilityRange = reservation["availabilityRange"] as? [[String : Any]] ?? [[:]]
                        let frameRange = reservation["frameRange"] as? [String : Any] ?? [:]
                        
                        /// reservation
                        let id = reservation["id"] as? String ?? ""
                        let sid = reservation["sid"] as? String ?? ""
                        let image = reservation["image"] as? String ?? ""
                        let licenseImage = reservation["licenseImage"] as? String ?? ""
                        let notes = reservation["notes"] as? String ?? ""
                        let price = reservation["price"] as? Double ?? 0.0
                        let isAvailable = reservation["isAvailable"] as? Bool ?? false
                        let name = reservation["name"] as? String ?? ""
                        let spotOwnerID = reservation["spotOwnerID"] as? String ?? ""
                        let bookingUserID = reservation["bookingUserID"] as? String ?? ""
                        let isApproved = reservation["isApproved"] as? Bool ?? false
                        let isHidden = reservation["isHidden"] as? Bool ?? false
                        
                        /// convertedLocation
                        let latitude = (reservation["convertedLocation"] as? GeoPoint)?.latitude ?? 0.0
                        let longitude = (reservation["convertedLocation"] as? GeoPoint)?.longitude ?? 0.0
                        let convertedLocation = CLLocation(latitude: latitude, longitude: longitude)
                        
                        /// location
                        let street = location["street"] as? String ?? ""
                        let city = location["city"] as? String ?? ""
                        let state = location["state"] as? String ?? ""
                        let zipcode = location["zipcode"] as? String ?? ""
                        let locationFinal = Location(street: street, city: city, state: state, zip_code: zipcode)
                        
                        /// availabilityRange
                        var availabilityRangeArray = [AvailabilityRange]()
                        for i in availabilityRange {
                            let startDate = (i["startDate"] as? Timestamp)?.dateValue() ?? Date()
                            let endDate = (i["endDate"] as? Timestamp)?.dateValue() ?? Date()
                            let day = i["day"] as? String ?? ""
                            availabilityRangeArray.append(AvailabilityRange(day: day, startDate: startDate, endDate: endDate))
                        }
                        let availabilityRangeFinal = availabilityRangeArray
                        
                        /// frameRange
                        let startDateF = (frameRange["startDate"] as? Timestamp)?.dateValue() ?? Date()
                        let endDateF = (frameRange["endDate"] as? Timestamp)?.dateValue() ?? Date()
                        let frameRangeFinal = DateRange(startDate: startDateF, endDate: endDateF)
    
                        let reservation = Reservation(spot: Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: spotOwnerID, sid: sid, isApproved: isApproved, isHidden: isHidden), frameRange: frameRangeFinal, name: name, bookingUserID: bookingUserID, spotID: sid, reservationID: id)
                        temp.append(reservation)
                        Firestore.firestore().collection("users").document(bookingUserID).getDocument { doc, error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                            }else{
                                if let doc = doc, doc.exists {
                                    let fullname = doc.data()?["fullname"] as? String
                                    let email = doc.data()?["email"] as? String
                                    let phoneNumber = doc.data()?["phoneNumber"] as? String
                                    let make = doc.data()?["make"] as? String
                                    let model = doc.data()?["model"] as? String
                                    let color = doc.data()?["color"] as? String
                                    
                                    let user = User(fullname: fullname ?? "error", email: email ?? "", phoneNumber: phoneNumber ?? "", car: Car(make: make ?? "", model: model ?? "", color: color ?? ""))
                                    
                                    
                                    for i in self.bookingHistory.indices {
                                        if self.bookingHistory[i].reservationID == id {
                                            self.bookingHistory[i].renter = user
                                        }
                                    }
                                    
                                }else {
                                    print("Doesn't exist")
                                }
                            }
                        }
                    }
                    self.reservationHistory = temp
                    self.reservationHistory = self.reservationHistory.filter({$0.spot.notes != ""})
                }
                
            }
        }
    }
    func fetchBookingHistory() {
        guard let uid = userSession?.uid else { return }
        usersDB.document(uid).getDocument { doc, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                let user = doc?.data() as? [String : Any] ?? [:]
                let reservation = user["bookingHistory"] as? [[String : Any]]
                if let reservations = reservation {
                    var temp = [Reservation]()
                    for reservation in reservations {
                        let location = reservation["location"] as? [String : Any] ?? [:]
                        let availabilityRange = reservation["availabilityRange"] as? [[String : Any]] ?? [[:]]
                        let frameRange = reservation["frameRange"] as? [String : Any] ?? [:]
                        
                        /// reservation
                        let id = reservation["id"] as? String ?? ""
                        let sid = reservation["sid"] as? String ?? ""
                        let image = reservation["image"] as? String ?? ""
                        let licenseImage = reservation["licenseImage"] as? String ?? ""
                        let notes = reservation["notes"] as? String ?? ""
                        let price = reservation["price"] as? Double ?? 0.0
                        let isAvailable = reservation["isAvailable"] as? Bool ?? false
                        let name = reservation["name"] as? String ?? ""
                        let spotOwnerID = reservation["spotOwnerID"] as? String ?? ""
                        let bookingUserID = reservation["bookingUserID"] as? String ?? ""
                        let isApproved = reservation["isApproved"] as? Bool ?? false
                        let isHidden = reservation["isHidden"] as? Bool ?? false
                        
                        /// convertedLocation
                        let latitude = (reservation["convertedLocation"] as? GeoPoint)?.latitude ?? 0.0
                        let longitude = (reservation["convertedLocation"] as? GeoPoint)?.longitude ?? 0.0
                        let convertedLocation = CLLocation(latitude: latitude, longitude: longitude)
                        
                        /// location
                        let street = location["street"] as? String ?? ""
                        let city = location["city"] as? String ?? ""
                        let state = location["state"] as? String ?? ""
                        let zipcode = location["zipcode"] as? String ?? ""
                        let locationFinal = Location(street: street, city: city, state: state, zip_code: zipcode)
                        
                        /// availabilityRange
                        var availabilityRangeArray = [AvailabilityRange]()
                        for i in availabilityRange {
                            let startDate = (i["startDate"] as? Timestamp)?.dateValue() ?? Date()
                            let endDate = (i["endDate"] as? Timestamp)?.dateValue() ?? Date()
                            let day = i["day"] as? String ?? ""
                            availabilityRangeArray.append(AvailabilityRange(day: day, startDate: startDate, endDate: endDate))
                        }
                        let availabilityRangeFinal = availabilityRangeArray
                        
                        /// frameRange
                        let startDateF = (frameRange["startDate"] as? Timestamp)?.dateValue() ?? Date()
                        let endDateF = (frameRange["endDate"] as? Timestamp)?.dateValue() ?? Date()
                        let frameRangeFinal = DateRange(startDate: startDateF, endDate: endDateF)
    
                        let reservation = Reservation(spot: Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: spotOwnerID, sid: sid, isApproved: isApproved, isHidden: isHidden), frameRange: frameRangeFinal, name: name, bookingUserID: bookingUserID, spotID: sid, reservationID: id)
                        temp.append(reservation)
                        print(reservation)
                    }
                    self.bookingHistory = temp
                    self.bookingHistory = self.bookingHistory.filter({$0.spot.notes != ""})
                }
                
            }
        }
    }
}




/// User - name, surname, email, picture, userSpots : [Spot], reservations: [Spot]
/// All spots: [Spot]
///


//class AuthViewModel : ObservableObject {
//
//    @Published var currentUser : User?
//
//    static let shared = AuthViewModel()
//
//    init() {
//        userSession = Auth.auth().currentUser
//        fetchUser()
//        print(currentUser?.username ?? "aaaaaa")
//    }
//
//    func login(withEmail email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error{
//                print(error.localizedDescription)
//                return
//            }
//            guard let user = result?.user else {return}
//            self.userSession = user
//            self.fetchUser()
//        }
//    }
//
//    func register(withEmail email: String, password: String, username: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            guard let user = result?.user else {return}
//            let data = ["email" : email,
//                        "username" : username,
//                        "points": 1,
//                        "uid" : user.uid
//            ] as [String : Any]
//            Firestore.firestore().collection("users").document(user.uid).setData(data) { _ in
//                self.userSession = user
//                self.fetchUser()
//            }
//        }
//    }
//
//    func signout() {
//        self.userSession = nil
//        try? Auth.auth().signOut()
//    }
//
//    func fetchUser() {
//        guard let uid = userSession?.uid else {return}
//        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
//            if error == nil {
//                guard let user = try? snapshot?.data(as: User.self) else {return}
//                self.currentUser = user
//            }else {
//                if let error = error{
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    func addPoint(product: SKProduct) {
//        guard let boughtPoints = product.localizedTitle.parseToInt() else {return}
//        guard let uid = userSession?.uid else {return}
//
//        Firestore.firestore().collection("users").document(uid).updateData(["points" : FieldValue.increment(Int64(boughtPoints))])
//
//        fetchUser()
//    }
//
//    func removePoint() {
//        guard let uid = userSession?.uid else {return}
//
//        Firestore.firestore().collection("users").document(uid).updateData(["points" : FieldValue.increment(Int64(-1))])
//
//        fetchUser()
//    }
//}

//
//["7C2UjkcZEgUGIPzQPlVwinsotuy1reserved135CCD32-FF35-4106-9E3B-16FC00613EAC": {
//    address = "\U015awi\U0119tego J\U00f3zefa 42, Rybnik, 44-200";
//    availabilityRange =     {
//        endDate = "<FIRTimestamp: seconds=1664360977 nanoseconds=509447000>";
//        startDate = "<FIRTimestamp: seconds=1664377619 nanoseconds=747944000>";
//    };
//    convertedLocation = "<FIRGeoPoint: (50.100344, 18.530663)>";
//    id = "135CCD32-FF35-4106-9E3B-16FC00613EAC";
//    image = "";
//    isAvailable = 1;
//    licenseImage = "";
//    location =     {
//        city = Rybnik;
//        state = "\U015al\U0105sk";
//        street = "\U015awi\U0119tego J\U00f3zefa 42";
//        zipcode = "44-200";
//    };
//    name = Name;
//    notes = Siemka;
//    price = "12.2";
//}]
