import SwiftUI
import SwiftSoup

struct TajweedExampleBody: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @State var example: TajweedExModel
    @State var col: Int
    @Binding var activeLetter: Int
    @Binding var player: Player
    @Binding var audioHelper: AudioHelper
    
    @State var text = ""

    @State var width = 60.0
    @State var background = colorResource.lightButton
    @State var fontSize = 40
    @State var showPlay = true
    @State var show = true
    @State var vowel = " ْ "
    @State var x = 0.0
    @State var y = 0.0
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
            
        VStack(spacing: 0) {
            
            if (show) {
                
                VStack(spacing: 0) {
                    
                    let data = try! SwiftSoup.parse("<p>\(exValue(value: text))</p>").body()?.getAllElements()
                    
                    var newData: AttributedString {
                        
                        var str = AttributedString("")
                        
                        data!.forEach { it in
                            
                            let value = (try? it.text()) ?? ""
                            
                            if (value != "") {
                                
                                if (it.nodeName() == "p") {
                                    
                                    let childNodes = try! it.getAllElements()
                                    
                                    childNodes.forEach { it1 in
                                        
                                        var value1 = (try? it1.text()
                                            .replacingOccurrences(of: "One Word", with: mvm.home.OneWord)
                                            .replacingOccurrences(of: "Two Words", with: mvm.home.TwoWords)
                                        ) ?? ""
                                        
                                        if (currentLanguage == "Ar") {
                                            value1 = (try? it1.text()
                                                .replacingOccurrences(of: "Noon Saakin", with: "النون الساكنة")
                                                .replacingOccurrences(of: "Tanween", with: "التنوين")
                                            ) ?? ""
                                        }
                                        
                                        if (it1.nodeName() == "p") {
                                            str.append(AttributedString(value1))
                                        }
                                        
                                        if (it1.nodeName() == "span") {
                                            
                                            if let range = str.range(of: value1) {
                                                str[range].foregroundColor = Color(hex: "FF9e00")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if (mvm.lessonSelected.Number == 25) {
                            
                            var space: String {
                                
                                if (example.id == 3 || example.id == 5 || example.id == 9) {
                                    return "  "
                                }
                                
                                return ""
                            }
                            
                            
                            return AttributedString(
                                text
                                    .replacingOccurrences(of: "<span class=\"english\">", with: "")
                                    .replacingOccurrences(of: "</span>", with: "")
                                    .replacingOccurrences(of: "\n", with: "")
                                    .replacingOccurrences(of: "<br />", with: "\n")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=7&a=206\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=13&a=15\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=16&a=50\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=17&a=109\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=19&a=58\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=22&a=77\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=25&a=60\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=27&a=26\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=32&a=15\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=38&a=24\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=41&a=38\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=53&a=62\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=84&a=21\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "<a href=\"/verse-by-verse-full-qur'an?s=96&a=19\" target=\"_blank\">", with: "")
                                    .replacingOccurrences(of: "</a>", with: "") + space
                            )
                        }
                        
                        return str
                    }
                    
                    ZStack {
                        
                        HStack(spacing: 0) {
                            
                            if (mvm.lessonSelected.Number == 25) {
                                Text(newData)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: CGFloat(fontSize)))
                                    .multilineTextAlignment((col != 0) ? .leading : .center)
                                    .frame(maxWidth: .infinity, maxHeight: (example.Value.contains("over-size")) ? 70 : .infinity,
                                           alignment: (col != 0) ? .leading : .center)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                    .offset(x: (example.id == 3 || example.id == 5) ? 25 : 0)
                                    .offset(y: (example.id == 3 || example.id == 5) ? 65 : 0)
                                    .offset(x: (example.id == 9) ? 10 : 0)
                                    .offset(y: (example.id == 9) ? 40 : 0)
                            }
                            else {
                                                                
                                Text(newData)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: CGFloat(fontSize)))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                            }
                        }
                        .environment(\.layoutDirection, (mvm.lessonSelected.Number == 25 && col == 1 && currentLanguage != "Ar") ? .leftToRight : .rightToLeft)
                        
                        if (text.contains("absolute")) {
                            
                            HStack(spacing: 0) {
                                
                                Text(vowel)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                    .foregroundColor(colorResource.orange)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                    .offset(x: x, y: y)
                                
                                Text(newData)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                    .opacity(0)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        if (showPlay) {

                            HStack(spacing: 0) {
                                
                                VStack(spacing: 0) {
                                    
                                    Spacer()
                                    
                                    if (activeLetter == example.id) {
                                        
                                        ProgressView().tint(colorResource.maroon)
                                        
                                    } else {
                                        
                                        Image(systemName: "play.circle.fill")
                                            .foregroundStyle(colorResource.primary_500)
                                            .frame(width: 18)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                }
                .frame(width: ((mvm.lessonSelected.Number == 6) ||
                               (mvm.lessonSelected.Number == 7) ||
                               (mvm.lessonSelected.Number == 12) ||
                               (mvm.lessonSelected.Number == 13) ||
                               (mvm.lessonSelected.Number == 14) ||
                               (mvm.lessonSelected.Number == 16) ||
                               (mvm.lessonSelected.Number == 17) ||
                               (mvm.lessonSelected.Number == 18) ||
                               (mvm.lessonSelected.Number == 19) ||
                               (mvm.lessonSelected.Number == 20) ||
                               (mvm.lessonSelected.Number == 21) ||
                               (mvm.lessonSelected.Number == 22)
                              ) ? UIScreen.main.bounds.size.width : width)
                .padding(5)
                .background(background)
                .onTapGesture {
                    
                    if (showPlay) {
                        
                        activeLetter = example.id
                        
                        if (example.Type == "Letter") {
                            
                            letterPlayByName(name: example.Audio1, player: player)
                            
                        } else {
                            
                            let verseAudio = "/recitation/2/\(example.Verse)"                                                        
                            
                            audioHelper.downloadVerse(
                                fileName: verseAudio,
                                url: URL(string: "https://mualim-alquran.com/\(verseAudio)")!
                            ) {
                                
                                DispatchQueue.main.async {
                                    
                                    audioHelper.playVerse(audioFileName: verseAudio) {
                                        
                                        activeLetter = -1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear() {
            
            text = example.Value
            
            if (col == 0) {
                if (mvm.lessonSelected.Number == 9 ||
                    mvm.lessonSelected.Number == 10 ||
                    mvm.lessonSelected.Number == 11 ||
                    mvm.lessonSelected.Number == 12 ||
                    mvm.lessonSelected.Number == 13 ||
                    mvm.lessonSelected.Number == 14 ||
                    mvm.lessonSelected.Number == 15 ||
                    mvm.lessonSelected.Number == 16 ||
                    mvm.lessonSelected.Number == 17 ||
                    mvm.lessonSelected.Number == 18 ||
                    mvm.lessonSelected.Number == 19 ||
                    mvm.lessonSelected.Number == 20 ||
                    mvm.lessonSelected.Number == 21 ||
                    mvm.lessonSelected.Number == 22 ||
                    mvm.lessonSelected.Number == 23 ||
                    mvm.lessonSelected.Number == 24
                ) {
                    width = 250
                    background = colorResource.transparent
                }
            }
            if (col != 0) {
                width = 250
                background = colorResource.transparent
            }
            
            
            if ((mvm.lessonSelected.Number == 2 && col == 1) ||
                (mvm.lessonSelected.Number == 3 && col == 1) ||
                (mvm.lessonSelected.Number == 4 && col == 1)
            ) {
                width = 160
                fontSize = 20
                showPlay = false
            }
            
            if (mvm.lessonSelected.Number == 25) {
                showPlay = false
                text = example.Value
                    .replacingOccurrences(of: "&nbsp;<span class=\"over-size\">", with: "")
                    .replacingOccurrences(of: "</span>", with: "")
            }
            
            if (mvm.lessonSelected.Number == 25 && col == 0) {
                width = 60
            }
            
            if (mvm.lessonSelected.Number == 25 && col == 1) {
                width = 700
                fontSize = 20
            }
                        
            if (example.Value.contains("over-size")) {
                showPlay = false
                fontSize = 90

                if (example.id == 9) {
                    fontSize = 80
                    text = "ۛ ۛ"
                }
            }
            
            if ((mvm.lessonSelected.Number == 6 && col == 0) ||
                (mvm.lessonSelected.Number == 7 && col == 0) ||
                (mvm.lessonSelected.Number == 8 && col == 0)
            ) {
                show = false
            }
            
            if (text.contains("absolute")) {
                
                if (text.contains("<span class=\"color absolute\">ً</span>")) {
                    vowel = " ً "
                }
                if (text.contains("<span class=\"color absolute\">ٌ</span>")) {
                    vowel = " ٌ "
                }
                if (text.contains("<span class=\"color absolute\">ٍ</span>")) {
                    vowel = " ٍ "
                }
                if (text.contains("<span class=\"color absolute\">َ</span>")) {
                    vowel = " َ "
                }
                if (text.contains("<span class=\"color absolute\">ُ</span>")) {
                    vowel = " ُ "
                }
                if (text.contains("<span class=\"color absolute\">ِ</span>")) {
                    vowel = " ِ "
                }
                if (text.contains("<span class=\"color absolute\">ۢ</span>")) {
                    vowel = " ۢ "
                }
                if (text.contains("<span class=\"color absolute\">ُۢ</span>")) {
                    vowel = " ُۢ "
                }
                if (text.contains("<span class=\"color absolute\">َۢ</span>")) {
                    vowel = " َۢ "
                }
                if (text.contains("<span class=\"color absolute\">ٰ</span>")) {
                    vowel = " ٰ "
                }
                if (text.contains("<span class=\"color absolute\">ٰٓ</span>")) {
                    vowel = " ٰٓ "
                }
                
                //region Offset L1
                if (mvm.lessonSelected.Number == 1) {
                    
                    switch (example.id) {
                        
                    case 2 : do {
                        x = 40
                        y = -10
                    }
                        
                    case 3: do {
                        x = 34
                        y = -4
                    }
                        
                    case 4 : do {
                        x = 48
                    }
                        
                    case 6 : do {
                        x = 35
                        y = -8
                    }
                        
                    case 7 : do {
                        x = 28
                        y = -12
                    }
                        
                    case 8 : do {
                        x = 65
                    }
                        
                    case 10 : do {
                        x = 22
                        y = -10
                    }
                        
                    case 11 : do {
                        x = 36
                        y = -4
                    }
                        
                    case 12 : do {
                        x = 68
                        y = 20
                    }
                        
                    case 14 : do {
                        x = 24
                        y = -8
                    }
                        
                    case 15 : do {
                        x = 36
                        y = -4
                    }
                        
                    case 16 : do {
                        x = 38
                    }
                        
                    case 18 : do {
                        x = 64
                        y = -8
                    }
                        
                    case 19 : do {
                        x = 36
                        y = -4
                    }
                        
                    case 20 : do {
                        x = 45
                    }
                        
                    case 22 : do {
                        x = 60
                        y = -8
                    }
                        
                    case 23 : do {
                        x = 36
                        y = -4
                    }
                        
                    case 24 : do {
                        x = 62
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L2
                if (mvm.lessonSelected.Number == 2) {
                    
                    switch (example.id) {
                    case 7 : do {
                        x = 44
                        y = -18
                    }
                        
                    case 8 : do {
                        x = 44
                        y = -18
                    }
                        
                    case 15 : do {
                        x = 50
                        y = 0
                    }
                        
                    case 16 : do {
                        x = 50
                        y = 0
                    }
                        
                    case 23 : do {
                        x = 58
                        y = 30
                    }
                        
                    case 24 : do {
                        x = 58
                        y = 30
                    }
                        
                    case 31 : do {
                        x = 70
                        y = 20
                    }
                        
                    case 32 : do {
                        x = 70
                        y = 20
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L3
                if (mvm.lessonSelected.Number == 3) {
                    
                    switch (example.id) {
                    case 7 : do {
                        x = 86
                        y = -16
                    }
                        
                    case 8 : do {
                        x = 86
                        y = -16
                    }
                        
                    case 15 : do {
                        x = 65
                        y = 0
                    }
                        
                    case 16 : do {
                        x = 65
                        y = 0
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L4
                if (mvm.lessonSelected.Number == 4) {
                    
                    switch (example.id) {
                    case 3 : do {
                        x = 36
                    }
                        
                    case 7 : do {
                        x = 24
                    }
                        
                    case 11 : do {
                        x = 36
                        y = 8
                    }
                        
                    case 15 : do {
                        x = 62
                        y = 8
                    }
                        
                    case 19 : do {
                        x = 52
                        y = -16
                    }
                        
                    case 23 : do {
                        x = 38
                        y = -5
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L5
                if (mvm.lessonSelected.Number == 5) {
                    
                    switch (example.id) {
                    case 3 : do {
                        x = 74
                        y = -6
                    }
                        
                    case 6 : do {
                        x = 40
                        y = -6
                    }
                        
                    case 9 : do {
                        x = 65
                        y = -8
                    }
                        
                    case 12 : do {
                        x = 64
                        y = -6
                    }
                        
                    case 15 : do {
                        x = 44
                        y = 0
                    }
                        
                    case 18 : do {
                        x = 74
                        y = -4
                    }
                        
                    case 21 : do {
                        x = 52
                        y = 18
                    }
                        
                    case 24 : do {
                        x = 74
                        y = -6
                    }
                        
                    case 27 : do {
                        x = 44
                        y = 36
                    }
                        
                    case 30 : do {
                        x = 48
                        y = -14
                    }
                        
                    case 33 : do {
                        x = 56
                        y = 18
                    }
                        
                    case 36 : do {
                        x = 68
                        y = 30
                    }
                        
                    case 39 : do {
                        x = 68
                        y = 22
                    }
                        
                    case 42 : do {
                        x = 72
                        y = 4
                    }
                        
                    case 45 : do {
                        x = 86
                        y = -10
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L15
                if (mvm.lessonSelected.Number == 15) {
                    
                    switch (example.id) {
                    case 5 : do {
                        x = 44
                        y = -2
                    }
                        
                    case 6 : do {
                        x = 50
                        y = -2
                    }
                        
                    case 7 : do {
                        x = 58
                        y = -10
                    }
                        
                    case 8 : do {
                        x = 102
                        y = -2
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L19
                if (mvm.lessonSelected.Number == 19) {
                    
                    switch (example.id) {
                    case 6 : do {
                        x = 84
                        
                    }
                    case 5 : do {
                        x = 70
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                //region Offset L21
                if (mvm.lessonSelected.Number == 21) {
                    
                    switch (example.id) {
                    case 2 : do {
                        x = 52
                    }
                    default:
                        break
                    }
                }
                //endregion
                
                x += 5
                y -= 15
            }
            
        }
        
        if (col != mvm.tajweedSelectedSetup.ColumnCount - 1) {
            
            Divider()
                .frame(minWidth: 1, maxHeight: .infinity)
                .background(Color(hex: "DAE1A0"))
        }
    }
}

func exValue(value: String) -> String {

    return value
        .replacingOccurrences(of: "<span class=\"color absolute\">ْ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ً</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ٌ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ٍ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">َ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ُ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ِ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ۢ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ُۢ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">َۢ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ٰ</span>", with: "")
        .replacingOccurrences(of: "<span class=\"color absolute\">ٰٓ</span>", with: "")
}
