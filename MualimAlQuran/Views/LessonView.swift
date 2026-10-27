import SwiftUI
//import AVFoundation

struct LessonView: View {
    
    @AppStorage("language") var currentLanguage = getLanguage()
    @EnvironmentObject var mvm: MainViewModel
    @EnvironmentObject var sheetVM: BottomSheetViewModel
    @Binding var lesson: ListModel
    
    @State var loader = true
    @State var header: ListModel?
    @State var activeLetter = 0
    @State var layoutPadding = 0.0
    @StateObject var player = Player()
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    var body: some View {
        
        GeometryReader { geo in
            
            let screenWidth = UIScreen.main.bounds.size.width - geo.safeAreaInsets.leading - geo.safeAreaInsets.trailing
            
            ZStack {
                
                AppBG()
                
                ScrollViewReader { scrollView in
                    
                    ScrollView {
                        
                        VStack(spacing: 0) {
                                  
                            VStack(spacing: 0) {
                                Spacer().frame(height: 10)
                                
                                Text(mvm.home.Lesson + " " + mvm.lessonSelected.Sort.description)
                                    .font(currentLanguage == "Ar" ? .system(size: 22, weight: .bold) : .custom("opensans", size: 22))
                                    .bold()
                                    .lineSpacing(8)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)
                                    .padding(.bottom, 5)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                                
                                Text(mvm.lessonSelected.Title.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: ""))
                                    .font(currentLanguage == "Ar" ? .system(size: 20, weight: .regular) : .custom("opensans", size: 20))
                                    .fontWeight(currentLanguage == "Ar" ? .regular : nil)
                                    .foregroundColor(colorResource.maroon)
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 15)
                                    .padding(.leading, 15)
                                    .padding(.trailing, 15)
                                
                                Button(action: { 
                                    AppHaptics.tap()
                                    sheetVM.sheetState.toggle()
                                    sheetVM.title = lesson.Title
                                    sheetVM.summary = lesson.Summary
                                }) {
                                    
                                    ZStack {
                                        
                                        Text(mvm.home.Instructions)
                                            .font(currentLanguage == "Ar" ? .system(size: 20, weight: .regular) : .custom("opensans", size: 20))
                                            .foregroundColor(colorResource.maroon)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(12)
                                        
                                        if (sheetVM.sheetState) {
                                            
                                            Image(systemName: "chevron.up")
                                                .frame(maxWidth:.infinity, alignment: .trailing)
                                                .padding(20)
                                                .tint(colorResource.lightButtonText)
                                        }
                                        else {
                                            
                                            Image(systemName: "chevron.down")
                                                .frame(maxWidth:.infinity, alignment: .trailing)
                                                .padding(20)
                                                .tint(colorResource.lightButtonText)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(colorResource.lightButton)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .shadow(color: Color(hex: "#cacaca"), radius: 1)
                                .padding(.bottom, 10)
//                                .sheet(isPresented: $sheetVM.sheetState) {
//                                    
//                                    if #available(iOS 16.0, *) {
//                                        BottomSheet().presentationDetents([.medium, .large])
//                                    } else {
//                                        BottomSheet()
//                                    }
//                                }
                            }
                            .padding(.leading, layoutPadding)
                            .padding(.trailing, layoutPadding)
                            
                            if (mvm.lessonItems.isEmpty) {
                                
                                if (mvm.loading) {
                                    ProgressView()
                                }
                                else {
                                    ProgressView().task {
                                        mvm.loadLessonItems()
                                        layoutPadding = lessonLayoutPadding()
                                    }
                                }
                            }
                            else {
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: lessonListAdaptive(lesson: lesson, screenWidth: screenWidth)), spacing: lessonListSpacedBy(lesson: lesson))], spacing: 0) {
                                    
                                    if (!$mvm.lessonItems.isEmpty) {
                                        
                                        if ($mvm.lessonItems[0].sectionID.wrappedValue != "") {
                                            
                                            ForEach($mvm.lessonItems.filter { $0.section.wrappedValue }) { sectionItem in
                                                
                                                Section(
                                                    
                                                    header: VStack {
                                                        
                                                        Spacer().frame(height:1) // Important: the list keeps dragging whne scrolling up to the header                                                        
                                                        let separatorItem = $mvm.lessonItems.filter { $0.sectionID.wrappedValue == sectionItem.sectionID.wrappedValue }[0]
                                                        
                                                        if (separatorItem.separator.wrappedValue) {
                                                            
                                                            if (!separatorItem.title1.wrappedValue.isEmpty) {
                                                                
                                                                Spacer().frame(height: 10)
                                                                
                                                                Text(separatorItem.title1.wrappedValue)
                                                                    .font(currentLanguage == "Ar" ? .system(size: 32, weight: .regular) : .custom("philosopher", size: 32))
                                                                    .multilineTextAlignment(.center)
                                                                    .lineSpacing(6)
                                                                    .foregroundColor(colorResource.maroon)
                                                                    .padding(15)
                                                                    .padding(.top, 25)
                                                                    .frame(maxWidth: .infinity)
                                                                
                                                                Image("ddh").padding(.bottom, 15)
                                                            }
                                                        }
                                                        
                                                    }.frame(maxWidth: .infinity),
                                                    
                                                    footer: Spacer().frame(height:10)) {
                                                        
                                                        ForEach($mvm.lessonItems.filter { $0.sectionID.wrappedValue == sectionItem.sectionID.wrappedValue }) { item in
                                                            
                                                            if (item.separator.wrappedValue) {
                                                                
                                                                
                                                            }
                                                            else {
                                                                
                                                                LessonItem(item: item, activeLetter: $activeLetter, player: player)
                                                            }
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity)
                                            }
                                        }
                                        else {
                                            
                                            ForEach($mvm.lessonItems) { item in
                                                
                                                LessonItem(item: item, activeLetter: $activeLetter, player: player)
                                            }
                                        }
                                    }
                                    
                                }
                                .padding(.leading, layoutPadding)
                                .padding(.trailing, layoutPadding)
                                .environment(\.layoutDirection, .rightToLeft)
                            }
                        }
                    }
                }
                .padding(.top, (safeArea?.top ?? 0) + 1)
                .padding(.leading, safeArea?.left)
                .padding(.trailing, safeArea?.right)
                .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true)
            .clipShape(PageBottomOverflowClip(), style: FillStyle(antialiased: false))
            .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
            .onAppear {
                if let insets = UIApplication.shared.firstKeyWindow?.safeAreaInsets {
                    safeArea = insets
                }
                
                layoutPadding = lessonLayoutPadding()
            }
            .onRotate { newOrientation in
                
                Task {
                    
                    for _ in 1...5 {
                        
                        try await Task.sleep(nanoseconds: 100_000_000)
                        layoutPadding = lessonLayoutPadding()
                        safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .task(id: player.playing) {
                if (!player.playing) {
                    activeLetter = 0
                }                
            }
            .onDisappear() {
                mvm.lessonItems[0].sectionID = ""
            }
        }
    }
}


