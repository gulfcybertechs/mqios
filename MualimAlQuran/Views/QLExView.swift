import SwiftUI

struct QLExView: View {
    
    @AppStorage("language") var currentLanguage = getLanguage()
    @EnvironmentObject var mvm: MainViewModel
    @State var activeLetter = -1
    @State var activeVerse = ""
    @State var layoutPadding = 0.0
    @State var itemSpacing = 0.0
    @State var player = Player()
    @State var audioHelper: AudioHelper = AudioHelper(player: .constant(Player()))
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    var body: some View {
        
        ZStack {
            
            AppBG()
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        Spacer().frame(height: 10)
                        Text(mvm.lessonSelected.Title.components(separatedBy: "<span>")[0])
                            .font(currentLanguage == "Ar" ? .system(size: 22, weight: .bold) : .custom("opensans", size: 22))
                            .bold()
                            .lineSpacing(8)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        
                        Text(mvm.qlItems.first { $0.id == mvm.lessonSelected.Number + 100000 }!.Examples)
                            .font(currentLanguage == "Ar" ? .system(size: 20, weight: .regular) : .custom("opensans", size: 20))
                            .foregroundColor(colorResource.maroon)
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        //endregion
                        
                        if (mvm.qlExItems.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                                
                                ForEach($mvm.qlExItems.indices, id: \.self) { index in
                                    
                                    let item = $mvm.qlExItems[index].wrappedValue
                                    
                                    Button(action: {
                                        AppHaptics.tap()
                                        
                                        activeLetter = index
                                        
                                        let Surah = item.Verse.trim().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ":")[0].description
                                        let Ayah = item.Verse.trim().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ":")[1].description

                                        let selectedVerseAudioFileName = audioHelper.audioName(name: Surah) + "" + audioHelper.audioName(name: Ayah) + ".mp3"

                                        audioHelper.downloadVerse(
                                            fileName: "/recitation/2/\(selectedVerseAudioFileName)",
                                            url: URL(string: "https://mualim-alquran.com/recitation/2/\(selectedVerseAudioFileName)")!
                                        ) {

                                            audioHelper.playVerse(audioFileName: "/recitation/2/\(selectedVerseAudioFileName)") {

                                                activeLetter = -1
                                            }
                                        }
                                    }) {
                                        
                                        ZStack {
                                            
                                            VStack(spacing: 0) {
                                                
                                                var verse: AttributedString {
                                                    
                                                    var attributedString = AttributedString(item.VerseText)
                                                    
                                                    if let range = attributedString.range(of: item.Value) {
                                                        attributedString[range].foregroundColor = Color(hex: "FF9e00")
                                                    }
                                                    
                                                    return attributedString
                                                }
                                                
                                                Text(verse)
                                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                                    .foregroundStyle(.black)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                
                                                Text(item.VerseTranslation)
                                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 24))
                                                    .foregroundStyle(.black)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .environment(\.layoutDirection, .leftToRight)
                                                
                                                QLItemLoader(index: index, activeLetter: $activeLetter)
                                            }
                                            .padding(5)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.clear)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(.white)
                                    .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
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
