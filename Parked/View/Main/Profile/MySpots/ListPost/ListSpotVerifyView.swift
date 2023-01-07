//
//  ListSpotVerifyView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI
import MapKit

struct ListSpotVerifyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var spotsVM: SpotsViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Binding var street: String
    @Binding var city: String
    @Binding var state: String
    @Binding var zipcode: String
    @Binding var notes: String
    @Binding var page: Int
    @Binding var price: String
    @Binding var price2: String
    @Binding var availabilityRange: [AvailabilityRange]
    
    @State private var spotImage = UIImage()
    @State private var drivingLicenseImage = UIImage()
    @State private var drivingShowSheet = false
    @State private var showSheet = false
    @State private var spotShowSheet = false
    @State private var showLibrary = false
    @State private var showCamera = false
    
    @State var showSecondInfo = false
    @State var showInfo = false
    @State var isChecking = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 30, weight: .bold))
                        .padding(.horizontal, 5)
                    Text("Verify")
                        .font(.system(size: 25, weight: .bold))
                    Spacer()
                    HStack(spacing: 5){
                        Circle().fill(Color("CustomGreen")).frame(width: 20)
                        Circle().fill(Color("CustomGreen")).frame(width: 20)
                        Circle().fill(Color("CustomGreen")).frame(width: 20)
                    }
                }
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Driving License")
                                .font(.system(size: 20, weight: .regular))
                                .padding(.leading, 3)
                            Button {
                                showInfo = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                            }.foregroundColor(Color(UIColor.label))
                        }.padding(.top, 25)
                        Button {
                            drivingShowSheet = true
                            showSheet = true
                        } label: {
                            ZStack {
                                if drivingLicenseImage == UIImage(){
                                    Color(UIColor.systemGray4).cornerRadius(10).frame(height: 120)
                                    if isChecking {
                                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).fill(.red).padding(2)
                                    }
                                }else {
                                    Image(uiImage: self.drivingLicenseImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                }
                            }
                        }
                        HStack{
                            Text("Spot Image")
                                .font(.system(size: 20, weight: .regular))
                                .padding(.leading, 3)
                            Button {
                                showSecondInfo = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                            }.foregroundColor(Color(UIColor.label))
                        }.padding(.top, 25)
                        Button {
                            spotShowSheet = true
                            showSheet = true
                        } label: {
                            ZStack{
                                if spotImage == UIImage(){
                                    Color(UIColor.systemGray4).cornerRadius(10).frame(height: 120)
                                    if isChecking {
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
                    }
                }
                Spacer()
                Spacer()
                ListSpotNextButton(function: {
                    UIApplication.shared.endEditing()
                    if drivingLicenseImage != UIImage() && spotImage != UIImage() {
                        spotsVM.isLoading = true
                        DispatchQueue.main.async {
                            converAddressToCoordinates(address: "\(street), \(city), \(zipcode)", completion: { (placemarks, error) in
                                guard
                                    let placemarks = placemarks,
                                    let location = placemarks.first?.location
                                else {
                                    print("error \(error!)")
                                    return
                                }
                                spotsVM.uploadImage(image: spotImage, subDir: "spotImages") { spotURL, spotError in
                                    if let spotError = spotError {
                                        print("Error: \(spotError.localizedDescription)")
                                    }else{
                                        if let spotURL = spotURL {
                                            spotsVM.uploadImage(image: drivingLicenseImage, subDir: "drivingLicenseImages") { licenseURL, licenseError in
                                                if let licenseError = licenseError {
                                                    print("Error: \(licenseError.localizedDescription)")
                                                } else {
                                                    if let licenseURL = licenseURL {
                                                        let image = spotURL.absoluteString
                                                        let license = licenseURL.absoluteString
                                                        
                                                        let spot = Spot(image: image, licenseImage: license, location: Location(street: street, city: city, state: state, zip_code: zipcode), convertedLocation: location, availabilityRange: availabilityRange, price: Double("\(price).\(price2)") ?? 0.0, notes: notes, isAvailable: true, ownerID: userVM.currentUser?.uid ?? "", sid: "", isApproved: false, isHidden: false)
                                                        spotsVM.addSpot(spot: spot, sid: spot.id.uuidString) { error in
                                                            if let error = error {
                                                                print("Error: \(error.localizedDescription)")
                                                            }else{
                                                                userVM.addSpot(spot: spot, sid: spot.id.uuidString) { error in
                                                                    if let error = error {
                                                                        print("Error: \(error.localizedDescription)")
                                                                    }else{
                                                                        print("no come on")
                                                                        dismiss()
                                                                        spotsVM.isLoading = false
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
                            })
                        }
                    }else {
                        isChecking = true
                    }
                    
                }, isLast: true).disabled(spotsVM.isLoading)
                Spacer()
            }.padding(20)
                .padding(.top, 15)
                .sheet(isPresented: $showSheet) {
                    VStack {
                        
                        Spacer()
                        Button {
                            showSheet = false
                            showCamera = true
                        } label: {
                            Text("Camera")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        Spacer()
//                        if spotShowSheet {
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
//                        }
                    } .presentationDetents([.fraction(0.2)])
                }
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
                    spotShowSheet = false
                    drivingShowSheet = false
                }) {
                    if spotShowSheet {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: self.$spotImage)
                    } else {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: self.$drivingLicenseImage)
                    }
                }
                .sheet(isPresented: $showCamera, onDismiss: {
                    spotShowSheet = false
                    drivingShowSheet = false
                }){
                    if spotShowSheet {
                        ImagePicker(sourceType: .camera, selectedImage: self.$spotImage)
                    } else {
                        ImagePicker(sourceType: .camera, selectedImage: self.$drivingLicenseImage)
                    }
                }
            if showInfo {
                InfoView(showInfo: $showInfo, text: "We use your drivers license to confirm the property is yours. We will not use this data for any other reasons")
            }
            if showSecondInfo {
                InfoView(showInfo: $showSecondInfo, text: "We use this image to make your parking spot more accessible to Parkers!")
            }
        }
    }
    func converAddressToCoordinates(address: String, completion: @escaping CLGeocodeCompletionHandler){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: completion)
    }
    func addressIntoZipCode(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) -> Void in
            // Placemarks is an optional array of CLPlacemarks, first item in array is best guess of Address
            
            if let placemark = placemarks?[0] {
                
                zipcode = placemark.postalAddress?.postalCode ?? ""
            }
            
        }
    }
}


