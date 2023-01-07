//
//  SpotsViewModel.swift
//  Parked
//
//  Created by Natanael Jop on 27/09/2022.
//

import SwiftUI
import Foundation
import MapKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class SpotsViewModel: ObservableObject {    
    @Published var allSpots = [Spot]()
    @Published var isLoading = false
    let spotsDB = Firestore.firestore().collection("spots")
    let storage = Storage.storage().reference()
    
    init() {
        self.fetchSpots()
    }
    
    func fetchSpots() {
        spotsDB.addSnapshotListener { query, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }else{
                query?.documentChanges.forEach({ change in
                    switch change.type {
                    case .added:
                        let spot = change.document.data()
                        let location = spot["location"] as? [String : Any] ?? [:]
                        let availabilityRange = spot["availabilityRange"] as? [[String : Any]] ?? [[:]]
                        
                        /// spot
                        let image = spot["image"] as? String ?? ""
                        let licenseImage = spot["licenseImage"] as? String ?? ""
                        let notes = spot["notes"] as? String ?? ""
                        let price = spot["price"] as? Double ?? 0.0
                        let isAvailable = spot["isAvailable"] as? Bool ?? false
                        let ownerID = spot["ownerID"] as? String ?? ""
                        let sid = spot["sid"] as? String ?? ""
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
                        
                        
                        self.allSpots.append(Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: ownerID, sid: sid, isApproved: isApproved, isHidden: isHidden))
                    case .modified:
                        let spot = change.document.data()
                        let location = spot["location"] as? [String : Any] ?? [:]
                        let availabilityRange = spot["availabilityRange"] as? [[String : Any]] ?? [[:]]
                        
                        /// spot
                        let image = spot["image"] as? String ?? ""
                        let licenseImage = spot["licenseImage"] as? String ?? ""
                        let notes = spot["notes"] as? String ?? ""
                        let price = spot["price"] as? Double ?? 0.0
                        let isAvailable = spot["isAvailable"] as? Bool ?? false
                        let ownerID = spot["ownerID"] as? String ?? ""
                        let sid = spot["sid"] as? String ?? ""
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
                        
                        self.allSpots = self.allSpots.filter({$0.sid != sid})
                        self.allSpots.append(Spot(image: image, licenseImage: licenseImage, location: locationFinal, convertedLocation: convertedLocation, availabilityRange: availabilityRangeFinal, price: price, notes: notes, isAvailable: isAvailable, ownerID: ownerID, sid: sid, isApproved: isApproved, isHidden: isHidden))
                    case .removed:
                        let spot = change.document.data()
                        let id = spot["id"] as? String ?? ""
                        self.allSpots = self.allSpots.filter({$0.id.uuidString != id})
                    }
                    
                })
            }
            
        }
    }
    
    func addSpot(spot: Spot, sid: String, completion: ((Error?) -> Void)?) {
        let tempSpot = Spot(image: spot.image, licenseImage: spot.licenseImage, location: spot.location, convertedLocation: spot.convertedLocation, availabilityRange: spot.availabilityRange, price: spot.price, notes: spot.notes, isAvailable: spot.isAvailable, ownerID: spot.ownerID, sid: sid, isApproved: false, isHidden: spot.isHidden)
        
        var availabilityRangeArray = [[:]]
        for i in tempSpot.availabilityRange {
            availabilityRangeArray.append([
                "day": i.day,
                "startDate" : Timestamp(date: Date()),
                "endDate" : Timestamp(date: Date())
            ])
        }
        
        let data = [
            "id" : tempSpot.id.uuidString,
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
            "sid": tempSpot.id.uuidString,
            "isApproved": false
        ] as [String : Any]
        spotsDB.document(tempSpot.id.uuidString).setData(data, completion: completion)
    }
    
    

    func uploadImage(image: UIImage, subDir: String, completion: @escaping ((URL?, Error?) -> Void)) {
        let data = image.jpegData(compressionQuality: 0.2)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        if let data = data {
            storage.child("images/\(subDir)/\(image.description)").putData(data, metadata: metaData) { metaData, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    self.storage.child("images/\(subDir)/\(image.description)").downloadURL(completion: completion)
                }
            }
        }
    }
    
    func setSpotAvailability(for isAvailable: Bool, spotID: String){
        spotsDB.document(spotID).updateData(["isAvailable" : isAvailable]) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    func setVisibility(for isHidden: Bool, spotID: String){
        spotsDB.document(spotID).updateData(["isHidden" : isHidden]) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteSpot(spot: Spot, completion: ((Error?) -> Void)?){
        spotsDB.document(spot.id.uuidString).delete(completion: completion)
    }
    
    func updateSpot(spot: Spot, completion: ((Error?) -> Void)?){
        var availabilityRangeArray = [[:]]
        for i in spot.availabilityRange {
            availabilityRangeArray.append([
                "day": i.day,
                "startDate" : Timestamp(date: i.startDate),
                "endDate" : Timestamp(date: i.endDate)
            ])
        }
        
        let data = [
            "id" : spot.sid,
            "image" : spot.image,
            "licenseImage" : spot.licenseImage,
            "location" : [
                "street" : spot.location.street,
                "city" : spot.location.city,
                "state" : spot.location.state,
                "zipcode" : spot.location.zip_code
            ],
            "address" : spot.address,
            "convertedLocation" : GeoPoint(latitude: spot.convertedLocation.coordinate.latitude, longitude: spot.convertedLocation.coordinate.longitude),
            "availabilityRange": availabilityRangeArray,
            "price" : spot.price,
            "notes" : spot.notes,
            "isAvailable" : spot.isAvailable,
            "ownerID": spot.ownerID,
            "sid": spot.sid,
            "isApproved": spot.isApproved
        ] as [String : Any]
        spotsDB.document(spot.sid).updateData(data, completion: completion)
    }
}
