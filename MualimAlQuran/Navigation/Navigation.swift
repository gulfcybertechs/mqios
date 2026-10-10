import SwiftUI

struct NavigationOld: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sheetVM: BottomSheetViewModel
    
    @State private var selectedTab = Tab.home
    
    var body: some View { 
        
        ZStack {
            
            TabView(selection: $mvm.selectedTab) {
                
                NavigationView {
                    
                    ZStack {
                        
                        AppBG()
                        
                        HomeView()
                    }
                }
                .navigationBarHidden(true)
                .navigationViewStyle(.stack)
                .tag(Tab.home)
                
                NavigationView {
                    
                    ZStack {
                        
                        AppBG()
                        
                        AccountView()
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .navigationBarHidden(true)
                .navigationViewStyle(.stack)
                .tag(Tab.account)
                .ignoresSafeArea(.keyboard)
                
                NavigationView {
                    
                    ZStack {
                        
                        AppBG()
                        
                        ShareView()
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .navigationBarHidden(true)
                .navigationViewStyle(.stack)
                .tag(Tab.share)
                .ignoresSafeArea(.keyboard)
                
                NavigationView {
                    
                    ZStack {
                        
                        AppBG()
                        
                        LanguageLayout()
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .navigationBarHidden(true)
                .navigationViewStyle(.stack)
                .tag(Tab.lang)
                .ignoresSafeArea(.keyboard)
                
                NavigationView {
                    
                    ZStack {
                        
                        AppBG()
                        
                        MoreView()
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .navigationBarHidden(true)
                .navigationViewStyle(.stack)
                .tag(Tab.more)
                .ignoresSafeArea(.keyboard)
            }
            .accentColor(Color(hex: "#a8b44c"))
            //            .onAppear {
            //                // correct the transparency bug for Tab bars
            //                let tabBarAppearance = UITabBarAppearance()
            //                tabBarAppearance.configureWithOpaqueBackground()
            //                tabBarAppearance.backgroundColor = UIColor.white
            //                tabBarAppearance.shadowImage = nil
            //                tabBarAppearance.shadowColor = UIColor.clear
            //                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            //                UITabBar.appearance().standardAppearance = tabBarAppearance
            //                // correct the transparency bug for Navigation bars
            //                let navigationBarAppearance = UINavigationBarAppearance()
            //                navigationBarAppearance.configureWithOpaqueBackground()
            //                UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            //            }
            .sheet(isPresented: $sheetVM.sheetState) {
                
                if #available(iOS 16.0, *) {
                    BottomSheet().presentationDetents([.medium, .large])
                } else {
                    BottomSheet()
                }
            }
            
            NavView()
        }
    }
}

struct NavigationUtil {
    
    static func popToRootView(animated: Bool = false) {
        findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController)?.popToRootViewController(animated: animated)
    }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UITabBarController {
            return findNavigationController(viewController: navigationController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}

