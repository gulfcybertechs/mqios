import SwiftUI

struct MoreView: View {
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        
        
        VStack(spacing: 0) {
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        Spacer().frame(height: 40)
                        
                        Text(mvm.home.InfoSettings)
                            .font(currentLanguage == "Ar" ? .system(size: 28, weight: .bold) : .custom("opensans", size: 28))
                            .fontWeight(currentLanguage == "Ar" ? .bold : .medium)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 5)
                        
                        Spacer().frame(height: 20)
                        //endregion                                                    
                        
                        if (mvm.pages.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: 0, alignment: .leading)], spacing: 0) {
                                                                
                                ForEach($mvm.pages.indices, id: \.self) { index in
                                    
                                    let item = $mvm.pages[index]
                                    
                                    if (item.id == "feedback") {
                                        Spacer().frame(height: 30)
                                    }
                                    
                                    VStack {
                                        
                                        Button(action: {
                                            AppHaptics.tap()
                                            
                                            mvm.pageSelected = item.wrappedValue
                                            if (item.id == "language") {
                                                navigation.push(.language, in: .more)
                                            } else if (item.id == "download") {                                                
                                                navigation.push(.downloads, in: .more)
                                            } else if (item.id == "share") {
                                                navigation.push(.share, in: .more)
                                            } else {
                                                navigation.push(.infoPage(item.id), in: .more)
                                            }
                                            
                                        })
                                        {
                                            ZStack(alignment: .trailing) {
                                                
                                                HStack(spacing: 0)
                                                {
                                                    
                                                    Text(item.Title.wrappedValue)
                                                        .fontWeight(currentLanguage == "Ar" ? .bold : nil)
                                                    
                                                    Spacer()
                                                    
                                                    if (item.id != "language") {
                                                        
                                                        Image(systemName: (currentLanguage == "Ar") ? "chevron.left" : "chevron.right")
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                
                                                
                                                if (item.id == "language") {
                                                    
                                                    Image(uiImage: UIImage(named: getLanguage().lowercased())!)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 50, alignment: .trailing)
                                                        .padding(.trailing, 10)
                                                }
                                                
                                            }
                                        }
                                        .background(colorResource.lightButton)
                                        .foregroundColor(colorResource.lightButtonText)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(0)
                                    }
                                    
                                    Spacer().frame(height: 5)
                                }
                            }
                        }
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                }
            }
        }
    }
}
