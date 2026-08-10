import SwiftUI

struct TajweedExampleHeader: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @State var col: Int
    @State var width = 60.0
    @State var text = (getLanguage() == "Ar") ? "الحرف" : "Letter"
    
    var body: some View {
                        
        VStack(spacing: 0)
        {
            Text(text)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.top, 5)
                .padding(.bottom, 5)
        }
        .frame(minWidth: width, maxHeight: .infinity, alignment: .center)
        .padding(5)
        .background(colorResource.lightButton)
        .onAppear() {
            
            if (col == 0) {
                
                if (mvm.lessonSelected.Number == 9 ||
                    mvm.lessonSelected.Number == 10 ||
                    mvm.lessonSelected.Number == 11 ||
                    mvm.lessonSelected.Number == 12 ||
                    mvm.lessonSelected.Number == 13 ||
                    mvm.lessonSelected.Number == 14 ||
                    mvm.lessonSelected.Number == 15 ||
                    mvm.lessonSelected.Number == 16 ||
                    mvm.lessonSelected.Number == 17 ||
                    mvm.lessonSelected.Number == 18 ||
                    mvm.lessonSelected.Number == 19 ||
                    mvm.lessonSelected.Number == 20 ||
                    mvm.lessonSelected.Number == 21 ||
                    mvm.lessonSelected.Number == 22 ||
                    mvm.lessonSelected.Number == 23 ||
                    mvm.lessonSelected.Number == 24) {
                    text = mvm.tajweedSelectedSetup.Col1.replacingOccurrences(of: "<br />", with: "\n")
                    width = 250
                }
            }
            if (col == 1) {
                text = mvm.tajweedSelectedSetup.Col2.replacingOccurrences(of: "<br />", with: "\n")
                width = 250
            }
            else if (col == 2) {
                text = mvm.tajweedSelectedSetup.Col3.replacingOccurrences(of: "<br />", with: "\n")
                width = 250
            }
            if (col == 3) {
                text = mvm.tajweedSelectedSetup.Col4.replacingOccurrences(of: "<br />", with: "\n")
                width = 250
            }
            
            if ((mvm.lessonSelected.Number == 2 && col == 1) ||
                (mvm.lessonSelected.Number == 3 && col == 1) ||
                (mvm.lessonSelected.Number == 4 && col == 1)) {
                width = 160
            }
        }
        
        if (col != mvm.tajweedSelectedSetup.ColumnCount - 1) {
            
            Divider()
                .frame(minWidth: 1, maxHeight: .infinity)
                .background(Color(hex: "DAE1A0"))
        }
    }
}
