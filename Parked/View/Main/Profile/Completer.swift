//
//  TestView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI
import MapKit

struct CompleterView: View {
    @State var searched = false
    @State var previousSearch = ""
    @EnvironmentObject var locationService: LocationService
    @State private var searchedPin = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
    @State var clickedPin: Spot?
    
    @Binding var currentType: TextFieldFocusState
    @Binding var text: String
    
    let type: TextFieldFocusState
    let view: AnyView
    
    var body: some View {
        VStack(spacing: 0){
            view
            if type == currentType {
                if locationService.queryFragment != previousSearch {
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
                    }.background(Color.revLabel.cornerRadius(20, corners: [.allCorners]))
                }
            }
        }.onAppear {
            locationService.queryFragment = text
        }
        .onChange(of: text) { newValue in
            locationService.queryFragment = newValue
        }
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
                    text = previousSearch
                }
                
            }
        }
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

