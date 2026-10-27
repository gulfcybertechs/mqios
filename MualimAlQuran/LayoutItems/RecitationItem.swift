import SwiftUI
//import WrappingHStack

// Page previews carry their Surah's verses without replacing active playback data.
private struct RecitationDisplayItemsKey: EnvironmentKey {
    static let defaultValue: [RecitationModel]? = nil
}

private struct RecitationControlHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 32
}

extension EnvironmentValues {
    var recitationDisplayItems: [RecitationModel]? {
        get { self[RecitationDisplayItemsKey.self] }
        set { self[RecitationDisplayItemsKey.self] = newValue }
    }

    var recitationControlHeight: CGFloat {
        get { self[RecitationControlHeightKey.self] }
        set { self[RecitationControlHeightKey.self] = newValue }
    }
}

private struct RecitationBookmarkHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Shared by the continuous reader and the controls above the book pager.
struct RecitationBookmarkRow: View {
    @EnvironmentObject var mvm: MainViewModel
    @Binding var item: RecitationModel
    @Binding var vm: RecitationViewModel
    @Binding var audioHelper: AudioHelper
    var readingModeControl: AnyView? = nil
    @Environment(\.layoutDirection) private var bookmarkLayoutDirection
    @AppStorage("language") var currentLanguage = getLanguage()

    @State private var bookmarkButtonHeight: CGFloat = 32
    @State var bookmarkText = "Bookmark"
    @State var bookmarkTextColor = Color(hex: "C2C2C2")
    @State var bookmarkColor = Color(hex: "C2C2C2")
    @State var buttonBackground = Color.gray.opacity(0.6)

    var ayahText:String {
        if (currentLanguage == "Ar") {
            "الآية"
        }
        else {
            "Ayah"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0)
            {
                Button(action: {
                    AppHaptics.tap()

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
                .lineLimit(readingModeControl == nil ? nil : 1)
                .minimumScaleFactor(readingModeControl == nil ? 1 : 0.6)
                .task(id: vm.bookmarked) {

                    if (vm.bookmarked != "" && !mvm.verseByVerse.isEmpty) {
                        bookmarkText = getBookmark(key: "Surah", mvm: mvm) + " | " + getBookmark(key: "Ayah", mvm: mvm)
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
                .background {
                    if readingModeControl != nil {
                        GeometryReader { button in
                            Color.clear.preference(key: RecitationBookmarkHeightKey.self, value: button.size.height)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 10))
                .tint(buttonBackground)
            }
            .environment(\.layoutDirection, bookmarkLayoutDirection)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let readingModeControl {
                readingModeControl
                    .environment(\.recitationControlHeight, bookmarkButtonHeight)
            }
        }
        // Keep bookmark on the physical left and the switch on the right.
        .environment(\.layoutDirection, readingModeControl == nil ? bookmarkLayoutDirection : .leftToRight)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .onPreferenceChange(RecitationBookmarkHeightKey.self) { height in
            if height.isFinite && height > 0 && bookmarkButtonHeight != height {
                bookmarkButtonHeight = height
            }
        }
        .onAppear {
            bookmarkText = mvm.home.Bookmark
        }
    }
}

// Shared only by the two Tajweed recitation headers; verse/page selection does not own it.
struct RecitationTajweedLegend: View {
    @EnvironmentObject private var mvm: MainViewModel
    @AppStorage("language") private var currentLanguage = getLanguage()

    var body: some View {
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
}

struct RecitationPageBarScrollID: Hashable {
    let surah: String
    let page: String
}

struct RecitationItem: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Binding var item: RecitationModel    
    @Binding var vm: RecitationViewModel
    @Binding var player: Player
    @Binding var audioHelper: AudioHelper
    var readingModeControl: AnyView? = nil
    var showsBookmark = true
    @Environment(\.recitationDisplayItems) private var pageDisplayItems

    private var displayItems: [RecitationModel] { pageDisplayItems ?? mvm.recitationItems }
    private var isActiveSurah: Bool {
        pageDisplayItems == nil || item.Surah == mvm.recitationItems.first?.Surah
    }

    @AppStorage("quran.reader.autoplay.v1") private var verseAutoplay = true
    @AppStorage("quran.reader.tajweed.v1") private var tajweedColors = false
    private var usesTajweedColors: Bool {
        mvm.lessonSelected.requiresTajweedColors
            || (mvm.lessonSelected.supportsRecitationReadingControls && tajweedColors)
    }
    @State var finishedPlaying = false
    @State var finishedPlaying1 = false
    @AppStorage("reciter") var reciterID = ""
    
    var verseAudioFileName: String {
        
        if (item.basmalah) {
            return "001001.mp3"
        }
        
        return audioHelper.audioName(name: item.Surah) + "" + audioHelper.audioName(name: item.Ayah) + ".mp3"
    }
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
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
                        
            //region Bookmark
            if showsBookmark && (item.Ayah == displayItems.first?.Ayah || readingModeControl != nil) {
                RecitationBookmarkRow(item: $item, vm: $vm, audioHelper: $audioHelper,
                    readingModeControl: readingModeControl)
            }
            //endregion
            
            //region Page Bar
            if (1 == 1) {
                
                var showPageBar: Bool {
                    
                    if (mvm.lessonSelected.StageID == 7) {
                        return false
                    }
                    
                    if (item.Ayah == displayItems.first?.Ayah) {
                        return true
                    }
                                                                                    
                    if (displayItems.contains { $0.Ayah == (Int(item.Ayah)! - 1).description }) {
                        
                        if (item.Page != displayItems.first { $0.Ayah == (Int(item.Ayah)! - 1).description }!.Page) {
                            
                            return true
                        }
                    }
                    
                    return false
                }
                
                if (showPageBar) {
                    
                    HStack {
                        
                        Text("\(mvm.home.Page) " + item.Page)
                            .font(currentLanguage == "Ar" ? .system(size: 18, weight: .bold) : .custom(hafs(), size: 18))
                            .foregroundStyle(Color.white)
                            .frame(alignment: .trailing)
                        
                        Spacer()
                        
                        Text("\(juzuText) " + item.Juzu)
                            .font(currentLanguage == "Ar" ? .system(size: 18, weight: .bold) : .custom(hafs(), size: 18))
                            .foregroundStyle(Color.white)
                            .frame(alignment: .trailing)
                    }
                    .padding(.top, currentLanguage == "Ar" ? 11 : 5)
                    .padding(.bottom, currentLanguage == "Ar" ? 11 : 5)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .background(colorResource.maroon)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .id(RecitationPageBarScrollID(surah: item.Surah, page: item.Page))
                }
            }
            //endregion
            
            //region Surah Name
            if (item.Ayah == displayItems.first?.Ayah) {
                
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
                        
                        if (isActiveSurah && item.id == vm.selectedItem) {
                            return colorResource.verseSelected
                        }
                        
                        if (Int(item.Ayah)! % 2 != 0) {
                            return colorResource.verseColor
                        }
                        
                        return colorResource.transparent
                    }
                    
                    ZStack {
                        
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
                                            
                                let tajweedWords: [String: AttributedString] = usesTajweedColors
                                    ? RecitationTajweedText.words(in: item) : [:]
                                ForEach(item.Words) { wordItem in
                                    
                                    let wordBackground = (isActiveSurah && vm.selectedWord == item.Page + ":" + wordItem.Word) ? Color(hex: "f5dbcd") : Color.white.opacity(0)
                                    
                                    VStack(spacing: 0)
                                    {
                                        Text(tajweedWords[wordItem.Word] ?? AttributedString(wordItem.Verse))
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
                                        
                                        selectAudio(word: item.Page + ":" + wordItem.Word)
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
                                    
                                    let ayahString = toArabic(str: item.Ayah)
                                    var attributedString = usesTajweedColors
                                        ? RecitationTajweedText.attributed(item.Verse, markup: item.VerseColor)
                                        : AttributedString(item.Verse)
                                    if !item.basmalah {
                                        attributedString.append(AttributedString(" ﴿" + toArabic(str: item.Ayah) + "﴾"))
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
                                    let cloudIcon = downloaded ? "checkmark.icloud.fill" : "icloud.fill"
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
                        // Balance the 20-point status-icon row below the verse.
                        .padding(.top, 20)
                    }
                    // The verse content owns row height; bookmark spacers only align its overlay.
                    .overlay {
                        //region Verse Bookmark
                        if (mvm.lessonSelected.StageID != 7 && !item.basmalah) {

                            VStack(spacing: 0)
                            {
                                HStack
                                {
                                    let cloudColor = (vm.bookmarked == item.id.description) ? colorResource.maroon : Color(hex: "C2C2C2")

                                    Button(action: {
                                        AppHaptics.tap()
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
                                    .padding(.leading, 10)

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
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(backgroundColor)
                    .padding(0)
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .background {
                    GeometryReader { verse in
                        Color.clear.preference(key: RecitationVerseTapPositionsKey.self,
                            value: [RecitationVerseTapScrollID(surah: item.Surah, verseID: item.id):
                                verse.frame(in: .named(RecitationVerseTapCoordinateSpace.content)).minY])
                    }
                }
                .onTapGesture {
                    
                    if (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 4) {
                        // Play Word
                    } else if (mvm.lessonSelected.StageID == 7) {
                        // Memorizing
                    } else {
                        selectAudio()
                    }
                }
            }
            //endregion
            
            //region Extra Space at the end
            if (item.Ayah == displayItems.last?.Ayah) {
                VStack(spacing: 0) { }.frame(maxWidth: .infinity, minHeight: 50)
            }
            //endregion
        }
        .onAppear() {
            
            reciterID = getReciter(mvm: mvm).0
        }
        .task(id: vm.selectedItem) {
            if isActiveSurah && vm.selectedItem == item.id && vm.selectedWord.isEmpty && vm.audioPlaying {
                playVerse()
            }
        }
        .task(id: vm.selectedWord) {
            if isActiveSurah && !vm.selectedWord.isEmpty && vm.selectedWordVerseID == item.id && vm.audioPlaying {
                playWord()
            }
        }
        .task(id: vm.audioPlayRequest) {
            guard isActiveSurah, vm.audioPlaying else { return }
            if !vm.selectedWord.isEmpty {
                if vm.selectedWordVerseID == item.id { playWord() }
            } else if vm.selectedItem == item.id {
                playVerse()
            }
        }
    }

    private func selectAudio(word: String? = nil) {
        guard isActiveSurah else { return }
        AppHaptics.tap()
        vm.stopAudio(player: player, hide: false)
        vm.selectedWord = word ?? ""
        vm.selectedWordVerseID = word == nil ? nil : item.id
        if word == nil {
            vm.selectedItem = item.id
            vm.verseTapScrollRequest = RecitationVerseTapScrollRequest(
                verse: RecitationVerseTapScrollID(surah: item.Surah, verseID: item.id))
        }
        vm.audioBarVisible = true
        if !mvm.lessonSelected.supportsRecitationReadingControls || verseAutoplay {
            vm.requestSelectedAudio()
        }
    }

    private func playWord() {
        let word = vm.selectedWord
        let parts = word.split(separator: ":")
        guard parts.count == 2 else { return }
        vm.audioPlaying = false
        let request = UUID()
        vm.audioRequestID = request
        vm.audioNeedsStart = true
        vm.audioBarVisible = true
        vm.audioBarStatus = "loading"
        let filename = audioHelper.audioName(name: String(parts[0]))
            + audioHelper.audioName(name: String(parts[1])) + ".mp3"
        audioHelper.downloadVerse(fileName: "/recitation/w/\(filename)",
            url: URL(string: "https://mualim-alquran.com/recitation/w/\(filename)")!) {
            guard vm.audioRequestID == request, vm.audioBarVisible,
                  vm.selectedWord == word, vm.selectedWordVerseID == item.id else { return }
            vm.audioNeedsStart = false
            vm.audioBarStatus = "stop"
            player.type = "word"
            player.vm = self
            audioHelper.playVerse(audioFileName: "/recitation/w/\(filename)")
        }
    }

    func playWordCompleted() {
        guard vm.audioBarVisible, vm.selectedWordVerseID == item.id else { return }
        vm.audioNeedsStart = true
        vm.audioBarStatus = "play"
    }

    func playVerse() {
        
        vm.audioPlaying = false
        
        guard let selectedItemData = mvm.recitationItems.first(where: { $0.id == vm.selectedItem }) else { return }
        let request = UUID()
        vm.audioRequestID = request
        vm.audioNeedsStart = true
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
                
                selectedItemData.downloaded = true
                guard vm.audioRequestID == request, vm.audioBarVisible,
                      vm.selectedItem == selectedItemData.id, vm.selectedWord.isEmpty else { return }
                vm.audioNeedsStart = false
                vm.audioBarStatus = "stop"

                player.type = "recitation"
                player.vm = self
                audioHelper.playVerse(audioFileName: "\(pathForAr)/\(selectedVerseAudioFileName)")
            }
        }
    }
    
    func playVerseCompleted() {
        guard vm.audioBarVisible, isActiveSurah, vm.selectedItem == item.id else { return }
        vm.audioNeedsStart = true
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
                    let request = vm.audioRequestID
                    vm.audioBarStatus = "loading"
                    audioHelper.downloadVerse(
                        fileName: "translation/\(getLanguageName())/\(selectedVerseAudioFileName)",
                        url: URL(string: "https://mualim-alquran.com/translation/\(getLanguageName())/\(selectedVerseAudioFileName)")!
                    ) {
                        
                        selectedItemData.downloaded = true
                        guard vm.audioRequestID == request, vm.audioBarVisible,
                              vm.selectedItem == selectedItemData.id else { return }
                        vm.audioNeedsStart = false
                        vm.audioBarStatus = "stop"

                        player.type = "translation"
                        player.vm = self
                        audioHelper.playVerse(audioFileName: "translation/\(getLanguageName())/\(selectedVerseAudioFileName)")
                    }
                    
                }
                else {
                    
                    continuousRecitation()
                }
            }
        }
    }
    
    func playTranslationCompleted() {
        guard vm.audioBarVisible, isActiveSurah, vm.selectedItem == item.id else { return }
        vm.audioNeedsStart = true
        vm.audioBarStatus = "play"
        
        continuousRecitation()
    }
    
    func continuousRecitation() {
        guard vm.audioBarVisible,
              let current = mvm.recitationItems.first(where: { $0.id == vm.selectedItem }) else { return }
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
                
                vm.selectedItem = nextItem.id
                vm.audioPlaying = true
                vm.requestAutomaticVerseScroll(to: nextItem)
                                
            } else {
                     
                if (vm.surah.items.first { $0.split(separator: " ")[0] == (Int(current.Surah)! + 1).description } != nil) {
                    
                    vm.surah.selected = vm.surah.items.first { $0.split(separator: " ")[0] == (Int(current.Surah)! + 1).description }!
                    
                    let request = vm.audioRequestID
                    loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected.split(separator: " ")[0].description,
                        trigger: "Surah", audioHelper: audioHelper, continueAudio: true) {
                        guard vm.audioRequestID == request, vm.audioBarVisible,
                              let first = mvm.recitationItems.first else { return }
                        vm.selectedItem = first.id
                        vm.audioPlaying = true
                        vm.requestAutomaticVerseScroll(to: first)
                    }
                }
            }
        }
    }
    
    func downloaded(item: RecitationModel) -> Bool {
        
        // Inserted Bismillah rows use verse 0, but play the shared 1:1 clip.
        let verseAudioFileName = item.basmalah ? "001001.mp3"
            : audioHelper.audioName(name: item.Surah) + "" + audioHelper.audioName(name: item.Ayah) + ".mp3"
        
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

// Paint the canonical Quran text; markup is a source of colors, never replacement text.
private enum RecitationTajweedText {
    private static let spanPattern = try? NSRegularExpression(
        pattern: #"<span\s+style="color:\s*(#[0-9A-Fa-f]{6});?">([^<]*)</span>"#)

    static func attributed(_ text: String, markup: String) -> AttributedString {
        var result = AttributedString(text)
        let target = Array(text.unicodeScalars)
        guard !target.isEmpty, let spanPattern else { return result }
        let source = markup as NSString
        let matches = spanPattern.matches(in: markup, range: NSRange(location: 0, length: source.length))
        guard !matches.isEmpty else { return result }

        var scalars: [Unicode.Scalar] = []
        var colors: [String?] = []
        func append(_ part: String, color: String?) {
            let decoded = part.replacingOccurrences(of: "<[^>]*>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: "\u{00A0}")
            for scalar in decoded.unicodeScalars {
                scalars.append(scalar)
                colors.append(color)
            }
        }
        var offset = 0
        for match in matches {
            append(source.substring(with: NSRange(location: offset, length: match.range.location - offset)), color: nil)
            append(source.substring(with: match.range(at: 2)), color: source.substring(with: match.range(at: 1)))
            offset = NSMaxRange(match.range)
        }
        append(source.substring(from: offset), color: nil)

        // Most markup matches exactly. A few legacy records differ: leave inserted
        // canonical characters uncolored and ignore removed markup characters.
        var removed = Set<Int>()
        var inserted = Set<Int>()
        if scalars != target {
            for change in target.difference(from: scalars) {
                switch change {
                case .remove(let offset, _, _): removed.insert(offset)
                case .insert(let offset, _, _): inserted.insert(offset)
                }
            }
        }
        var mapped = [String?](repeating: nil, count: target.count)
        var sourceIndex = 0
        for index in target.indices {
            if inserted.contains(index) { continue }
            while removed.contains(sourceIndex) { sourceIndex += 1 }
            guard sourceIndex < scalars.count, scalars[sourceIndex] == target[index] else {
                return result
            }
            mapped[index] = colors[sourceIndex]
            sourceIndex += 1
        }

        // Set attributes only, using scalar boundaries for Arabic combining marks.
        var cursor = result.unicodeScalars.startIndex
        var start = 0
        while start < mapped.count {
            var end = start + 1
            while end < mapped.count && mapped[end] == mapped[start] { end += 1 }
            let upper = result.unicodeScalars.index(cursor, offsetBy: end - start)
            if let color = mapped[start] {
                result[cursor..<upper].foregroundColor = Color(hex: color)
            }
            cursor = upper
            start = end
        }
        return result
    }

    static func words(in item: RecitationModel) -> [String: AttributedString] {
        let verse = attributed(item.Verse, markup: item.VerseColor)
        var result: [String: AttributedString] = [:]
        var searchStart = item.Verse.startIndex
        for word in item.Words {
            guard !word.Verse.isEmpty,
                  let range = item.Verse.range(of: word.Verse, options: .literal,
                    range: searchStart..<item.Verse.endIndex) else { continue }
            let offset = item.Verse[..<range.lowerBound].unicodeScalars.count
            let lower = verse.unicodeScalars.index(verse.startIndex, offsetBy: offset)
            let upper = verse.unicodeScalars.index(lower, offsetBy: word.Verse.unicodeScalars.count)
            result[word.Word] = AttributedString(verse[lower..<upper])
            searchStart = range.upperBound
        }
        return result
    }
}
