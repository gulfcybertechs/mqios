import SwiftUI

enum Tab: String, CaseIterable {
    case home, account, share, lang, more
    
    var text: String {
        switch self {
        case .home:
            "Home"
        case .account:
            "Account"
        case .share:
            "Share"
        case .lang:
            "Language"
        case .more:
            "More"
        }
    }
}

struct NavView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            HStack {
                
                ForEach(Tab.allCases, id: \.self) { tab in
                    
                    Spacer()
                    
                    Button {
                        
                        mvm.selectedTab = tab
                        
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        
                        if (mvm.selectedTab == Tab.home) {
                            
                            if (mvm.viewLevel == "home") {
                                
                                mvm.homeScroll = 0
                            }
                            
                            if (mvm.backLevels.contains(mvm.viewLevel)) {
                                
                                mvm.back = true
                            }
                        }
                        
                        if (mvm.selectedTab == Tab.account) {
                            
                            if (mvm.viewLevel == "account") {
                                
                                mvm.accountScroll = 0
                            }
                            
                            if (mvm.accountBackLevels.contains(mvm.viewLevel)) {
                                
                                mvm.accountBack = true
                            }
                        }
                        
                        if (mvm.selectedTab == Tab.more) {
                            
                            if (mvm.viewLevel == "menu") {
                                
                                mvm.menuScroll = 0
                            }
                            
                            if (mvm.menuBackLevels.contains(mvm.viewLevel)) {
                                
                                mvm.back = true
                            }
                        }
                        
                    } label: {
                        
                        VStack {
                            
                            if (tab == Tab.home) {
                                
                                if (mvm.backLevels.contains(mvm.viewLevel)) {
                                    VStack(spacing: 0) {
                                        if (currentLanguage == "Ar") {
                                            Image("back").resizable().scaleEffect(x: -1, y: 1).aspectRatio(contentMode: .fit)
                                        }
                                        else {
                                            Image("back").resizable().aspectRatio(contentMode: .fit)
                                        }
                                    }
                                    .frame(width: 40)
                                }
                                else {
                                    VStack(spacing: 0) {
                                        Image("home").resizable().aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 20)
                                }
                            }
                            else if (tab == Tab.account) {
                                
                                if (mvm.accountBackLevels.contains(mvm.viewLevel)) {
                                    VStack(spacing: 0) {
                                        if (currentLanguage == "Ar") {
                                            Image("back").resizable().scaleEffect(x: -1, y: 1).aspectRatio(contentMode: .fit)
                                        }
                                        else {
                                            Image("back").resizable().aspectRatio(contentMode: .fit)
                                        }
                                    }
                                    .frame(width: 40)
                                }
                                else {
                                    VStack(spacing: 0) {
                                        Image("account").resizable().aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 22)
                                }
                            }
                            else if (tab == Tab.share) {
                                
                                VStack(spacing: 0) {
                                    Image("share").resizable().aspectRatio(contentMode: .fit)
                                }
                                .frame(width: 20)
                            }
                            else if (tab == Tab.lang) {
                                
                                VStack(spacing: 0) {
                                    Image(uiImage: UIImage(named: getLanguage().lowercased())!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                }
                                .padding(1)
                                .background((mvm.selectedTab == Tab.lang) ? Color(hex: "#aab25b") : Color(hex: "#88888a"))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .frame(width: 40)
                                
                            }
                            else if (tab == Tab.more) {
                                
                                if (mvm.menuBackLevels.contains(mvm.viewLevel)) {
                                    VStack(spacing: 0) {
                                        if (currentLanguage == "Ar") {
                                            Image("back").resizable().scaleEffect(x: -1, y: 1).aspectRatio(contentMode: .fit)
                                        }
                                        else {
                                            Image("back").resizable().aspectRatio(contentMode: .fit)
                                        }
                                    }
                                    .frame(width: 40)
                                }
                                else {
                                    VStack(spacing: 0) {
                                        Image("menu").resizable().aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 20)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .foregroundStyle(mvm.selectedTab == tab ? colorResource.primary_500 : .secondary)
                    
                    Spacer()
                }
            }
        }
    }
}

