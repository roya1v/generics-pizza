import SwiftUI

struct GradientBackgroundView: View {

    private let startDate = Date()

    var body: some View {
        if #available(iOS 17.0, *) {
            TimelineView(.animation) { _ in
                Color.white.visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.psychodelics(
                                .boundingRect,
                                .float(startDate.timeIntervalSinceNow)
                            )
                        )
                }
            }
        } else {
            Color.white
        }

    }
}
