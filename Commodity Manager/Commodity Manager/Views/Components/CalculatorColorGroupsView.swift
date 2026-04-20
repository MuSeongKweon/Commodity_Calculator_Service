import SwiftUI

struct CalculatorColorGroupsView: View {

    let groups: [MaterialColor: [Material]]
    @Binding var materials: [Material]
    @Binding var selectedQuantities: [UUID: Int]

    var body: some View {
        let sortedKeys = groups.keys.sorted { String(describing: $0) < String(describing: $1) }

        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    Color.clear
                        .frame(height: 0.1)
                        .id("top")

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(sortedKeys, id: \.self) { color in
                            NavigationLink {
                                CalculatorColorFilteredListView(
                                    color: color,
                                    materials: $materials,
                                    selectedQuantities: $selectedQuantities
                                )
                            } label: {
                                ColorGroupCell(color: color, count: groups[color]?.count ?? 0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }

                ScrollToTopOverlay(
                    action: {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    },
                    bottomPadding: 16,
                    trailingPadding: 16,
                    size: 56,
                    backgroundColor: .white,
                    iconColor: .gray,
                    systemImageName: "arrow.up.circle.fill"
                )
            }
        }
    }
}
