import SwiftUI

struct ListTabItem: View {
    
    @AppStorage("language") var currentLanguage = getLanguage()
    @EnvironmentObject var mvm: MainViewModel
    @Binding var item: ListModel
    @Binding var account: Bool
    
    var callBack : (() -> Void)? = nil
    
    var body: some View {
        
        Button(action: {
            AppHaptics.tap()
            callBack!()
        }) {
            
            ZStack {
                
                Text(item.Title)
                    .font(currentLanguage == "Ar" ? .system(size: 20, weight: .bold) : .custom("opensans", size: 20))
                    .fontWeight(currentLanguage == "Ar" ? .bold : nil)
                    .foregroundColor(colorResource.maroon)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                
                if (item.TabIndex == mvm.stageTab.TabIndex) {
                    
                    Image(systemName: "chevron.up")
                        .frame(maxWidth:.infinity, alignment: .trailing)
                        .padding(20)
                        .tint(colorResource.lightButtonText)
                }
                else {
                    
                    Image(systemName: "chevron.down")
                        .frame(maxWidth:.infinity, alignment: .trailing)
                        .padding(20)
                        .tint(colorResource.lightButtonText)
                }
            }
        }
        .scaleEffect(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorResource.lightButton)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .background((account && (item.TabIndex == mvm.stageTab.TabIndex)) ? Color(hex: "F1F1EB") : colorResource.lightButton.opacity(0))
        .padding(.bottom, account ? 0 : 10)
        .padding(.top, account ? 10 : 0)
    }
}
