import SwiftUI

struct QLVocView: View {
    
    @AppStorage("language") var currentLanguage = getLanguage()
    @EnvironmentObject var mvm: MainViewModel
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
                        Text(mvm.lessonSelected.Title.components(separatedBy: "<span>")[0])
                            .font(currentLanguage == "Ar" ? .system(size: 22, weight: .bold) : .custom("opensans", size: 22))
                            .bold()
                            .lineSpacing(8)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        
                        Text(mvm.qlItems.first { $0.id == mvm.lessonSelected.Number + 100000 }!.Vocabularies)
                            .font(currentLanguage == "Ar" ? .system(size: 20, weight: .regular) : .custom("opensans", size: 20))
                            .foregroundColor(colorResource.maroon)
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        //endregion
                        
                        if (mvm.qlVocItems.isEmpty) {
                            
                            ProgressView()
                        }
                        else {
                            
                            ScrollView(.horizontal) {
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                                    
                                    if (mvm.lessonSelected.Number != 22) {
                                        
                                        HStack(spacing: 0)
                                        {
                                            
                                            ForEach(1...3, id: \.self) { i in
                                                
                                                var text: String {
                                                    
                                                    if (i == 2) {
                                                        return "Plural"
                                                    }
                                                    else if (i == 3) {
                                                        return "Meaning"
                                                    }
                                                    
                                                    return "Singular"
                                                }
                                                
                                                ZStack {
                                                    
                                                    Text(text)
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(colorResource.primary_500)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .padding(12)
                                                }
                                                .frame(width: 150)
                                                .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                        .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
                                    }
                                    
                                    ForEach($mvm.qlVocItems) { item in
                                        
                                        var proceed: Bool {
                                            
                                            if (qlVocCondition(item: item.wrappedValue)) {
                                                return false
                                            }
                                            
                                            return true
                                        }
                                        
                                        if (proceed) {
                                            
                                            HStack(spacing: 0)
                                            {
                                                
                                                ForEach(1...3, id: \.self) { i in
                                                    
                                                    var text: String {
                                                        
                                                        if (i == 2) {
                                                            return item.Plural.wrappedValue
                                                        }
                                                        else if (i == 3) {
                                                            return item.Meaning.wrappedValue
                                                        }
                                                        
                                                        return item.Singular.wrappedValue
                                                    }
                                                    var wordIndex: Int {
                                                        
                                                        if (i == 2) {
                                                            return item.WordIndex2.wrappedValue
                                                        }
                                                        
                                                        return item.WordIndex1.wrappedValue
                                                    }
                                                    
                                                    Button(action: {
                                                        if (text != "" && i != 3) {                                                            
                                                            activeLetter = wordIndex
                                                            qLPlay(index: wordIndex, voc: true, mvm: mvm, player: player)
                                                        }
                                                    }) {
                                                        
                                                        ZStack {
                                                            
                                                            var fontSize: Int {
                                                                
                                                                if (i == 3) {
                                                                    return 20
                                                                }
                                                                
                                                                return 30
                                                            }
                                                            
                                                            Text(text)
                                                                .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: CGFloat(fontSize)))
                                                                .foregroundStyle(.black)
                                                                .frame(maxWidth:.infinity)
                                                                .padding(12)
                                                            
                                                            if (text != "" && i != 3) {
                                                                QLItemLoader(index: wordIndex, activeLetter: $activeLetter)
                                                            }
                                                        }
                                                        .frame(width: 150)
                                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(.white)
                                            .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
                                        }
                                    }
                                }
                            }
                            
                            ScrollView(.horizontal) {
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 2000), spacing: itemSpacing, alignment: .leading)], spacing: 0) {
                                    
                                    if (qlVocConditionHeader(mvm: mvm)) {
                                        
                                        HStack(spacing: 0)
                                        {
                                            
                                            ForEach(1...4, id: \.self) { i in
                                                
                                                var text: String {
                                                    
                                                    if (i == 2) {
                                                        return "Imperfect"
                                                    }
                                                    else if (i == 3) {
                                                        return "Verbal Noun"
                                                    }
                                                    else if (i == 4) {
                                                        return "Meaning"
                                                    }
                                                    
                                                    return "Perfect"
                                                }
                                                
                                                ZStack {
                                                    
                                                    Text(text)
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(colorResource.primary_500)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(12)
                                                }
                                                .frame(width: 150)
                                                .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                        .padding(.top, 20)
                                        .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
                                    }
                                    
                                    ForEach($mvm.qlVocItems) { item in
                                        
                                        var proceed: Bool {
                                            
                                            if (qlVocCondition(item: item.wrappedValue)) {
                                                return true
                                            }
                                            
                                            return false
                                        }
                                        
                                        if (proceed) {
                                            
                                            HStack(spacing: 0)
                                            {
                                                
                                                ForEach(1...4, id: \.self) { i in
                                                    
                                                    var text: String {
                                                        
                                                        if (i == 2) {
                                                            return item.Plural.wrappedValue
                                                        }
                                                        else if (i == 3) {
                                                            return item.Meaning2.wrappedValue
                                                        }
                                                        else if (i == 4) {
                                                            return item.Meaning.wrappedValue
                                                        }
                                                        
                                                        return item.Singular.wrappedValue
                                                    }
                                                    var wordIndex: Int {
                                                        
                                                        if (i == 2) {
                                                            return item.WordIndex2.wrappedValue
                                                        }
                                                        else if (i == 3) {
                                                            return item.WordIndex3.wrappedValue
                                                        }
                                                        
                                                        return item.WordIndex1.wrappedValue
                                                    }
                                                    
                                                    Button(action: {
                                                        if (text != "" && i != 4) {
                                                            activeLetter = wordIndex
                                                            qLPlay(index: wordIndex, voc: true, vocSection2: true, mvm: mvm, player: player)
                                                        }
                                                    }) {
                                                        
                                                        ZStack {
                                                            
                                                            var fontSize: Int {
                                                                
                                                                if (i == 4) {
                                                                    return 20
                                                                }
                                                                
                                                                return 30
                                                            }
                                                            
                                                            Text(text)
                                                                .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: CGFloat(fontSize)))
                                                                .foregroundStyle(.black)
                                                                .frame(maxWidth:.infinity)
                                                                .padding(12)
                                                            
                                                            if (text != "" && i != 4) {
                                                                QLItemLoader(index: wordIndex, activeLetter: $activeLetter)
                                                            }
                                                        }
                                                        .frame(width: 150)
                                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(.white)
                                            .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
                                        }
                                    }
                                }
                            }
                            .background(Color(hex: "F3F3F3"))
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

func qlVocConditionHeader(mvm: MainViewModel) -> Bool {

    return ((8...13) ~= mvm.lessonSelected.Number) || ((15...40) ~= mvm.lessonSelected.Number)
}

func qlVocCondition(item: QLVocModel) -> Bool {

    return (item.QLID == "8" && item.id >= 224) ||
            (item.QLID == "9" && item.id >= 264) ||
            (item.QLID == "10" && item.id >= 309) ||
            (item.QLID == "11" && item.id >= 342) ||
            (item.QLID == "12" && item.id >= 375) ||
            (item.QLID == "13" && item.id >= 396) ||
            (item.QLID == "15" && item.id >= 414) ||
            (item.QLID == "16" && item.id >= 444) ||
            (item.QLID == "17" && item.id >= 460) ||
            (item.QLID == "18" && item.id >= 483) ||
            (item.QLID == "19" && item.id >= 413) ||
            (item.QLID == "20" && item.id >= 524) ||
            (item.QLID == "21" && item.id >= 541) ||
            (item.QLID == "22" && item.id >= 552) ||
            (item.QLID == "23" && item.id >= 583) ||
            (item.QLID == "24" && item.id >= 594) ||
            (item.QLID == "25" && item.id >= 636) ||
            (item.QLID == "26" && item.id >= 643) ||
            (item.QLID == "27" && item.id >= 670) ||
            (item.QLID == "28" && item.id >= 684) ||
            (item.QLID == "29" && item.id >= 711) ||
            (item.QLID == "30" && item.id >= 721) ||
            (item.QLID == "31" && item.id >= 748) ||
            (item.QLID == "32" && item.id >= 757) ||
            (item.QLID == "33" && item.id >= 764) ||
            (item.QLID == "34" && item.id >= 787) ||
            (item.QLID == "35" && item.id >= 814) ||
            (item.QLID == "36" && item.id >= 836) ||
            (item.QLID == "37" && item.id >= 868) ||
            (item.QLID == "38" && item.id >= 894) ||
            (item.QLID == "39" && item.id >= 913) ||
            (item.QLID == "40" && item.id >= 942)
}
