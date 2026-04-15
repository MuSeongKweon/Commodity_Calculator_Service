import SwiftUI

struct ColorGroupsView: View {

    let groups: [MaterialColor: [Material]]
    // 🔴 이거 추가
    @Binding var selectedColorFilter: MaterialColor?
    @Binding var materials: [Material]   // 🔴 추가

    var body: some View {

        let sortedKeys = groups.keys.sorted { $0.rawValue < $1.rawValue }

        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16
        ) {

            ForEach(sortedKeys, id: \._rawValue) { color in

                NavigationLink {

                    ColorFilteredListView(
                        color: color,
                        materials: $materials
                    )

                } label: {

                    ColorGroupCell(
                        color: color,
                        count: groups[color]?.count ?? 0
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

struct ColorGroupCell: View {

    let color: MaterialColor
    let count: Int

    var body: some View {

        ZStack(alignment: .bottomLeading) {

            ZStack {

                RoundedRectangle(cornerRadius: 10)
                    .fill(color.color.opacity(0.5))
                    .frame(height: 110)
                    .offset(x: 8, y: 8)

                RoundedRectangle(cornerRadius: 10)
                    .fill(color.color.opacity(0.7))
                    .frame(height: 110)
                    .offset(x: 4, y: 4)

                RoundedRectangle(cornerRadius: 10)
                    .fill(color.color)
                    .frame(height: 110)
            }
            .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 4) {

                Text(color.displayName)
                    .font(.headline)

                Text("\(count)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
    }
}

extension MaterialColor {

    var _rawValue: String {
        String(describing: self)
    }

    var displayName: String {
        switch self {
            case .gray: return "회색"
            case .red: return "빨강"
            case .orange: return "주황"
            case .yellow: return "노랑"
            case .green: return "초록"
            case .blue: return "파랑"
        }
    }
}
