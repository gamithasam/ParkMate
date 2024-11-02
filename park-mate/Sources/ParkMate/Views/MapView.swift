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
    var body: some View {
        #if !SKIP
        if #available(iOS 17.0, macOS 14.0, *) {
            Map()
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
