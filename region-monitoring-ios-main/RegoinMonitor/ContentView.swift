//
//  ContentView.swift
//  RegoinMonitor
//
//  Created by Dac Vu on 08/05/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    
    @EnvironmentObject var settings: AlertSettings

    var body: some View {
        Button {
            
            let locations = [
                (CLLocation(latitude: 10.8033210, longitude: 106.7145378), "home"),
                (CLLocation(latitude: 10.7940724, longitude: 106.7018899), "thap"),
                (CLLocation(latitude: 10.7851695, longitude: 106.6902156), "nam ky khoi nghia"),
                (CLLocation(latitude: 10.7781524, longitude: 106.6838211), "nha tho")
            ]
            let mapItems = locations.map { (location, name) -> MKMapItem in
                let placemark = MKPlacemark(coordinate: location.coordinate)
                let item = MKMapItem(placemark: placemark)
                item.name = name
                return item
            }
            MKMapItem.openMaps(with: mapItems, launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        } label: {
            Text("Start trip")
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AlertSettings())
    }
}
