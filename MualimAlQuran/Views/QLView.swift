import SwiftUI

struct QLView: View {
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @AppStorage("language") var currentLanguage = getLanguage()
    @EnvironmentObject var mvm: MainViewModel
    @State var activeItem = -1
    @State var activeLetter = -1
    @State var layoutPadding = 0.0
    @State var itemSpacing = 0.0
    @State var player = Player()
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    var body: some View {
        
        ZStack {
            
            AppBG()
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        Spacer().frame(height: 10)
                        Text(mvm.home.Lesson + " " + mvm.lessonSelected.Number.description)
                            .font(currentLanguage == "Ar" ? .system(size: 22, weight: .bold) : .custom("opensans", size: 22))
                            .bold()
                            .lineSpacing(8)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        
                        Text(mvm.lessonSelected.Title.components(separatedBy: "<span>")[0].description)
                            .font(currentLanguage == "Ar" ? .system(size: 20, weight: .regular) : .custom("opensans", size: 20))
                            .fontWeight(currentLanguage == "Ar" ? .regular : nil)
                            .foregroundColor(colorResource.maroon)
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        //endregion
                        
                        if (mvm.qlItems.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                                
                                ForEach($mvm.qlItems.filter{ $0.Type.wrappedValue == "Intro" }) { item in
                                    
                                    QLItem(item: item, activeItem: $activeItem, activeLetter: $activeLetter, player: $player)
                                    
                                    ForEach($mvm.qlItems.filter{ $0.Type.wrappedValue == "Header" }) { item1 in
                                        
                                        QLItem(item: item1, activeItem: $activeItem, activeLetter: $activeLetter, player: $player)
                                        
                                        ForEach($mvm.qlItems.filter { $0.Type.wrappedValue == "Section" && $0.headerID.wrappedValue == item1.headerID.wrappedValue }) { item2 in
                                            
                                            QLItem(item: item2, activeItem: $activeItem, activeLetter: $activeLetter, player: $player)
                                            
                                            if (item2.wrappedValue.headerID == activeItem || item2.wrappedValue.EmptyHeader) {
                                                
                                                ScrollView(.horizontal) {
                                                    
                                                    ForEach($mvm.qlItems.filter { ($0.Type.wrappedValue == "WordHeader" || $0.Type.wrappedValue == "Word") && $0.headerID.wrappedValue == item1.headerID.wrappedValue && $0.sectionID.wrappedValue == item2.id.wrappedValue } ) { item3 in
                                                        
                                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                                                            
                                                            QLItem(item: item3, activeItem: $activeItem, activeLetter: $activeLetter, player: $player)
                                                                .padding(.top, (
                                                                    $mvm.qlItems.first
                                                                    {
                                                                        ($0.Type.wrappedValue == "WordHeader" || $0.Type.wrappedValue == "Word") &&
                                                                        $0.headerID.wrappedValue == item1.headerID.wrappedValue &&
                                                                        $0.sectionID.wrappedValue == item2.id.wrappedValue
                                                                    }?.id == item3.wrappedValue.id
                                                                ) ? 0 : -8)
                                                        }
                                                    }
                                                }
                                                .background(Color(hex: "F3F3F3"))
                                                .padding(.leading, 12)
                                                .padding(.trailing, 12)
                                            }
                                        }
                                    }
                                }
                                
                                ForEach($mvm.qlItems.filter{ $0.Type.wrappedValue == "Voc" || $0.Type.wrappedValue == "Examples" }) { item in
                                    
                                    QLItem(item: item, activeItem: $activeItem, activeLetter: $activeLetter, player: $player)
                                }
                            }
                        }
                    }
                    .task(id: mvm.qlScrollTarget) {
                        
                        if (mvm.qlScrollTarget != -1) {
                                                        
                            scrollView.scrollTo(mvm.qlScrollTarget, anchor: .top)
                            
                            mvm.qlScrollTarget = -1
                        }
                    }
                }
                .padding(.top, (safeArea?.top ?? 0) + 1)
                .padding(.leading, safeArea?.left)
                .padding(.trailing, safeArea?.right)
                .frame(maxWidth: .infinity)
            }                        
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .clipShape(PageBottomOverflowClip(), style: FillStyle(antialiased: false))
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
        .onAppear {
            if let insets = UIApplication.shared.firstKeyWindow?.safeAreaInsets {
                safeArea = insets
            }
            
            activeItem = mvm.qlItems.first{ $0.Type == "Header" }?.id ?? -1
        }
        .onReceive(player.objectWillChange, perform: { _ in
                        
            if (!player.player.isPlaying) {
                activeLetter = -1
            }
        })
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
