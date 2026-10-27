import SwiftUI
import SwiftSoup

struct LanguageLayout: View {
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    @EnvironmentObject var sheetVM: BottomSheetViewModel
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    var body: some View {
        
        ZStack {
            
            AppBG()
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        Spacer().frame(height: 40)
                        
                        Text(mvm.pages.first{ $0.id == "language" }?.Title ?? "")
                            .font(currentLanguage == "Ar" ? .system(size: 26, weight: .bold) : .custom("opensans", size: 26))
                            .fontWeight(currentLanguage == "Ar" ? .bold : .medium)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                        
                        Rectangle()
                            .fill(colorResource.maroon)
                            .frame(height: 1)
                            .padding(.bottom, 5)
                        
                        Spacer().frame(height: 10)
                        //endregion
                           
                        if (mvm.languageItems.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: 0, alignment: .leading)], spacing: 0) {
                                
                                ForEach($mvm.languageItems) { item in
                                    
                                    VStack(spacing:0) {
                                        
                                        Button(action: {
                                            
                                            if (currentLanguage != item.id) {
                                                setLanguage(id: item.id, name: item.Title.wrappedValue)
                                                currentLanguage = item.id
                                                
                                                sheetVM.restart = true
                                                sheetVM.title = mvm.home.RestartApp
                                                sheetVM.summary = mvm.home.RestartAppSummary
                                                sheetVM.sheetState.toggle()
                                                
                                                Task.detached { @MainActor in
                                                    
                                                    mvm.initiated = false
                                                    mvm.initiate()
                                                    
                                                    try! await Task.sleep(nanoseconds: 1000_000_000)
                                                    try! await Task.sleep(nanoseconds: 800_000_000)
                                                    navigation.resetAll()
                                                    mvm.selectedTab = Tab.home
                                                    try! await Task.sleep(nanoseconds: 1000_000_000)
                                                    sheetVM.sheetState = false
                                                    sheetVM.restart = false
                                                }
                                            }
                                        })
                                        {
                                            
                                            ZStack(alignment: .trailing) {
                                                
                                                let color = (item.id == currentLanguage) ? colorResource.white : colorResource.lightButtonText
                                                let background = (item.id == currentLanguage) ? colorResource.primary_500 : colorResource.lightButton
                                                
                                                HStack(spacing:0) {
                                                    
                                                    Text(item.Title.wrappedValue)
                                                        .foregroundStyle(color)
                                                    
                                                    Spacer()
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .background(background)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                                
                                                Image(uiImage: UIImage(named: item.id.lowercased())!)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 50, alignment: .trailing)
                                                    .padding(.trailing, 10)
                                            }
                                        }                                        
                                        
                                        Spacer().frame(height: 5)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, (safeArea?.top ?? 0) + 1)
                .padding(.leading, safeArea?.left)
                .padding(.trailing, safeArea?.right)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .clipShape(PageBottomOverflowClip(), style: FillStyle(antialiased: false))
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
        .onAppear {
            if let insets = UIApplication.shared.firstKeyWindow?.safeAreaInsets {
                safeArea = insets
            }
        }
        .onRotate { newOrientation in
            
            Task {
                
                for _ in 1...5 {
                    
                    try await Task.sleep(nanoseconds: 100_000_000)
                    safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
                }
            }
        }
    }
}
