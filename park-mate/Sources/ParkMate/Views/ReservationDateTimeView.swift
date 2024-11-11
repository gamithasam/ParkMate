// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ReservationDateTimeView: View {
    let dateNTime: String

    var body: some View {
        if let date = getDate(from: dateNTime) {
            HStack(alignment: .bottom) {
                Text(getFormattedTime(from: date))
                    .font(.body)
                Text(getFormattedDate(from: date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func getDate(from dateNTime: String) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy 'at' h:mm:ss a"
        return inputFormatter.date(from: dateNTime)
    }

    private func getFormattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }

    private func getFormattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
