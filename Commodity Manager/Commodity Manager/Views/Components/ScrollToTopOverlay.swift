import SwiftUI

struct ScrollToTopOverlay: View {
    var action: () -> Void
    var bottomPadding: CGFloat = 16
    var trailingPadding: CGFloat = 16
    var size: CGFloat = 56
    var backgroundColor: Color = .blue
    var iconColor: Color = .white
    var systemImageName: String = "arrow.up.circle.fill"

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImageName)
                .font(.system(size: size * 0.5))
                .foregroundStyle(iconColor)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: size, height: size)
                )
                .padding(4)
        }
        .padding(.trailing, trailingPadding)
        .padding(.bottom, bottomPadding)
        .accessibilityLabel("최상단으로 이동")
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.gray.ignoresSafeArea()
        ScrollToTopOverlay(action: {})
    }
}
