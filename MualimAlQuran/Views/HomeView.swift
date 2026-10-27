import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    @State var layoutPadding = 0.0
    @State var itemSpacing = 0.0
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        ZStack {
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        Spacer().frame(height: 10).id(0)
                        
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 110)
                            .padding(.bottom, currentLanguage == "Ar" ? 9 : 5)
                        
                        Text((currentLanguage == "Ar") ? "مُــعَــلِّــمُ الـــقُـــرْآنْ" : "Mu'alim Al-Qur'an")
                            .font(currentLanguage == "Ar" ? .system(size: 26, weight: .bold) : .custom("opensans", size: 22))
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5)
                        
                        Text(mvm.home.Title.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: ""))
                            .font(currentLanguage == "Ar" ? .system(size: 20, weight: .regular) : .custom("opensans", size: 20))
                            .foregroundColor(colorResource.maroon)
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: mainListAdaptive()), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                            
                            ForEach($mvm.stages) { item in
                                
                                if (currentLanguage == "Ar" && item.id == 4)
                                {
                                    // Hide
                                }
                                else {
                                    
                                    VStack(spacing: 0) {
                                        
                                        if (item.id == 7) {
                                            
                                            Button(action:{
                                                AppHaptics.tap()
                                                
                                                let lessonItem = item
                                                lessonItem.StageID.wrappedValue = 7
                                                
                                                mvm.recitationInitialLoad = false
                                                mvm.listType = "recitation"
                                                mvm.listSelected = item.wrappedValue
                                                mvm.lessonSelected = lessonItem.wrappedValue
                                                mvm.recitationItems = mvm.verse1
                                                navigation.push(.recitation(stageID: 7), in: .home)
                                                
                                            }) {
                                                ListItem(item: item)
                                            }
                                            
                                        } else {
                                            
                                            Button(action: {
                                                AppHaptics.tap()
                                                
                                                mvm.listType = "stage"
                                                mvm.listSelected = item.wrappedValue
                                                mvm.stageTab = ListModel(isTab: true, TabIndex: "101")
                                                mvm.loadStageLessons(item: mvm.listSelected)
                                                navigation.push(.stage(item.id), in: .home)
                                                
                                            }) {
                                                ListItem(item: item)
                                            }
                                        }
                                    }
                                    .id(item.id)
                                }
                            }
                        }
                        .padding(.leading, layoutPadding)
                        .padding(.trailing, layoutPadding)
                    }
                    
                }
                .padding(.top, 1)
                .frame(maxWidth: .infinity)
                .task(id: mvm.homeScroll) {
                    
                    if (mvm.homeScroll != nil) {
                        
                        withAnimation(.linear(duration: 0.3)) {
                            scrollView.scrollTo(mvm.homeScroll, anchor: .center)
                        }
                        
                        mvm.homeScroll = nil
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .onAppear {
            layoutPadding = mainLayoutPadding(items: mvm.stages)
            itemSpacing = listItemSpacing(items: mvm.stages)
            
            /*for family in UIFont.familyNames.sorted() {
             let names = UIFont.fontNames(forFamilyName: family)
             print("Family: \(family) Font Names: \(names)")
             }*/
        }
        .onRotate { newOrientation in
            
            Task {
                
                for _ in 1...5 {
                    
                    try await Task.sleep(nanoseconds: 100_000_000)
                    layoutPadding = mainLayoutPadding(items: mvm.stages)
                    itemSpacing = listItemSpacing(items: mvm.stages)
                }
            }
        }
    }
}
