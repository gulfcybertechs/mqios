import SwiftUI

struct ShareView: View {
    
    @AppStorage("language") var currentLanguage = getLanguage()
    @EnvironmentObject var mvm: MainViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        Spacer().frame(height: 40)
                        
                        Text(mvm.home.Share)
                            .font(currentLanguage == "Ar" ? .system(size: 28, weight: .bold) : .custom("opensans", size: 28))
                            .fontWeight(currentLanguage == "Ar" ? .bold : .medium)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 5)
                        
                        Text(mvm.home.ShareSummary)
                            .font(currentLanguage == "Ar" ? .system(size: 18, weight: .regular) : .custom("opensans", size: 18))
                            .fontWeight(currentLanguage == "Ar" ? .regular : .medium)
                            .foregroundStyle(colorResource.maroon)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        
                        Spacer().frame(height: 20)
                        //endregion                                                    
                        
                        Button(action: {
                            
                            let activeScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                            let rootViewController = (activeScene?.windows ?? []).first(where: { $0.isKeyWindow })?.rootViewController
                            
                            let AV = UIActivityViewController(activityItems: ["Mu'alim al-Qur'an: https://mualim-alquran.com"], applicationActivities: nil)
                            AV.popoverPresentationController?.sourceView = rootViewController?.view
                            AV.popoverPresentationController?.sourceRect = .zero
                            
                            rootViewController?.present(AV, animated: true, completion: nil)
                            
                        }) {
                            
                            HStack {
                                Text(mvm.home.Share)
                            }
                            .padding([.top, .bottom], 12)
                            .padding([.leading, .trailing], 30)
                        }
                        .foregroundColor(.white)
                        .background(colorResource.primary_500)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .background {
            AppBG()
        }
    }
}
