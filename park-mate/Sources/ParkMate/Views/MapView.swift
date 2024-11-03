// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
#if !SKIP
import MapKit
#else
import com.google.maps.android.compose.__
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
#endif


struct MapView: View {
    #if !SKIP
    @StateObject private var viewModel: ParkingLotViewModel = ParkingLotViewModel()
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337), // Default to Kandy
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    #endif
    
    var body: some View {
        #if !SKIP
        if #available(iOS 17.0, macOS 14.0, *) {
            Map(coordinateRegion: $region, annotationItems: viewModel.parkingLots) { lot in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: lot.latitude?.doubleValue ?? 0.0, longitude: lot.longitude?.doubleValue ?? 0.0)) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        Text(lot.name ?? "")
                            .font(.caption)
                            .bold()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Optionally, center the map on the first parking lot
                if let firstLot = viewModel.parkingLots.first,
                   let latitude = firstLot.latitude?.doubleValue,
                   let longitude = firstLot.longitude?.doubleValue {
                    region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            }
        } else {
            Text("Map requires iOS 17")
                .font(.title)
        }
        #else
        ComposeView { ctx in
            GoogleMap()
        }
        #endif
    }
}
