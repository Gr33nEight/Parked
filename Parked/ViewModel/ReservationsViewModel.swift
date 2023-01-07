//
//  ReservationsViewModel.swift
//  Parked
//
//  Created by Natanael Jop on 04/10/2022.
//

import SwiftUI
import Foundation
import MapKit
import Firebase
import FirebaseStorage
import FirebaseFirestore



class ReservationsViewModel: ObservableObject {
    @Published var reservations = [Reservation]()
    @Published var allReservations = [Reservation]()
    @Published var userVM = UserViewModel()
    let reservationsDB = Firestore.firestore().collection("reservations")
    
    init() {
        Task(priority: .low){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.fetchReservations()
                self.fetchAllReservations()
            }
        }
    }
    
    func fetchReservations() {
        reservationsDB.whereField("bookingUserID", isEqualTo: userVM.currentUser?.uid ?? "").addSnapshotListener { query, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }else{
                if !query!.isEmpty {
                    query?.documentChanges.forEach({ change in
                        switch change.type {
                        case .added:
                            let reservation = change.document.data()
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
                            
                            self.reservations.append(Reservation(spot: Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: spotOwnerID, sid: sid, isApproved: isApproved, isHidden: isHidden), frameRange: frameRangeFinal, name: name, bookingUserID: bookingUserID, spotID: sid, reservationID: id))
                            self.fetchOwnerWithId(userID: spotOwnerID, reservationID: id)
                            self.fetchRenterWithId(userID: bookingUserID, reservationID: id)
                            print(self.reservations)
                        case .modified:
                            let reservation = change.document.data()
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
                            let startDateF = (frameRange["date"] as? Timestamp)?.dateValue() ?? Date()
                            let endDateF = (frameRange["endDate"] as? Timestamp)?.dateValue() ?? Date()
                            let frameRangeFinal = DateRange(startDate: startDateF, endDate: endDateF)
                            
                            self.reservations = self.reservations.filter({$0.reservationID != id})
                            self.reservations.append(Reservation(spot: Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: spotOwnerID, sid: sid, isApproved: isApproved, isHidden: isHidden), frameRange: frameRangeFinal, name: name, bookingUserID: bookingUserID, spotID: sid, reservationID: id))
                            self.fetchOwnerWithId(userID: spotOwnerID, reservationID: id)
                            self.fetchRenterWithId(userID: bookingUserID, reservationID: id)
                        case .removed:
                            let reservation = change.document.data()
                            let id = reservation["id"] as? String ?? ""
                            let sid = reservation["sid"] as? String ?? ""
                            self.reservations = self.reservations.filter({$0.reservationID != id})
                            Firestore.firestore().collection("spots").document(sid).updateData(["isAvailable" : false]) { error in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                }else{
//                                    print("działa")
                                }
                            }
                        }
                    })
                }else{
                    print("ni ma")
                }
            }
        }
        
    }
    
    func fetchAllReservations() {
        reservationsDB.addSnapshotListener { query, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }else{
                if !query!.isEmpty {
                    query?.documentChanges.forEach({ change in
                        switch change.type {
                        case .added:
                            let reservation = change.document.data()
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
                            
                            self.allReservations.append(Reservation(spot: Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: spotOwnerID, sid: sid, isApproved: isApproved, isHidden: isHidden), frameRange: frameRangeFinal, name: name, bookingUserID: bookingUserID, spotID: sid, reservationID: id))
                            self.fetchOwnerWithId(userID: spotOwnerID, reservationID: id)
                            self.fetchRenterWithId(userID: bookingUserID, reservationID: id)
                            print(self.reservations)
                        case .modified:
                            let reservation = change.document.data()
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
                            let startDateF = (frameRange["date"] as? Timestamp)?.dateValue() ?? Date()
                            let endDateF = (frameRange["endDate"] as? Timestamp)?.dateValue() ?? Date()
                            let frameRangeFinal = DateRange(startDate: startDateF, endDate: endDateF)
                            
                            self.allReservations = self.allReservations.filter({$0.reservationID != id})
                            self.allReservations.append(Reservation(spot: Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: spotOwnerID, sid: sid, isApproved: isApproved, isHidden: isHidden), frameRange: frameRangeFinal, name: name, bookingUserID: bookingUserID, spotID: sid, reservationID: id))
                            self.fetchOwnerWithId(userID: spotOwnerID, reservationID: id)
                            self.fetchRenterWithId(userID: bookingUserID, reservationID: id)
                        case .removed:
                            let reservation = change.document.data()
                            let id = reservation["id"] as? String ?? ""
                            let sid = reservation["sid"] as? String ?? ""
                            self.allReservations = self.allReservations.filter({$0.reservationID != id})
                            Firestore.firestore().collection("spots").document(sid).updateData(["isAvailable" : false]) { error in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                }else{
//                                    print("działa")
                                }
                            }
                        }
                    })
                }else{
                    print("ni ma")
                }
            }
        }
    }
    
    func reserveSpot(reservation: Reservation, completion: ((Error?) -> Void)?) {
        var availabilityRangeArray = [[:]]
        for i in reservation.spot.availabilityRange {
            availabilityRangeArray.append([
                "day": i.day,
                "startDate" : Timestamp(date: i.startDate),
                "endDate" : Timestamp(date: i.endDate)
            ])
        }
        let data = [
            "id" : reservation.id.uuidString,
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
        ] as [String : Any]
        reservationsDB.document(reservation.id.uuidString).setData(data, completion: completion)
    }
    
    func deleteReservation(reservationID: String, completion: ((Error?) -> Void)?){
        reservationsDB.document(reservationID).delete(completion: completion)
    }
    
    func extendTimeOfReservation(reservation: Reservation, newDate: Date, completion: ((Error?) -> Void)?){
        reservationsDB.document(reservation.reservationID ?? "").updateData([
            "frameRange": [
                "startDate" : Timestamp(date: reservation.frameRange.startDate),
                "endDate" : Timestamp(date: newDate)
            ],
        ], completion: completion)
    }
    
    func fetchRenterWithId(userID: String, reservationID: String){
        Firestore.firestore().collection("users").document(userID).getDocument { doc, error in
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
                    
                    
                    for i in self.reservations.indices {
                        if self.reservations[i].reservationID == reservationID {
                            self.reservations[i].renter = user
                        }
                    }
                    
                }else {
                    print("Doesn't exist")
                }
            }
        }
    }
    func fetchOwnerWithId(userID: String, reservationID: String){
        Firestore.firestore().collection("users").document(userID).getDocument { doc, error in
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
                    
                    
                    for i in self.reservations.indices {
                        if self.reservations[i].reservationID == reservationID {
                            self.reservations[i].owner = user
                        }
                    }
                    
                }else {
                    print("Doesn't exist")
                }
            }
        }
    }
}
