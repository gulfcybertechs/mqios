import SwiftUI

struct AppBG: View {
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Image("bg_custom")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight:425)
            
            Spacer()
        }
        .frame(width: 0)
        .ignoresSafeArea()
    }
}

// Preserve the original page's top and side clipping, allowing drawing only
// below its bottom edge. The extra drawing area does not add layout space.
struct PageBottomOverflowClip: Shape {
    func path(in rect: CGRect) -> Path {
        Path(CGRect(x: rect.minX, y: rect.minY,
                    width: rect.width, height: rect.height * 2))
    }
}
