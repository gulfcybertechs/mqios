import SwiftUI
//import WrappingHStack

struct RecitationItem: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Binding var item: RecitationModel    
    @Binding var vm: RecitationViewModel
    @Binding var player: Player
    @Binding var audioHelper: AudioHelper
    @State var finishedPlaying = false
    @State var finishedPlaying1 = false
    @AppStorage("reciter") var reciterID = ""
    
    var verseAudioFileName: String {
        
        if (item.basmalah) {
            return "001001.mp3"
        }
        
        return audioHelper.audioName(name: item.Surah) + "" + audioHelper.audioName(name: item.Ayah) + ".mp3"
    }
    
    @State var bookmarkText = "Bookmark"
    @State var bookmarkTextColor = Color(hex: "C2C2C2")
    @State var bookmarkColor = Color(hex: "C2C2C2")
    @State var buttonBackground = Color.gray.opacity(0.6)
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var ayahText:String {
        if (currentLanguage == "Ar") {
            "الآية"
        }
        else {
            "Ayah"
        }
    }
    
    var juzuText:String {
        if (currentLanguage == "Ar") {
            "الجزء"
        }
        else {
            "Juzu"
        }
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
                        
            //region Colors Meaning
            if (item.Ayah == mvm.recitationItems.first?.Ayah && mvm.lessonSelected.StageID == 3 && mvm.lessonSelected.id == 52) {
                
                VStack(spacing: 0)
                {
                    HStack(spacing: 0) {
                        
                        HStack(spacing: 0) {
                            Text(mvm.home.ColorsMeaning).fontWeight(.bold).padding(.leading, 4).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        HStack(spacing: 0) {
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "940056")).font(.system(size: 24))
                            Text(mvm.home.Madd6).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    
                    HStack(spacing: 0) {
                        
                        HStack(spacing: 0) {
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "ed008c")).font(.system(size: 24))
                            Text(mvm.home.Madd4).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 0) {
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "f48221")).font(.system(size: 24))
                            Text(mvm.home.Madd2).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    
                    HStack(spacing: 0) {
                        
                        HStack(spacing: 0) {
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "00a652")).font(.system(size: 24))
                            Text(mvm.home.Gunnah).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 0) {
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "9e9fa3")).font(.system(size: 24))
                            Text(mvm.home.Idgam).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    
                    HStack(spacing: 0) {
                        
                        HStack(spacing: 0) {
                            
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "006f9a")).font(.system(size: 24))
                            Text(mvm.home.Tafkheem).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 0) {
                            Image(systemName: "circle.fill").foregroundStyle(Color(hex: "00adef")).font(.system(size: 24))
                            Text(mvm.home.Qalqalah).padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(5)
                }
                .environment(\.layoutDirection, (currentLanguage == "Ar") ? .rightToLeft : .leftToRight)
                .frame(maxWidth: .infinity)
                .border(colorResource.primary_500, width: 1)
                .padding(.top, 0)
                .padding(.bottom, 10)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }
            //endregion
            
            //region Bookmark
            if (item.Ayah == mvm.recitationItems.first?.Ayah) {
                
                VStack(spacing: 0)
                {
                    Button(action: {
                        
                        if (mvm.lessonSelected.StageID == 7) {
                            
                            if (!getMemorizing().isEmpty) {
                                
                                let format = DateFormatter()
                                format.dateFormat = "dd/MM/yyyy HH:mm:ss"
                                format.timeZone = TimeZone(abbreviation: "UTC")
                                let continueItem = getMemorizing().filter {
                                    $0.UserID == getUser(type: "ID")
                                }.sorted { item1, item2 in format.date(from: item1.Date)! > format.date(from: item2.Date)! }
                                
                                if (!continueItem.isEmpty) {
                                    
                                    vm.surah.selected = vm.surah.items.first { $0.split(separator: " ")[0] == continueItem[0].Surah }!
                                    vm.surah.title = vm.surah.items.first { $0.split(separator: " ")[0] == continueItem[0].Surah }!
                                    vm.ayah.selected = "\(ayahText) \(continueItem[0].Ayah)"
                                    vm.ayah.title = "\(ayahText) \(continueItem[0].Ayah)"
                                    
                                    loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "Ayah", audioHelper: audioHelper)
                                }
                            }
                            
                        }
                        else {
                            
                            if (vm.bookmarked != "" && !mvm.verseByVerse.isEmpty) {
                                
                                if (item.Surah == getBookmark(key: "Surah", mvm: mvm)) {
                                    
                                    vm.ayah.selected = "\(ayahText) \(getBookmark(key: "Ayah", mvm: mvm))"
                                    vm.ayah.title = "\(ayahText) \(getBookmark(key: "Ayah", mvm: mvm))"
                                    
                                    vm.scrollTarget = mvm.recitationItems.first{ $0.Ayah == getBookmark(key: "Ayah", mvm: mvm) }!.id.description
                                    
                                } else {
                                    
                                    vm.surah.selected = vm.surah.items.first { $0.split(separator: " ")[0] == getBookmark(key:  "Surah", mvm: mvm) }!
                                    vm.surah.title = vm.surah.items.first { $0.split(separator: " ")[0] == getBookmark(key:  "Surah", mvm: mvm) }!
                                    
                                    loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected, trigger: "Surah", audioHelper: audioHelper) {
                                        
                                        vm.ayah.selected = "\(ayahText) \(getBookmark(key: "Ayah", mvm: mvm))"
                                        vm.ayah.title = "\(ayahText) \(getBookmark(key: "Ayah", mvm: mvm))"
                                        
                                        vm.scrollTarget = mvm.recitationItems.first{ $0.Ayah == getBookmark(key: "Ayah", mvm: mvm) }!.id.description
                                    }
                                }
                            }
                        }
                    })
                    {
                        if (vm.bookmarked != "" && mvm.lessonSelected.StageID != 7) {
                            
                            if (mvm.verseByVerse.isEmpty) {
                                
                                ProgressView()
                                    .foregroundStyle(bookmarkColor)
                                    .frame(width: 20)
                                
                            } else {
                                
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(bookmarkColor)
                                    .font(.system(size: 20))

                                Text(bookmarkText)
                                    .foregroundStyle(bookmarkTextColor)
                            }
                            
                        }
                        else if (!getMemorizing().isEmpty && mvm.lessonSelected.StageID == 7) {
                            
                            if (mvm.verseByVerse.isEmpty) {
                                
                                ProgressView()
                                    .foregroundStyle(bookmarkColor)
                                    .frame(width: 20)
                            }
                            else {
                                
//                                Image(systemName: "chevron.forward")
//                                    .foregroundStyle(bookmarkColor)
//                                    .font(.system(size: 20))
                                
                                Text(bookmarkText)
                                    .foregroundStyle(bookmarkTextColor)
                            }
                        }
                        else
                        {
                            if (mvm.lessonSelected.StageID != 7) {
                                
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(bookmarkColor)
                                    .font(.system(size: 20))
                                
                                Text(bookmarkText)
                                    .foregroundStyle(bookmarkTextColor)
                            }
                            else {
                                
//                                Image(systemName: "chevron.forward")
//                                    .padding(0)
//                                    .foregroundStyle(bookmarkColor)
//                                    .font(.system(size: 20))
                                    
                                
                                Text(bookmarkText)
                                    .foregroundStyle(bookmarkTextColor)
                            }
                        }
                    }
                    .task(id: vm.bookmarked) {
                        
                        if (vm.bookmarked != "" && !mvm.verseByVerse.isEmpty) {
                            bookmarkText = getBookmark(key: "SurahName", mvm: mvm) + " " + getBookmark(key: "Surah", mvm: mvm) + " | \(ayahText) " + getBookmark(key: "Ayah", mvm: mvm)
                            bookmarkTextColor = colorResource.lightButtonText
                            bookmarkColor = colorResource.maroon
                            buttonBackground = colorResource.maroon
                        }
                        
                        if (mvm.lessonSelected.StageID == 7) {
                                                                                    
                            bookmarkText = (currentLanguage == "Ar") ? "متابعة" : "Continue"
                            bookmarkTextColor = Color(hex: "C2C2C2")
                            bookmarkColor = Color(hex: "C2C2C2")
                            buttonBackground = Color.gray.opacity(0.6)
                            
                            if (!getMemorizing().isEmpty) {
                                
                                let format = DateFormatter()
                                format.dateFormat = "dd/MM/yyyy HH:mm:ss"
                                format.timeZone = TimeZone(abbreviation: "UTC")
                                let continueItem = getMemorizing().filter {
                                    $0.UserID == getUser(type: "ID")
                                }.sorted { item1, item2 in format.date(from: item1.Date)! > format.date(from: item2.Date)! }
                                
                                if (!continueItem.isEmpty) {
                                    
                                    bookmarkText = (currentLanguage == "Ar") ? "متابعة" : "Continue" + " " + continueItem[0].Surah + ":" + continueItem[0].Ayah
                                    bookmarkTextColor = colorResource.lightButtonText
                                    bookmarkColor = colorResource.maroon
                                    buttonBackground = colorResource.maroon
                                }
                            }
                        }
                    }
                    .task(id: getMemorizing().count) {
                        
                        if (mvm.lessonSelected.StageID == 7) {
                                                                                    
                            bookmarkText = (currentLanguage == "Ar") ? "متابعة" : "Continue"
                            bookmarkTextColor = Color(hex: "C2C2C2")
                            bookmarkColor = Color(hex: "C2C2C2")
                            buttonBackground = Color.gray.opacity(0.6)
                            
                            if (!getMemorizing().isEmpty) {
                                
                                let format = DateFormatter()
                                format.dateFormat = "dd/MM/yyyy HH:mm:ss"
                                format.timeZone = TimeZone(abbreviation: "UTC")
                                let continueItem = getMemorizing().filter {
                                    $0.UserID == getUser(type: "ID")
                                }.sorted { item1, item2 in format.date(from: item1.Date)! > format.date(from: item2.Date)! }
                                
                                if (!continueItem.isEmpty) {
                                    
                                    bookmarkText = (currentLanguage == "Ar") ? "متابعة" : "Continue" + " " + continueItem[0].Surah + ":" + continueItem[0].Ayah
                                    bookmarkTextColor = colorResource.lightButtonText
                                    bookmarkColor = colorResource.maroon
                                    buttonBackground = colorResource.maroon
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .buttonStyle(.bordered)
                    .tint(buttonBackground)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }
            //endregion
            
            //region Page Bar
            if (1 == 1) {
                
                var showPageBar: Bool {
                    
                    if (mvm.lessonSelected.StageID == 7) {
                        return false
                    }
                    
                    if (item.Ayah == mvm.recitationItems.first?.Ayah) {
                        return true
                    }
                                                                                    
                    if (mvm.recitationItems.contains { $0.Ayah == (Int(item.Ayah)! - 1).description }) {
                        
                        if (item.Page != mvm.recitationItems.first { $0.Ayah == (Int(item.Ayah)! - 1).description }!.Page) {
                            
                            return true
                        }
                    }
                    
                    return false
                }
                
                if (showPageBar) {
                    
                    HStack {
                        
                        Text("\(mvm.home.Page) " + item.Page)
                            .font(.custom(hafs(), size: 18))
                            .foregroundStyle(Color.white)
                            .frame(alignment: .trailing)
                        
                        Spacer()
                        
                        Text("\(juzuText) " + item.Juzu)
                            .font(.custom(hafs(), size: 18))
                            .foregroundStyle(Color.white)
                            .frame(alignment: .trailing)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .background(colorResource.maroon)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            //endregion
            
            //region Surah Name
            if (item.Ayah == mvm.recitationItems.first?.Ayah) {
                
                var attributedString: AttributedString {
                    
                    let string = " ﴿" + item.SurahNameAr + "﴾"
                    var attributedString = AttributedString(string)
                    
                    if let range = attributedString.range(of: string[1]) {
                        attributedString[range].foregroundColor = colorResource.ayahNumber
                        attributedString[range].font = .custom("KFGQPCHAFSUthmanicScript-Regula", size: 34)
                    }
                    
                    if let range = attributedString.range(of: string[string.count - 1]) {
                        attributedString[range].foregroundColor = colorResource.ayahNumber
                        attributedString[range].font = .custom("KFGQPCHAFSUthmanicScript-Regula", size: 34)
                    }
                    
                    return attributedString
                }
                
                Text(attributedString)
                    .multilineTextAlignment(.center)
                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                    .foregroundStyle(colorResource.maroon)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            //endregion
            
            //region Verse
            if (1 == 1) {
                
                VStack(spacing: 0) {
                    
                    var backgroundColor: Color {
                        
                        if (item.id == vm.selectedItem) {
                            return colorResource.verseSelected
                        }
                        
                        if (Int(item.Ayah)! % 2 != 0) {
                            return colorResource.verseColor
                        }
                        
                        return colorResource.transparent
                    }
                    
                    ZStack {
                        
                        //region Verse Bookmark
                        if (mvm.lessonSelected.StageID != 7 && !item.basmalah) {
                            
                            VStack(spacing: 0)
                            {
                                HStack
                                {
                                    let cloudColor = (vm.bookmarked == item.id.description) ? colorResource.maroon : Color(hex: "C2C2C2")
                                    
                                    Button(action: {
                                        setBookmark(id: item.id.description, surah: item.Surah, surahName: item.SurahNameTr, ayah: item.Ayah)
                                        vm.bookmarked = item.id.description
                                    })
                                    {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(cloudColor)
                                            .font(.system(size: 24))
                                            .offset(y: -7)
                                    }
                                    .frame(width: 30, height: 40)
                                    
                                    if (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 4) {
                                        
                                        var attributedString: AttributedString {
                                            
                                            let string = " ﴾" + toArabic(str: item.Ayah) + "﴿"
                                            var attributedString = AttributedString(string)
                                            
                                            if let range = attributedString.range(of: string[1]) {
                                                attributedString[range].foregroundColor = colorResource.ayahNumber
                                                attributedString[range].font = .custom("KFGQPCHAFSUthmanicScript-Regula", size: 24)
                                            }
                                            
                                            if let range = attributedString.range(of: string[string.count - 1]) {
                                                attributedString[range].foregroundColor = colorResource.ayahNumber
                                                attributedString[range].font = .custom("KFGQPCHAFSUthmanicScript-Regula", size: 24)
                                            }
                                            
                                            return attributedString
                                        }
                                        
                                        Spacer()
                                        
                                        Text(attributedString)
                                            .multilineTextAlignment(.center)
                                            .font(.custom("ScheherazadeNew-Regular", size: 20))
                                            .foregroundStyle(colorResource.ayahNumber)
                                            .multilineTextAlignment(.trailing)
                                            .frame(alignment: .trailing)
                                            .padding(.trailing, 5)
                                            .offset(y: -5)
                                    }
                                    else {
                                        
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                            .environment(\.layoutDirection, .leftToRight)
                            .frame(maxWidth: .infinity)
                            .zIndex(99)
                        }
                        //endregion
                        
                        VStack(spacing:0) {
                            
                            //region Memorizing Repeating Icon
                            if (mvm.lessonSelected.StageID == 7 && item.id == vm.selectedItem) {
                                
                                VStack(spacing:0) {
                                    
                                    HStack(spacing:0) {
                                        
                                        Spacer()
                                        
                                        if (item.memorizingCounter > 0) {
                                            
                                            Text(item.memorizingCounter.description)
                                                .font(.system(size: 16))
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                                .foregroundStyle(colorResource.maroon)
                                                .padding(.trailing, 3)
                                            
                                            Image(systemName: "arrow.counterclockwise")
                                                .foregroundStyle(colorResource.maroon)
                                                .font(.system(size: 18))
                                            
                                            Spacer().frame(width: 5)
                                        }
                                        else {
                                            
                                            if (item.memorizingStartOverCounter > 0) {
                                                
                                                Text(item.memorizingStartOverCounter.description)
                                                    .font(.system(size: 16))
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundStyle(colorResource.maroon)
                                                    .padding(.trailing, 3)
                                                
                                                Image(systemName: "arrow.up")
                                                    .foregroundStyle(colorResource.maroon)
                                                    .font(.system(size: 18))
                                            }
                                        }
                                        
                                        Spacer().frame(width: 5)
                                        
                                        Text(vm.memorizingTotalCounter.description)
                                            .font(.system(size: 16))
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(colorResource.primary_700)
                                            .padding(.trailing, 3)
                                        
                                        Image(systemName: "arrow.counterclockwise")
                                            .foregroundStyle(colorResource.primary_700)
                                            .font(.system(size: 18))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            //endregion
                            
                            if (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 4) {
                                
                                //region Words Text
                                            
                                ForEach(item.Words) { wordItem in
                                    
                                    let wordBackground = (vm.selectedWord == item.Page + ":" + wordItem.Word) ? Color(hex: "f5dbcd") : Color.white.opacity(0)
                                    
                                    VStack(spacing: 0)
                                    {
                                        Text(wordItem.Verse)
                                            .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                            .foregroundColor(Color.black)
                                            .multilineTextAlignment(.center)
                                            .padding(5)
                                        
                                        if (currentLanguage != "Ar") {
                                            
                                            Text(wordItem.Transliteration)
                                                .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 24))
                                                .foregroundColor(Color.black)
                                                .multilineTextAlignment(.center)
                                                .padding(5)
                                                .environment(\.layoutDirection, .leftToRight)
                                        }
                                    }
                                    .frame(alignment: .center)
                                    .overlay(alignment: .bottom) {
                                        Rectangle()
                                            .foregroundStyle(colorResource.orange)
                                            .frame(height: 1)
                                    }
                                    .padding(15)
                                    
                                    .background(wordBackground)
                                    .onTapGesture {
                                        
                                        vm.selectedWord = item.Page + ":" + wordItem.Word
                                        vm.audioPlaying = true
                                    }
                                }
                                
//                                WrappingHStack(item.Words, id:\.self, alignment: .center) { wordItem in
//                                    
//                                    let wordBackground = (vm.selectedWord == item.Page + ":" + wordItem.Word) ? Color(hex: "f5dbcd") : Color.white.opacity(0)
//                                    
//                                    VStack(spacing: 0)
//                                    {
//                                        Text(wordItem.Verse)
//                                            .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
//                                            .foregroundColor(Color.black)
//                                            .multilineTextAlignment(.center)
//                                            .padding(5)
//                                        
//                                        Text(wordItem.Transliteration)
//                                            .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 24))
//                                            .foregroundColor(Color.black)
//                                            .multilineTextAlignment(.center)
//                                            .padding(5)
//                                            .environment(\.layoutDirection, .leftToRight)
//                                    }
//                                    .frame(alignment: .center)
//                                    .overlay(alignment: .bottom) {
//                                        Rectangle()
//                                            .foregroundStyle(colorResource.orange)
//                                            .frame(height: 1)
//                                    }
//                                    .padding(15)
//                                    
//                                    .background(wordBackground)
//                                    .onTapGesture {
//                                        
//                                        vm.selectedWord = item.Page + ":" + wordItem.Word
//                                        vm.audioPlaying = true
//                                    }
//                                }
//                                .frame(maxWidth: .infinity)
//                                .environment(\.layoutDirection, .rightToLeft)
                                //endregion
                                
                            } else {
                                
                                //region Verse Text
                                var verse: AttributedString {
                                    
                                    var string = item.Verse
                                    let ayahString = toArabic(str: item.Ayah)
                                    
                                    if (mvm.lessonSelected.StageID == 3) {
                                        string = ""
                                    }
                                    else {
                                        
                                        if (!item.basmalah) {
                                            
                                            string += " ﴿" + toArabic(str: item.Ayah) + "﴾"
                                        }
                                    }
                                    
                                    var attributedString = AttributedString(string)
                                    
                                    if (mvm.lessonSelected.StageID == 3) {
                                        
                                        for s in item.VerseColor.components(separatedBy: "<span style=\"color: ") {

                                            if (!s.isEmpty) {
                                                
                                                if (s[0] == "#") {
                                                    
                                                    let toColor = s.dropFirst(10)
                                                    
                                                    //if (toColor.firstIndex(of: "<") != nil) {
                                                        
                                                        let str = toColor[..<toColor.firstIndex(of: "<")!]
                                                        
                                                        if (str == "ـٰ") {
                                                            
                                                            //var subStr = AttributedString("ـ" + "ـٰ" + "ـ")
                                                            var subStr = AttributedString("ـٰ")
                                                            
                                                            if let range = subStr.range(of: str) {
                                                                subStr[range].foregroundColor = Color(hex: s[1...6])
                                                            }
                                                            
                                                            attributedString.append(subStr)
                                                        }
                                                        else {
                                                            
                                                            var subStr = AttributedString(str)
                                                            
                                                            if let range = subStr.range(of: str) {
                                                                subStr[range].foregroundColor = Color(hex: s[1...6])
                                                            }
                                                            
                                                            attributedString.append(subStr)
                                                        }
                                                    
                                                    
                                                    let target = toColor.range(of: "</span>")
                                                    let strRest = toColor.dropFirst(toColor.distance(from: toColor.startIndex, to: target!.lowerBound)).replacingOccurrences(of: "</span>", with: "")
                                                    
                                                    attributedString.append(AttributedString(strRest))
                                                    //}
                                                    //else {
                                                    //    print(ayahString)
                                                    //    print(s)
                                                    //}
                                                }
                                                else {
                                                    
                                                    attributedString.append(AttributedString(s))
                                                }
                                            }
                                        }
                                        
                                        if (!item.basmalah) {
                                            
                                            attributedString.append(AttributedString(" ﴿" + toArabic(str: item.Ayah) + "﴾"))
                                        }
                                    }                                                                        
                                    
                                    if (!item.basmalah) {
                                        
                                        if let range = attributedString.range(of: ayahString) {
                                            attributedString[range].foregroundColor = colorResource.ayahNumber
                                            attributedString[range].font = .custom("ScheherazadeNew-Regular", size: 28)
                                        }
                                        
                                        if let range = attributedString.range(of: " ﴿") {
                                            attributedString[range].foregroundColor = colorResource.ayahNumber
                                            attributedString[range].font = .custom("KFGQPCHAFSUthmanicScript-Regula", size: 28)
                                        }
                                        
                                        if let range = attributedString.range(of: "﴾") {
                                            attributedString[range].foregroundColor = colorResource.ayahNumber
                                            attributedString[range].font = .custom("KFGQPCHAFSUthmanicScript-Regular", size: 28)
                                        }
                                    }
                                    
                                    return attributedString
                                }
                                
                                Text(verse)
                                    .multilineTextAlignment(.center)
                                    .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: 40))
                                    .foregroundStyle(Color.black)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                //endregion
                                
                                //region Transliteration & Translation
                                if ((mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 6) ||
                                    (mvm.lessonSelected.StageID == 3 && mvm.lessonSelected.id == 97)) {
                                    // No Transliteration
                                } else 
                                {
                                    
                                    var transText: AttributedString {
                                        
                                        var string: String {
                                            
                                            if (mvm.lessonSelected.StageID == 3) {
                                                return ""
                                            }
                                            
                                            if (mvm.lessonSelected.StageID == 5) {
                                                return item.Verse_
                                            }
                                            
                                            return item.Transliteration
                                        }
                                        
                                        var attributedString = AttributedString(string)
                                        
                                        if (mvm.lessonSelected.StageID == 3) {
                                            
                                            for s in item.TransliterationColor.split(separator: "#") {
                                                
                                                if (s.description.count > 1) {
                                                    
                                                    if (s.description[0] == "1" || s.description[0] == "2" || s.description[0] == "3" || s.description[0] == "4" || s.description[0] == "5" || s.description[0] == "6" || s.description[0] == "7") {

                                                        var subStr = AttributedString(s.description[1])
                                                        
                                                        if let range = subStr.range(of: s.description[1]) {
                                                            subStr[range].foregroundColor = Color(hex: tajweedColorCode(code: Int(s.description[0])!))
                                                        }
                                                        
                                                        attributedString.append(subStr)
                                                        
                                                        attributedString.append(AttributedString(s.dropFirst().dropFirst().description))
                                                    }
                                                    else {
                                                                                                                
                                                        attributedString.append(AttributedString(s))
                                                    }
                                                }
                                            }
                                        }
                                        
                                        return attributedString
                                    }
                                    
                                    var transTextSize: CGFloat {
                                        
                                        if (mvm.lessonSelected.StageID == 3) {
                                            return 26.0
                                        }
                                        
                                        return 24.0
                                    }
                                    
                                    var showTrans:Bool {
                                        
                                        if (currentLanguage == "Ar") {
                                            
                                            if (mvm.lessonSelected.StageID != 5) {
                                                return false
                                            }
                                        }
                                        
                                        return true
                                    }
                                    
                                    if (showTrans)
                                    {
                                        Text(transText)
                                            .multilineTextAlignment(.center)
                                            .font(.custom("KFGQPCHAFSUthmanicScript-Regula", size: transTextSize))
                                            .foregroundStyle(Color.black)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .environment(\.layoutDirection, .leftToRight)
                                    }
                                }
                                //endregion
                                
                                //region Downloaded Icon
                                HStack
                                {
                                    let downloaded = downloaded(item: item)
                                    let cloudIcon = (downloaded) ? "checkmark.icloud.fill" : "icloud.and.arrow.down.fill"
                                    let cloudColor = (downloaded) ? colorResource.primary_200 : Color(hex: "C2C2C2")
                                    
                                    if (mvm.lessonSelected.StageID == 7) {
                                        
                                        let memorized = memorized(item: item)
                                        let memorizedIcon = (memorized) ? "checkmark.circle.fill" : "clock"
                                        let memorizingColor = (memorized) ? colorResource.success : colorResource.orange
                                        
                                        Image(systemName: memorizedIcon)
                                            .foregroundColor(memorizingColor)
                                            .font(.system(size: 20))
                                        
                                        Spacer()
                                    }
                                    
                                    Image(systemName: cloudIcon)
                                        .foregroundColor(cloudColor)
                                        .font(.system(size: 20))                                                                        
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .environment(\.layoutDirection, .leftToRight)
                                //endregion
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(backgroundColor)
                    .padding(0)
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .onTapGesture {
                    
                    if (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 4) {
                        // Play Word
                    } else if (mvm.lessonSelected.StageID == 7) {
                        // Memorizing
                    } else {
                        vm.selectedItem = item.id
                        vm.audioPlaying = true
                    }
                }
            }
            //endregion
            
            //region Extra Space at the end
            if (item.Ayah == mvm.recitationItems.last?.Ayah) {
                VStack(spacing: 0) { }.frame(maxWidth: .infinity, minHeight: 50)
            }
            //endregion
        }
        .onAppear() {
            
            reciterID = getReciter(mvm: mvm).0
            bookmarkText = mvm.home.Bookmark
        }
        .task(id: vm.selectedItem) {
            
            if (vm.selectedItem != 0 && vm.audioPlaying) {
                
                playVerse()
            }
        }
        .task(id: vm.selectedWord) {
            
            //region Play Word
            if (vm.selectedWord != "" && vm.audioPlaying) {
                
                vm.audioPlaying = false
                
                let wordPage = vm.selectedWord.split(separator: ":")[0].description
                let wordNumber = vm.selectedWord.split(separator: ":")[1].description
                
                let selectedVerseAudioFileName = audioHelper.audioName(name: wordPage) + "" + audioHelper.audioName(name: wordNumber) + ".mp3"
                
                audioHelper.downloadVerse(
                    fileName: "/recitation/w/\(selectedVerseAudioFileName)",
                    url: URL(string: "https://mualim-alquran.com/recitation/w/\(selectedVerseAudioFileName)")!
                ) {
                    
                    DispatchQueue.main.async {
                        
                        vm.audioBarStatus = "stop"
                        
                        audioHelper.playVerse(audioFileName: "/recitation/w/\(selectedVerseAudioFileName)") {
                            
                            vm.audioBarStatus = "play"
                        }
                    }
                }
            }
            //endregion
        }
    }
    
    func playVerse() {
        
        vm.audioPlaying = false
        
        let selectedItemData = mvm.recitationItems.first { $0.id == vm.selectedItem }!
        var selectedVerseAudioFileName = audioHelper.audioName(name: selectedItemData.Surah) + "" + audioHelper.audioName(name: selectedItemData.Ayah) + ".mp3"
        if (selectedItemData.basmalah) {
            selectedVerseAudioFileName = "001001.mp3"
        }
        
        vm.audioBarVisible = true
        vm.audioBarStatus = "loading"
        
        var pathForAr:String {
            
            if (currentLanguage == "Ar" && mvm.listSelected.id == 5) {
                return "/translation/\(getLanguageName())"
            }
            
            return "/recitation/\(reciterID)"
        }
        
        
        Task {
            
            audioHelper.downloadVerse(
                fileName: "\(pathForAr)/\(selectedVerseAudioFileName)",
                url: URL(string: "https://mualim-alquran.com/\(pathForAr)/\(selectedVerseAudioFileName)")!
            ) {
                
                DispatchQueue.main.async {
                    
                    selectedItemData.downloaded = true
                    
                    vm.audioBarStatus = "stop"
                    
                    player.type = "recitation"
                    player.vm = self
                    audioHelper.playVerse(audioFileName: "\(pathForAr)/\(selectedVerseAudioFileName)")
                }
            }
        }
    }
    
    func playVerseCompleted() {
        
        if (mvm.recitationItems.first { $0.id == vm.selectedItem } != nil)
        {
            vm.audioBarStatus = "play"
            
            let selectedItemData = mvm.recitationItems.first { $0.id == vm.selectedItem }!
            var selectedVerseAudioFileName = audioHelper.audioName(name: selectedItemData.Surah) + "" + audioHelper.audioName(name: selectedItemData.Ayah) + ".mp3"
            if (selectedItemData.basmalah) {
                selectedVerseAudioFileName = "001001.mp3"
            }
            
            if (mvm.lessonSelected.StageID == 7) {
                
                if (selectedItemData.memorizingCounter > 0) {
                    selectedItemData.memorizingCounter = selectedItemData.memorizingCounter - 1
                    if (vm.memorizingTotalCounter > 0) {
                        vm.memorizingTotalCounter = vm.memorizingTotalCounter - 1
                    }
                }
                else if (selectedItemData.memorizingStartOverCounter > 0) {
                    selectedItemData.memorizingStartOverCounter = selectedItemData.memorizingStartOverCounter - 1
                    if (vm.memorizingTotalCounter > 0) {
                        vm.memorizingTotalCounter = vm.memorizingTotalCounter - 1
                    }
                }
                
                if (selectedItemData.memorizingCounter > 0) {
                    
                    vm.scrollTarget = selectedItemData.id.description
                    vm.selectedItem = selectedItemData.id
                    vm.audioPlaying = true
                    playVerse()
                }
                else if (selectedItemData.memorizingStartOverCounter > 0) {
                    
                    vm.scrollTarget = mvm.recitationItems[0].id.description
                    vm.selectedItem = mvm.recitationItems[0].id
                    vm.audioPlaying = true
                }
                else {
                    
                    if (mvm.recitationItems.contains(where: { it in it.id == selectedItemData.id + 1 })) {
                        
                        vm.scrollTarget = (selectedItemData.id + 1).description
                        vm.selectedItem = selectedItemData.id + 1
                        vm.audioPlaying = true
                    }
                    else {
                        
                        // Android
                        vm.selectedItem = 0
                        vm.audioPlaying = false
                        memorizingResetTotalCounter(vm: vm)
                        memorizingResetData(vm: vm, data: mvm.recitationItems)
                    }
                }
            }
            else {
                
                if (mvm.lessonSelected.StageID == 5 && currentLanguage != "Ar") {
                    
                    audioHelper.downloadVerse(
                        fileName: "translation/\(getLanguageName())/\(selectedVerseAudioFileName)",
                        url: URL(string: "https://mualim-alquran.com/translation/\(getLanguageName())/\(selectedVerseAudioFileName)")!
                    ) {
                        
                        DispatchQueue.main.async {
                            selectedItemData.downloaded = true
                            
                            vm.audioBarStatus = "stop"
                            
                            player.type = "translation"
                            player.vm = self
                            audioHelper.playVerse(audioFileName: "translation/\(getLanguageName())/\(selectedVerseAudioFileName)")
                        }
                    }
                    
                }
                else {
                    
                    continuousRecitation()
                }
            }
        }
    }
    
    func playTranslationCompleted() {
        
        vm.audioBarStatus = "play"
        
        continuousRecitation()
    }
    
    func continuousRecitation() {
        
        if ((mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 5) ||
            (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 6) ||
            (mvm.lessonSelected.StageID == 5 && mvm.lessonSelected.Number == 2) ||
            (mvm.lessonSelected.StageID == 3 && mvm.lessonSelected.id == 97)
        ) {
            
            if (mvm.recitationItems.firstIndex(of: mvm.recitationItems.first { $0.id == vm.selectedItem }!)! < mvm.recitationItems.count - 1) {
                
                let nextItem = mvm.recitationItems.first {
                    $0.Ayah == (Int(mvm.recitationItems.first {
                        $0.id == vm.selectedItem
                    }!.Ayah)! + 1).description
                }!
                
                vm.scrollTarget = nextItem.id.description
                vm.selectedItem = nextItem.id
                vm.audioPlaying = true
                                
            } else {
                     
                if (vm.surah.items.first { $0.split(separator: " ")[0] == (Int(item.Surah)! + 1).description } != nil) {
                    
                    vm.surah.selected = vm.surah.items.first { $0.split(separator: " ")[0] == (Int(item.Surah)! + 1).description }!
                    
                    loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected, trigger: "Surah", audioHelper: audioHelper) {
                        
                        vm.selectedItem = mvm.recitationItems[0].id
                        vm.audioPlaying = true
                    }
                }
            }
        }
    }
    
    func downloaded(item: RecitationModel) -> Bool {
        
        let verseAudioFileName = audioHelper.audioName(name: item.Surah) + "" + audioHelper.audioName(name: item.Ayah) + ".mp3"
        
        item.downloaded = audioHelper.checkVerse(fileName: "/recitation/\(reciterID)/\(verseAudioFileName)")
        if (mvm.lessonSelected.StageID == 5) {
            item.downloaded = audioHelper.checkVerse(fileName: "/translation/\(getLanguageName())/\(verseAudioFileName)")
        }
        
        return item.downloaded
    }
    
    func memorized(item: RecitationModel) -> Bool {
        
        item.memorized = getMemorizing().contains { it in
            it.UserID == getUser(type: "ID") && it.Surah == item.Surah && it.Ayah == item.Ayah
        }
        
        return item.memorized
    }
}
