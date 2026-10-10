import SwiftUI

struct Navigation: View {
    @EnvironmentObject var sheetVM: BottomSheetViewModel

    var body: some View {
        NavView()
            .sheet(isPresented: $sheetVM.sheetState) {
                if #available(iOS 16.0, *) {
                    BottomSheet()
                        .presentationDetents([.medium, .large])
                } else {
                    BottomSheet()
                }
            }
    }
}
