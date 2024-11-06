// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP
import SwiftUI

struct CardView: View {
    var parkinglot: ParkingLot
    
    var body: some View {
        HStack {
            if let _ = parkinglot.pic, let url = URL(string: parkinglot.pic!) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                            .clipped()
                    case .failure:
                        Image("Logo") // TODO: Show a placeholder if image loading fails
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                            .clipped()
                    @unknown default:
                        EmptyView()
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                    }
                }
            } else {
                Image("replace") // TODO: Show a default placeholder if URL is nil
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
            }
            VStack(alignment: .leading) {
                Text(parkinglot.name ?? "Car Park Name")
                    .font(.headline)
                Text(parkinglot.city ?? "City")
                    .font(.caption)
                Spacer()
                HStack(alignment: .bottom) {
                    Text("Rs."+String(parkinglot.price?.intValue ?? 888))
                        .font(.body)
                    Text("per hour")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 16)
        }
        .padding(9)
        .background(Color.white)
        .cornerRadius(16)
    }
}
#endif
