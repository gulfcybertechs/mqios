//
//  MualimAlQuranApp.swift
//  MualimAlQuran
//
//  Created by Muhammad Bawab on 11/08/2022.
//

import SwiftUI
import AppTrackingTransparency
import AdSupport

class GlobalGrid: ObservableObject {
    @Published var columns = [GridItem(.adaptive(minimum: 300))]
}

@main
struct MualimAlQuranApp: App {
    
    let mvm = MainViewModel();
    let sheetVM = BottomSheetViewModel();
    let navigationController: UINavigationController = .init()
    @AppStorage("language") var currentLanguage = getLanguage()
    
    init() {
        
        mvm.initiate()
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            //ZStack {
                
                Navigation()
                    .environmentObject(mvm) 
                    .environmentObject(sheetVM)    
                    .environment(\.layoutDirection, (currentLanguage == "Ar") ? .rightToLeft : .leftToRight)
            //}
            /*.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    
                })
            }*/
        }
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
}


