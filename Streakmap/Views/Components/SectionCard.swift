import SwiftUI

struct SectionCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(StreakmapTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: StreakmapTheme.shadow, radius: 20, x: 0, y: 10)
    }
}
