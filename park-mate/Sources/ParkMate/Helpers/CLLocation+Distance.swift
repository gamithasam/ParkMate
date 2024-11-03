// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP
import CoreLocation

extension CLLocation {
    func distance(to location: CLLocation) -> CLLocationDistance {
        return self.distance(from: location)
    }
}
#endif
