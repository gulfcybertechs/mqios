import SwiftUI

struct QLItem: View {
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    @Binding var item: QLModel    
    @Binding var activeItem: Int
    @Binding var activeLetter: Int
    @Binding var player: Player
    @State var text = ""
    
    @State var text1 = "Singular"
    @State var text2 = "Plural"
    @State var text3 = ""
    @State var text4 = ""
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    @State var wordHeight = CGFloat.zero
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if (item.Type == "Intro") {
                
                Text(item.Intro)
                    .foregroundStyle(colorResource.maroon)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(colorResource.lightButton)
                
                if (text.trim() != "") {
                    
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                }
            }
            
            if (item.Type == "Header") {
                
                if (item.StartOver) {
                    
                    Text(item.StartOverTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                }
                
                if (text.trim() == "") {
                    // No Action
                } else {
                    
                    VStack(spacing: 0)
                    {
                        
                        Button(action: {
                            
                            AppHaptics.tap()
                            if (activeItem == item.id) {
                                activeItem = -1
                            } else {
                                activeItem = item.id
                            }
                            
                            mvm.qlScrollTarget = item.id
                        })
                        {
                            
                            Text(item.headerTitleIndex.description + ". " + text)
                                .font(.system(size: 18))
                                .foregroundStyle(colorResource.maroon)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                            
                            Spacer()
                            
                            let icon = (item.id == activeItem) ? "chevron.up" : "chevron.down"
                            
                            Image(systemName: icon)
                                .foregroundStyle(colorResource.maroon)
                                .frame(width: 28, height: 28)
                        }
                        .scaleEffect(1)
                        
                        Divider().frame(height: 1).background(Color(hex: "D9D9D9"))
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F3F3F3"))
                    .padding(.leading, 12)
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                }
            }
            
            if (item.headerID == activeItem || item.EmptyHeader) {
                
                if (item.Type == "Section") {
                    
                    if (text.trim() != "") {
                        
                        let paddingTop = (item.id == mvm.qlItems.first { $0.Type == "Section" && $0.headerID == item.headerID }?.id) ? 6 : 0
                        
                        VStack(spacing: 0)
                        {
                            Text(text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                                .padding(.bottom, 6)
                            
                            if (item.Type == "Header") {
                                Divider().frame(height: 1).background(Color(hex: "F3F3F3"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, CGFloat(paddingTop))
                        .background(Color(hex: "F3F3F3"))
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                    }
                    else {
                        VStack(spacing: 0) { }
                        .frame(maxWidth: .infinity, minHeight: 12, maxHeight: 12)
                        .background(Color(hex: "F3F3F3"))
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                    }
                }
                
                let wordWidth = ((UIScreen.main.bounds.width - safeArea!.left - safeArea!.right) / 2) - 48
                
                if (item.Type == "WordHeader") {
                    
                    if ((mvm.lessonSelected.Number == 15) ||
                        (mvm.lessonSelected.Number == 30 && item.sectionID == 358) ||
                        (mvm.lessonSelected.Number == 33 && item.sectionID == 372) ||
                        (mvm.lessonSelected.Number == 33 && item.sectionID == 376) ||
                        (mvm.lessonSelected.Number == 33 && item.sectionID == 378)
                    ) {
                        
                        //QLItem15Header(item, scrollStateList)
                        
                    } else {
                        
                        if (headerCondition1(item: item, mvm: mvm) ||
                            headerCondition2(item: item) ||
                            headerCondition3(item: item) ||
                            headerCondition4(item: item) ||
                            headerCondition5(item: item) ||
                            headerCondition6(item: item) ||
                            headerCondition7(item: item) ||
                            headerCondition8(item: item)
                        ) {
                            
                            VStack(spacing: 0)
                            {
                                HStack(spacing: 0)
                                {
                                    Text(text1)
                                        .font(.system(size: 20))
                                        .foregroundStyle(colorResource.primary_500)
                                        .multilineTextAlignment(.center)
                                        //.fixedSize(horizontal: false, vertical: true)
                                        .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                        .padding(12)
                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                    
                                    if (headerCondition1(item: item, mvm: mvm) ||
                                        headerCondition2(item: item) ||
                                        headerCondition3Column(item: item) ||
                                        headerCondition4(item: item) ||
                                        headerCondition6(item: item) ||
                                        headerCondition7(item: item) ||
                                        headerCondition8(item: item)
                                    ) {
                                        Text(text2)
                                            .font(.system(size: 20))
                                            .foregroundStyle(colorResource.primary_500)
                                            .multilineTextAlignment(.center)
                                            //.fixedSize(horizontal: false, vertical: true)
                                            .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                            .padding(12)
                                            .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                    }
                                    
                                    if (headerCondition2Column(item: item) ||
                                        headerCondition3(item: item) ||
                                        headerCondition4(item: item) ||
                                        headerCondition6(item: item) ||
                                        headerCondition8(item: item)
                                    ) {
                                        Text(text3)
                                            .font(.system(size: 20))
                                            .foregroundStyle(colorResource.primary_500)
                                            .multilineTextAlignment(.center)
                                            //.fixedSize(horizontal: false, vertical: true)
                                            .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                            .padding(12)
                                            .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                    }
                                    
                                    if (headerCondition2(item: item)) {
                                        Text(text4)
                                            .font(.system(size: 20))
                                            .foregroundStyle(colorResource.primary_500)
                                            .multilineTextAlignment(.center)
                                            //.fixedSize(horizontal: false, vertical: true)
                                            .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                            .padding(12)
                                            .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
                                .background(.white)
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "F3F3F3"))
                            .onAppear() {
                                
                                if (headerCondition2(item: item)) {
                                    text1 = "Singular"
                                    text2 = ""
                                    text3 = "Dual"
                                    text4 = "Plural"
                                }
                                if (headerCondition3(item: item)) {
                                    text1 = "Indefinite"
                                    text2 = ""
                                    text3 = "Definite"
                                    text4 = ""
                                }
                                if (headerCondition4(item: item)) {
                                    text1 = "with masculine noun"
                                    text2 = ""
                                    text3 = "with feminine noun"
                                    text4 = ""
                                }
                                if (headerCondition5(item: item)) {
                                    text1 = "with both genders"
                                    text2 = ""
                                    text3 = ""
                                    text4 = ""
                                }
                                if (headerCondition6(item: item)) {
                                    text1 = "Masc"
                                    text2 = ""
                                    text3 = "Fem"
                                    text4 = ""
                                }
                                if (headerCondition7(item: item)) {
                                    text1 = "Imperative"
                                    text2 = "Jussive"
                                    text3 = ""
                                    text4 = ""
                                }
                                if (headerCondition8(item: item)) {
                                    text1 = "nom."
                                    text2 = "ace."
                                    text3 = "gen."
                                    text4 = ""
                                }
                            }
                        }
                    }
                }
                
                if (item.Type == "Word") {
                    
                    let bottomPadding = (item.lastWord) ? 16 : 0
                    
                    VStack(spacing: 0)
                    {
                        if ((mvm.lessonSelected.Number == 15) ||
                            (mvm.lessonSelected.Number == 30 && item.sectionID == 358) ||
                            (mvm.lessonSelected.Number == 33 && item.sectionID == 372) ||
                            (mvm.lessonSelected.Number == 33 && item.sectionID == 376) ||
                            (mvm.lessonSelected.Number == 33 && item.sectionID == 378)
                        ) {
                            
                            QLItem15(item: $item, activeLetter: $activeLetter, player: $player)
                            
                        } else {
                            
                            HStack(spacing: 0)
                            {
                                Button(action: {
                                    activeLetter = item.WordIndex
                                    qLPlay(index: item.WordIndex, mvm: mvm, player: player)
                                }) {
                                    ZStack
                                    {
                                        Text(text)
                                            .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 30))
                                            .foregroundStyle(.black)
                                            //.fixedSize(horizontal: true, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                            .padding(12)
                                        
                                        HStack(spacing: 0) {
                                            
                                            Spacer()
                                            
                                            VStack(spacing: 0) {
                                                
                                                Spacer()
                                                
                                                if (activeLetter == item.WordIndex) {
                                                    
                                                    ProgressView().tint(colorResource.maroon)
                                                        .frame(width: 18, height: 18)
                                                        .padding(2)
                                                    
                                                } else {
                                                    
                                                    Image(systemName: "play.circle.fill")
                                                        .foregroundStyle(colorResource.primary_500)
                                                        .frame(width: 18, height: 18)
                                                        .padding(2)
                                                }
                                            }
                                        }
                                    }
                                    .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                }
                                
//                                .onTapGesture {
//                                    
//                                }
                                
                                if (bodyCondition1(item: item)) {
                                    
                                    Text(item.Meaning.replacingOccurrences(of: "<br />", with: "\n").trim())
                                        .font(.system(size: 20))
                                        .multilineTextAlignment(.center)
                                        //.fixedSize(horizontal: false, vertical: true)
                                        .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                        .padding(12)
                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                }
                                
                                if (bodyCondition2(item: item)) {
                                    
                                    Button(action: {
                                        activeLetter = item.Meaning2Index
                                        qLPlay(index: item.Meaning2Index, mvm: mvm, player: player)
                                    }) {
                                        
                                        ZStack
                                        {
                                            
                                            Text(item.Meaning2.replacingOccurrences(of: "<br />", with: "\n").trim())
                                                .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 30))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                //.fixedSize(horizontal: false, vertical: true)
                                                .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                                .padding(12)
                                            
                                            HStack(spacing: 0) {
                                                
                                                Spacer()
                                                
                                                VStack(spacing: 0) {
                                                    
                                                    Spacer()
                                                    
                                                    if (activeLetter == item.Meaning2Index) {
                                                        
                                                        ProgressView().tint(colorResource.maroon)
                                                            .frame(width: 18, height: 18)
                                                            .padding(2)
                                                        
                                                    } else {
                                                        
                                                        Image(systemName: "play.circle.fill")
                                                            .foregroundStyle(colorResource.primary_500)
                                                            .frame(width: 18, height: 18)
                                                            .padding(2)
                                                    }
                                                }
                                            }
                                        }
                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                    }
                                }
                                
                                if (bodyCondition3(item: item, mvm: mvm)) {
                                    
                                    Button(action: {
                                        activeLetter = item.Word2Index
                                        qLPlay(index: item.Word2Index, mvm: mvm, player: player)
                                    }) {
                                        
                                        ZStack
                                        {
                                            Text(item.Word2.trim())
                                                .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 30))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                //.fixedSize(horizontal: false, vertical: true)
                                                .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                                .padding(12)
                                            
                                            HStack(spacing: 0) {
                                                
                                                Spacer()
                                                
                                                VStack(spacing: 0) {
                                                    
                                                    Spacer()
                                                    
                                                    if (activeLetter == item.Word2Index) {
                                                        
                                                        ProgressView().tint(colorResource.maroon)
                                                            .frame(width: 18, height: 18)
                                                            .padding(2)
                                                        
                                                    } else {
                                                        
                                                        Image(systemName: "play.circle.fill")
                                                            .foregroundStyle(colorResource.primary_500)
                                                            .frame(width: 18, height: 18)
                                                            .padding(2)
                                                    }
                                                }
                                            }
                                        }
                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                    }
                                }
                                else if (item.Meaning.trim() != "") {
                                    
                                    Text(item.Meaning.replacingOccurrences(of: "<br />", with: "\n").trim())
                                        .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 20))
                                        .multilineTextAlignment(.center)
                                        //.fixedSize(horizontal: false, vertical: true)
                                        .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                        .padding(12)
                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                }
                                
                                if (bodyCondition4(item: item)) {
                                    
                                    Text(item.Meaning2.replacingOccurrences(of: "<br />", with: "\n").trim())
                                        .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 20))
                                        .multilineTextAlignment(.center)
                                        //.fixedSize(horizontal: false, vertical: true)
                                        .frame(minWidth: wordWidth, maxWidth: wordWidth, maxHeight: .infinity)
                                        .padding(12)
                                        .overlay(Divider().frame(maxWidth: 1, maxHeight: .infinity), alignment: .trailing)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .overlay(Divider().frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
                            .padding(.leading, 12)
                            .padding(.trailing, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, CGFloat(bottomPadding))
                    .background(Color(hex: "F3F3F3"))
                }
            }
            
            if (item.Type == "Voc") {
                
                Button(action: {
                    
                    AppHaptics.tap()
                    mvm.loadQLVocItems(mvm: mvm)
                    navigation.push(.qlVocabulary, in: .home)
                    
                }) {
                    
                    
                    HStack()
                    {
                        
                        Text(item.Intro)
                            .foregroundStyle(colorResource.maroon)
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(colorResource.maroon)
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .scaleEffect(1)
                .background(colorResource.lightButton)
                .cornerRadius(10)
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .padding(.top, 18)
                .padding(.bottom, 6)
            }
            
            if (item.Type == "Examples") {
                
                Button(action: {
                    
                    AppHaptics.tap()
                    mvm.loadQLExItems(mvm: mvm)
                    navigation.push(.qlExamples, in: .home)
                    
                }) {
                    
                    
                    HStack()
                    {
                        
                        Text(item.Intro)
                            .foregroundStyle(colorResource.maroon)
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(colorResource.maroon)
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .scaleEffect(1)
                .background(colorResource.lightButton)
                .cornerRadius(10)
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .padding(.top, 12)
                .padding(.bottom, 18)
            }
        }
        .frame(maxWidth:.infinity)
        .onAppear() {
            text = item.IntroText
                .replacingOccurrences(of: "<span style=\"font-size: 40px;\">", with: "")
                .replacingOccurrences(of: "<span style=\"font-size: 40px;\">ٌ", with: "ٌ")
                .replacingOccurrences(of: "</span>", with: "")
                .replacingOccurrences(of: "<br />", with: "\n")
                .replacingOccurrences(of: "<br >", with: "\n")
                .replacingOccurrences(of: "<br>", with: "\n")
                .replacingOccurrences(of: "<b>", with: "")
                .replacingOccurrences(of: "</b>", with: "")
                .replacingOccurrences(of: "<ul>", with: "")
                .replacingOccurrences(of: "</ul>", with: "")
                .replacingOccurrences(of: "<ol>", with: "")
                .replacingOccurrences(of: "<ol start=\"2\">", with: "")
                .replacingOccurrences(of: "<ol start=\"3\">", with: "")
                .replacingOccurrences(of: "<ol start=\"4\">", with: "")
                .replacingOccurrences(of: "<ol start=\"5\">", with: "")
                .replacingOccurrences(of: "<ol start=\"6\">", with: "")
                .replacingOccurrences(of: "</ol>", with: "")
                .replacingOccurrences(of: "<li>", with: "- ")
                .replacingOccurrences(of: "</li>", with: "")
                .replacingOccurrences(of: "<p>", with: "")
                .replacingOccurrences(of: "</p>", with: "\n")
                .replacingOccurrences(of: "<div class=\"text-center\">", with: "\n")
                .replacingOccurrences(of: "</div>", with: "").trim()
        }
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

//region Header Condition 1
func headerCondition1(item: QLModel, mvm: MainViewModel) -> Bool {

    return (mvm.lessonSelected.Number == 2 && item.sectionID < 26)
}
//endregion

//region Header Condition 2
func headerCondition2(item: QLModel) -> Bool {

    return item.sectionID == 79 ||
            item.sectionID == 121 ||
            item.sectionID == 128 ||
            item.sectionID == 173 ||
            item.sectionID == 178 ||
            item.sectionID == 200 ||
            item.sectionID == 209 ||
            item.sectionID == 229 ||
            item.sectionID == 230 ||
            item.sectionID == 237 ||
            item.sectionID == 238 ||
            item.sectionID == 239 ||
            item.sectionID == 245 ||
            item.sectionID == 313 ||
            item.sectionID == 314 ||
            item.sectionID == 315 ||
            item.sectionID == 316 ||
            item.sectionID == 317 ||
            item.sectionID == 318 ||
            item.sectionID == 320 ||
            item.sectionID == 321 ||
            item.sectionID == 345 ||
            item.sectionID == 346 ||
            item.sectionID == 347 ||
            item.sectionID == 348 ||
            item.sectionID == 349 ||
            item.sectionID == 350 ||
            item.sectionID == 351 ||
            item.sectionID == 352 ||
            item.sectionID == 353 ||
            item.sectionID == 354 ||
            item.sectionID == 355 ||
            item.sectionID == 356
}
//endregion

//region Header Condition 2 Column
func headerCondition2Column(item: QLModel) -> Bool {

    return item.sectionID == 173 ||
            item.sectionID == 178 ||
            item.sectionID == 200 ||
            item.sectionID == 209 ||
            item.sectionID == 229 ||
            item.sectionID == 230 ||
            item.sectionID == 237 ||
            item.sectionID == 238 ||
            item.sectionID == 239 ||
            item.sectionID == 245 ||
            item.sectionID == 313 ||
            item.sectionID == 314 ||
            item.sectionID == 315 ||
            item.sectionID == 316 ||
            item.sectionID == 318 ||
            item.sectionID == 319 ||
            item.sectionID == 320 ||
            item.sectionID == 321 ||
            item.sectionID == 345 ||
            item.sectionID == 346 ||
            item.sectionID == 347 ||
            item.sectionID == 348 ||
            item.sectionID == 349 ||
            item.sectionID == 350 ||
            item.sectionID == 351 ||
            item.sectionID == 352 ||
            item.sectionID == 353 ||
            item.sectionID == 354 ||
            item.sectionID == 355 ||
            item.sectionID == 356
}
//endregion

//region Header Condition 3
func headerCondition3(item: QLModel) -> Bool {

    return item.sectionID == 32 ||
            item.sectionID == 36 ||
            item.sectionID == 37 ||
            item.sectionID == 38 ||
            item.sectionID == 39 ||
            item.sectionID == 40 ||
            item.sectionID == 41 ||
            item.sectionID == 42 ||
            item.sectionID == 43 ||
            item.sectionID == 132 ||
            item.sectionID == 133
}
//endregion

//region Header Condition 3 Column
func headerCondition3Column(item: QLModel) -> Bool {

    return item.sectionID == 36 ||
            item.sectionID == 37 ||
            item.sectionID == 38 ||
            item.sectionID == 39 ||
            item.sectionID == 40 ||
            item.sectionID == 41 ||
            item.sectionID == 42 ||
            item.sectionID == 43 ||
            item.sectionID == 132 ||
            item.sectionID == 133
}
//endregion

//region Header Condition 4
func headerCondition4(item: QLModel) -> Bool {

    return item.sectionID == 146
}
//endregion

//region Header Condition 5
func headerCondition5(item: QLModel) -> Bool {

    return item.sectionID == 147
}
//endregion

//region Header Condition 6
func headerCondition6(item: QLModel) -> Bool {

    return item.sectionID == 360
}
//endregion

//region Header Condition 7
func headerCondition7(item: QLModel) -> Bool {

    return item.sectionID == 364 ||
            item.sectionID == 366 ||
            item.sectionID == 367 ||
            item.sectionID == 368 ||
            item.sectionID == 369
}
//endregion

//region Header Condition 8
func headerCondition8(item: QLModel) -> Bool {

    return item.sectionID == 383 || item.sectionID == 388
}
//endregion


//region Body Condition 1
func bodyCondition1(item: QLModel) -> Bool {

    return ((36...44) ~= item.sectionID) ||
            item.sectionID == 63 ||
            item.sectionID == 79 ||
            item.sectionID == 97 ||
            item.sectionID == 121 ||
            item.sectionID == 128 ||
            item.sectionID == 132 ||
            item.sectionID == 133 ||
            item.sectionID == 146 ||
            item.sectionID == 173 ||
            item.sectionID == 178 ||
            item.sectionID == 200 ||
            item.sectionID == 209 ||
            item.sectionID == 229 ||
            item.sectionID == 230 ||
            item.sectionID == 237 ||
            item.sectionID == 238 ||
            item.sectionID == 239 ||
            item.sectionID == 245 ||
            item.sectionID == 313 ||
            item.sectionID == 314 ||
            item.sectionID == 315 ||
            item.sectionID == 316 ||
            item.sectionID == 318 ||
            item.sectionID == 319 ||
            item.sectionID == 320 ||
            item.sectionID == 321 ||
            item.sectionID == 345 ||
            item.sectionID == 346 ||
            item.sectionID == 347 ||
            item.sectionID == 348 ||
            item.sectionID == 349 ||
            item.sectionID == 350 ||
            item.sectionID == 351 ||
            item.sectionID == 352 ||
            item.sectionID == 353 ||
            item.sectionID == 354 ||
            item.sectionID == 355 ||
            item.sectionID == 356 ||
            item.sectionID == 360 ||
            item.sectionID == 388
}
//endregion

//region Body Condition 2
func bodyCondition2(item: QLModel) -> Bool {

    return (item.sectionID == 173 ||
            item.sectionID == 178 ||
            item.sectionID == 200 ||
            item.sectionID == 209 ||
            item.sectionID == 229 ||
            item.sectionID == 230 ||
            item.sectionID == 237 ||
            item.sectionID == 238 ||
            item.sectionID == 239 ||
            item.sectionID == 245 ||
            item.sectionID == 313 ||
            item.sectionID == 314 ||
            item.sectionID == 315 ||
            item.sectionID == 316 ||
            item.sectionID == 318 ||
            item.sectionID == 319 ||
            item.sectionID == 320 ||
            item.sectionID == 321 ||
            item.sectionID == 345 ||
            item.sectionID == 346 ||
            item.sectionID == 347 ||
            item.sectionID == 348 ||
            item.sectionID == 349 ||
            item.sectionID == 350 ||
            item.sectionID == 351 ||
            item.sectionID == 352 ||
            item.sectionID == 353 ||
            item.sectionID == 354 ||
            item.sectionID == 355 ||
            item.sectionID == 356 ||
            item.sectionID == 383 ||
            item.sectionID == 388)
}
//endregion

//region Body Condition 3
func bodyCondition3(item: QLModel, mvm: MainViewModel) -> Bool {

    return ((mvm.lessonSelected.Number == 2 && item.sectionID < 26) ||
            item.sectionID == 32 ||
            item.sectionID == 36 ||
            item.sectionID == 37 ||
            item.sectionID == 38 ||
            item.sectionID == 39 ||
            item.sectionID == 40 ||
            item.sectionID == 41 ||
            item.sectionID == 42 ||
            item.sectionID == 43 ||
            item.sectionID == 44 ||
            item.sectionID == 63 ||
            item.sectionID == 79 ||
            item.sectionID == 97 ||
            item.sectionID == 121 ||
            item.sectionID == 128 ||
            item.sectionID == 132 ||
            item.sectionID == 133 ||
            item.sectionID == 146 ||
            item.sectionID == 173 ||
            item.sectionID == 178 ||
            item.sectionID == 200 ||
            item.sectionID == 209 ||
            item.sectionID == 229 ||
            item.sectionID == 230 ||
            item.sectionID == 237 ||
            item.sectionID == 238 ||
            item.sectionID == 239 ||
            item.sectionID == 245 ||
            item.sectionID == 280 ||
            item.sectionID == 281 ||
            item.sectionID == 282 ||
            item.sectionID == 313 ||
            item.sectionID == 314 ||
            item.sectionID == 315 ||
            item.sectionID == 316 ||
            item.sectionID == 318 ||
            item.sectionID == 319 ||
            item.sectionID == 320 ||
            item.sectionID == 321 ||
            item.sectionID == 345 ||
            item.sectionID == 346 ||
            item.sectionID == 347 ||
            item.sectionID == 348 ||
            item.sectionID == 349 ||
            item.sectionID == 350 ||
            item.sectionID == 351 ||
            item.sectionID == 352 ||
            item.sectionID == 353 ||
            item.sectionID == 354 ||
            item.sectionID == 355 ||
            item.sectionID == 356 ||
            item.sectionID == 360 ||
            item.sectionID == 364 ||
            item.sectionID == 366 ||
            item.sectionID == 367 ||
            item.sectionID == 368 ||
            item.sectionID == 369 ||
            item.sectionID == 383 ||
            item.sectionID == 388)
}
//endregion

//region Body Condition 4
func bodyCondition4(item: QLModel) -> Bool {

    return (item.sectionID == 44 ||
            item.sectionID == 63 ||
            item.sectionID == 76 ||
            item.sectionID == 89 ||
            item.sectionID == 90 ||
            item.sectionID == 93 ||
            item.sectionID == 97 ||
            item.sectionID == 135 ||
            item.sectionID == 140 ||
            item.sectionID == 156 ||
            item.sectionID == 257 ||
            item.sectionID == 262)
}
//endregion
