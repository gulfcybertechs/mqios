import SwiftUI

struct TajweedExView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @State var activeLetter = -1
    @State var layoutPadding = 0.0
    @State var itemSpacing = 0.0
    @State var player = Player()
    @State var audioHelper: AudioHelper = AudioHelper(player: .constant(Player()))
    @AppStorage("language") var currentLanguage = getLanguage()
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
                        
                        var subTitle: String {
                            if (mvm.lessonSelected.Number == 25) {
                                return mvm.lessonSelected.Title.components(separatedBy: "<span>")[0]
                            }
                            else {
                                return mvm.tajweedItems.first { $0.id == mvm.lessonSelected.Number }!.Examples
                            }
                        }
                        
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
                        
                        if (mvm.tajweedExItems.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            ScrollViewReader { scrollView1 in
                                
                                ScrollView(.horizontal) {
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                                        
                                        if (mvm.lessonSelected.Number == 1 ||
                                            mvm.lessonSelected.Number == 2 ||
                                            mvm.lessonSelected.Number == 3 ||
                                            mvm.lessonSelected.Number == 4 ||
                                            mvm.lessonSelected.Number == 5 ||
                                            mvm.lessonSelected.Number == 9 ||
                                            mvm.lessonSelected.Number == 10 ||
                                            mvm.lessonSelected.Number == 23 ||
                                            mvm.lessonSelected.Number == 24) {
                                            
                                            VStack(spacing: 0) {
                                                
                                                HStack(spacing: 0) {
                                                    
                                                    ForEach(0..<mvm.tajweedSelectedSetup.ColumnCount, id: \.self) { col in
                                                        
                                                        TajweedExampleHeader(col: col)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                                
                                                Divider().frame(height: 1).background(Color(hex: "DAE1A0"))
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        
                                        ForEach($mvm.tajweedExItems.indices, id: \.self) { index in
                                            
                                            let i = ((index / mvm.tajweedSelectedSetup.ColumnCount) * mvm.tajweedSelectedSetup.ColumnCount)
                                            if ((index % mvm.tajweedSelectedSetup.ColumnCount) == 0) {
                                                
                                                VStack(spacing: 0) {
                                                    
                                                    if (index == 0) {
                                                        
                                                        if (mvm.lessonSelected.Number != 1 &&
                                                            mvm.lessonSelected.Number != 2 &&
                                                            mvm.lessonSelected.Number != 3 &&
                                                            mvm.lessonSelected.Number != 4 &&
                                                            mvm.lessonSelected.Number != 5 &&
                                                            mvm.lessonSelected.Number != 9 &&
                                                            mvm.lessonSelected.Number != 10 &&
                                                            mvm.lessonSelected.Number != 23 &&
                                                            mvm.lessonSelected.Number != 24) {
                                                            
                                                            Divider().frame(height: 1).background(Color(hex: "DAE1A0"))
                                                        }
                                                    }
                                                    
                                                    HStack(spacing: 0) {
                                                        
                                                        ForEach(0..<mvm.tajweedSelectedSetup.ColumnCount, id: \.self) { col in
                                                            
                                                            TajweedExampleBody(example: mvm.tajweedExItems[i + col], col: col, activeLetter: $activeLetter, player: $player, audioHelper: $audioHelper)
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    
                                                    Divider().frame(height: 1).background(Color(hex: "DAE1A0"))
                                                }
                                                .frame(maxWidth: .infinity)
                                            }
                                        }
                                    }
                                    .padding(.leading, layoutPadding)
                                    .padding(.trailing, layoutPadding)
                                }
                                .onAppear() {
                                    
                                    if (currentLanguage == "Ar") {
                                        scrollView1.scrollTo(0)
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
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .clipShape(PageBottomOverflowClip(), style: FillStyle(antialiased: false))
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
        .onAppear {
            if let insets = UIApplication.shared.firstKeyWindow?.safeAreaInsets {
                safeArea = insets
            }
            
            audioHelper = AudioHelper(player: $player)
            
            layoutPadding = mainLayoutPadding(items: mvm.stageLessons)
            itemSpacing = listItemSpacing(items: mvm.stageLessons)
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
                    layoutPadding = mainLayoutPadding(items: mvm.stageLessons)
                    itemSpacing = listItemSpacing(items: mvm.stageLessons)
                    safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
                }
            }
        }
    }
}
