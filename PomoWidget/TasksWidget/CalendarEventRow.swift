import SwiftUI

struct CalendarEventRow: View {
    let event: GoogleCalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            // Calendar icon
            Image(systemName: "calendar")
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text(event.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    if let location = event.location, !location.isEmpty {
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        Text(location)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.05))
        )
    }
}
