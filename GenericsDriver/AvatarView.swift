import SwiftUI

struct AvatarView: View {

    enum Size {
        case regular, compact
    }

    let content: String
    let size: Size

    init(_ content: String = "", size: Size = .regular) {
        self.content = content
        self.size = size
    }

    private var font: Font {
        switch size {
        case .regular:
                .largeTitle
        case .compact:
                .body
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.gray.gradient)
            Text(content)
                .font(font)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
    }
}
