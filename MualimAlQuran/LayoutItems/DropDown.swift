import SwiftUI

struct DropDown: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Binding var type: String
    @Binding var title: String
    @Binding var items: [String]
    @Binding var selected: String
    @Binding var vm: RecitationViewModel
    @Binding var audioHelper: AudioHelper
    @Binding var geo: GeometryProxy
    @State var isPresented = false
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
    
    private var closeButton: some View {
        Button {
            AppHaptics.tap()
            isPresented = false
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .semibold))
        }
        .tint(.primary)
        .accessibilityLabel(currentLanguage == "Ar" ? "إغلاق" : "Close")
    }

    @ViewBuilder
    private var closeControl: some View {
        if #available(iOS 26.0, *) {
            closeButton
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)
        } else {
            closeButton
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
        }
    }

    var body: some View {
        
        VStack {
            
            Button {
                AppHaptics.tap()
                
                isPresented = true
                
            } label: {
                
                HStack {
                    
                    Text(selected)
                        .font(currentLanguage == "Ar" ? .system(size: 16, weight: .bold) : .custom(hafs(), size: 16))
                        .foregroundColor(colorResource.lightButtonText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .padding(.leading, 10)
                        .padding(.trailing, 0)
                        .padding(.top, currentLanguage == "Ar" ? 14 : 8)
                        .padding(.bottom, currentLanguage == "Ar" ? 12 : 6)
                    
                    Spacer()
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 8, height: 6)
                        .padding(.trailing, 5)
                        .foregroundStyle(colorResource.lightButtonText)
                    
                }
            }
            .frame(maxWidth: .infinity)
            .background(colorResource.lightButton.opacity(0.5))
            .padding(.trailing, (type == "4") ? 0 : 1)
            .popover(isPresented: $isPresented) {
                
                var width: CGFloat {
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        
                        return (geo.size.width > 500) ? 500 : geo.size.width
                    }
                    else {
                        
                        return geo.size.width
                    }
                }
                
                var height: CGFloat {
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        
                        return (geo.size.height > 500) ? 500 : geo.size.height
                    }
                    else {
                        
                        return geo.size.height + geo.safeAreaInsets.bottom
                    }
                }
                
                ScrollViewReader { scrollView in
                    
                    VStack(spacing: 0) {
                        closeControl
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .environment(\.layoutDirection, currentLanguage == "Ar" ? .rightToLeft : .leftToRight)

                        List {
                            
                            ForEach(items, id: \.self) { item in
                                
                                var id: String {
                                    
                                    if (type == "1") {
                                        
                                        return item.split(separator: " ")[0].description
                                    }
                                    
                                    return ""
                                }
                                
                                Button {
                                    AppHaptics.tap()
                                    
                                    if (type == "1") {
                                        
                                        vm.surah.selected = item
                                        vm.surah.title = item
                                        
                                        loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected, trigger: "Surah", audioHelper: audioHelper)
                                    }
                                    
                                    if (type == "2") {
                                        
                                        vm.ayah.selected = item
                                        vm.ayah.title = item
                                        
                                        if (mvm.listSelected.StageID == 7) {
                                            
                                            loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "Ayah", audioHelper: audioHelper)
                                            
                                        } else {
                                            
                                            vm.scrollTarget = mvm.recitationItems.first{ $0.Ayah == item.split(separator: " ")[1] }!.id.description
                                        }
                                    }
                                    
                                    if (type == "3") {
                                        
                                        if (mvm.listSelected.StageID == 7) {
                                            
                                            vm.page.selected = item
                                            vm.page.title = item
                                            
                                            setMemorizingAyah(id: item.split(separator: " ")[0].description)
                                            loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "Ayah", audioHelper: audioHelper)
                                            
                                        } else {
                                            
                                            vm.page.selected = item
                                            vm.page.title = item
                                            
                                            let pageIndex = mvm.recitationItems.filter { $0.Page == vm.page.selected.split(separator: " ")[1] }
                                            
                                            if (!pageIndex.isEmpty) {
                                                
                                                vm.scrollTarget = mvm.recitationItems.first{ $0.Ayah == pageIndex[0].Ayah }!.id.description
                                                
                                            } else {
                                                
                                                loadSurah(
                                                    vm: vm,
                                                    mvm: mvm,
                                                    surah: mvm.verseByVerse.first { $0.Page == vm.page.selected.split(separator: " ")[1] }!.Surah,
                                                    trigger: "Page",
                                                    audioHelper: audioHelper)
                                            }
                                        }
                                    }
                                    
                                    if (type == "4") {
                                        
                                        if (mvm.listSelected.StageID == 7) {
                                            
                                            vm.juzu.selected = item
                                            vm.juzu.title = item
                                            
                                            setMemorizingTimes(id: item.split(separator: " ")[0].description)
                                            loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "Ayah", audioHelper: audioHelper)
                                            
                                        } else {
                                            
                                            vm.juzu.selected = item
                                            vm.juzu.title = item
                                            
                                            let juzuIndex = mvm.recitationItems.filter { $0.Juzu == vm.juzu.selected.split(separator: " ")[1] }
                                            
                                            if (!juzuIndex.isEmpty) {
                                                
                                                vm.scrollTarget = mvm.recitationItems.first{ $0.Ayah == juzuIndex[0].Ayah }!.id.description
                                                
                                            } else {
                                                
                                                loadSurah(
                                                    vm: vm,
                                                    mvm: mvm,
                                                    surah: mvm.verseByVerse.first { $0.Juzu == vm.juzu.selected.split(separator: " ")[1] }!.Surah,
                                                    trigger: "Juzu",
                                                    audioHelper: audioHelper)
                                            }
                                        }
                                    }
                                    
                                    isPresented = false
                                    
                                } label: {
                                    
                                    HStack {
                                        
                                        Text(item).foregroundStyle(Color.black)
                                        
                                        Spacer()
                                        
                                        if (item == selected) {
                                            Image(systemName: "checkmark").foregroundStyle(colorResource.primary_500)
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                        .scrollContentBackground(.hidden)
                        .contentMargins(.top, 0, for: .scrollContent)
                    }
                    .frame(width: width)
                    .frame(maxHeight: height)
                    .background(Color(uiColor: .systemGroupedBackground))
                    .task(id: isPresented) {
                        scrollView.scrollTo(selected, anchor: .center)
                    }
                    .environment(\.layoutDirection, (currentLanguage == "Ar") ? .rightToLeft : .leftToRight)
                }
            }
        }
    }
}

@MainActor
func loadSurah(vm: RecitationViewModel, mvm: MainViewModel, surah: String, trigger: String, audioHelper: AudioHelper, continueAudio: Bool = false, callback: (() -> ())? = nil) {
    
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
    
    vm.surahLoadRevision = UUID()
    vm.verseTapScrollRequest = nil
    vm.pendingAutomaticVerseScroll = nil
    vm.scrollTarget = "-1"
    if !continueAudio {
        vm.bookLayoutRevision = UUID()
        vm.stopAudio(player: audioHelper.player, hide: mvm.listSelected.StageID != 7)
        vm.selectedItem = 0
        vm.selectedWord = ""
        vm.selectedWordVerseID = nil
    }

    var data = mvm.verseByVerse
        .filter { $0.Surah == surah.split(separator: " ")[0] }
        .sorted { Int($0.Ayah)! < Int($1.Ayah)! }

    guard !data.isEmpty else { return }

    var ayahDDItems: [String] = []
    for i in (1...data.count) {
        ayahDDItems.append("\(ayahText) " + i.description)
    }
    vm.ayah.items = ayahDDItems

    if (mvm.listSelected.StageID == 7) {

        let range = Int(vm.ayah.selected.split(separator: " ")[1])!...Int(vm.ayah.selected.split(separator: " ")[1])! + (Int(vm.page.selected.split(separator: " ")[0])! - 1)

        data = data.filter { range.contains(Int($0.Ayah)!) }

        memorizingResetTotalCounter(vm: vm)
        memorizingResetData(vm: vm, data: data)
    }

    //region Basmalah
    if (basmalah(surah: surah, mvm: mvm)) {

        let basmalahItem = mvm.verseByVerse.first{ $0.Surah == "1" }!.copy()
        basmalahItem.Surah = data[0].Surah
        basmalahItem.SurahName = data[0].SurahName
        basmalahItem.SurahNameAr = data[0].SurahNameAr
        basmalahItem.SurahNameTr = data[0].SurahNameTr
        basmalahItem.Ayah = "0"
        basmalahItem.Page = data[0].Page
        basmalahItem.Juzu = data[0].Juzu
        basmalahItem.basmalah = true

        data.insert(basmalahItem, at: 0)
    }
    //endregion

    mvm.recitationItems = data
    if (!data.isEmpty) {
        vm.surah.title = vm.surah.items.first { $0.split(separator: " ")[0] == data[0].Surah }!
        vm.scrollTarget = "0" // Android
    }

    if (trigger == "Surah") {

        if (!mvm.lessonSelected.FromMemorizing) {
            vm.ayah.title = "\(ayahText) 1"
            vm.ayah.selected = "\(ayahText) 1"
        }

        if (mvm.listSelected.StageID != 7) {

            vm.page.title = "\(mvm.home.Page) \(data[0].Page)"
            vm.page.selected = "\(mvm.home.Page) \(data[0].Page)"

            vm.juzu.title = "\(juzuText) \(data[0].Juzu)"
            vm.juzu.selected = "\(juzuText) \(data[0].Juzu)"
        }
    }

    if (mvm.listSelected.StageID != 7) {

        if (trigger == "Page" || trigger == "Juzu") {

            vm.surah.title = vm.surah.items.first { $0.split(separator: " ")[0] == data[0].Surah }!
            vm.surah.selected = vm.surah.items.first { $0.split(separator: " ")[0] == data[0].Surah }!
        }


        if (trigger == "Page") {

            let ayahToSelect = mvm.recitationItems.first { $0.Page == vm.page.selected.split(separator: " ")[1] }!.Ayah

            vm.ayah.title = "\(ayahText) \(ayahToSelect)"
            vm.ayah.selected = "\(ayahText) \(ayahToSelect)"

            vm.juzu.title = "\(juzuText) \(data[0].Juzu)"
            vm.juzu.selected = "\(juzuText) \(data[0].Juzu)"

            vm.scrollTarget = mvm.recitationItems.first{ $0.Page == vm.page.selected.split(separator: " ")[1] }!.id.description
        }

        if (trigger == "Juzu") {

            let ayahToSelect = mvm.recitationItems.first { $0.Juzu == vm.juzu.selected.split(separator: " ")[1] }!.Ayah

            vm.ayah.title = "\(ayahText) \(ayahToSelect)"
            vm.ayah.selected = "\(ayahText) \(ayahToSelect)"

            vm.page.title = "\(mvm.home.Page) \(data[0].Page)"
            vm.page.selected = "\(mvm.home.Page) \(data[0].Page)"

            vm.scrollTarget = mvm.recitationItems.first{ $0.Juzu == vm.juzu.selected.split(separator: " ")[1] }!.id.description
        }
    }

    callback?()
}

@MainActor
func loadMemorizingAyah(vm: RecitationViewModel, mvm: MainViewModel, trigger: String, audioHelper: AudioHelper) {
    
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
    
    if (mvm.listSelected.StageID == 7) {
        
        audioHelper.pauseVerse()
        vm.audioBarStatus = "play"
        vm.selectedItem = 0
        vm.audioPlaying = false
    }
    
    mvm.recitationItems.removeAll()
    
    var data = mvm.verseByVerse
        .filter { $0.Surah == vm.surah.selected.split(separator: " ")[0] }
        .sorted { Int($0.Ayah)! < Int($1.Ayah)! }
    
    var surahChanged = false
    var startAyah = Int(vm.ayah.selected.split(separator: " ")[1])!
    if (trigger == "NextButton") {
        
        startAyah = Int(vm.ayah.selected.split(separator: " ")[1])! + Int(vm.page.selected.split(separator: " ")[0])!
        
        if (startAyah > data.count) {
            
            if (vm.surah.selected.split(separator: " ")[0] != "114") {
                
                vm.surah.selected = vm.surah.items.first{ $0.split(separator: " ")[0] == (Int(vm.surah.selected.split(separator: " ")[0])! + 1).description }!
                vm.ayah.title = "\(ayahText) 1"
                vm.ayah.selected = "\(ayahText) 1"
                
                loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected, trigger: "Surah", audioHelper: audioHelper)
                
                surahChanged = true
            }
            else {
                
                startAyah = Int(vm.ayah.selected.split(separator: " ")[1])!
            }
        }
        else {
            
            vm.ayah.title = "\(ayahText) \(startAyah)"
            vm.ayah.selected = "\(ayahText) \(startAyah)"
        }
    }
    else if (trigger == "PrevButton") {
        
        startAyah = Int(vm.ayah.selected.split(separator: " ")[1])! - Int(vm.page.selected.split(separator: " ")[0])!
        
        if (startAyah < 1) {
            
            if (vm.surah.selected.split(separator: " ")[0] != "1") {
                
                vm.surah.selected = vm.surah.items.first{ $0.split(separator: " ")[0] == (Int(vm.surah.selected.split(separator: " ")[0])! - 1).description }!
                vm.ayah.title = "\(ayahText) 1"
                vm.ayah.selected = "\(ayahText) 1"
                
                loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected, trigger: "Surah", audioHelper: audioHelper)
                
                surahChanged = true
            }
            else {
                
                startAyah = 1
            }
        }
        else {
            
            vm.ayah.title = "\(ayahText) \(startAyah)"
            vm.ayah.selected = "\(ayahText) \(startAyah)"
        }
    }
    
    var start = startAyah
    if (surahChanged) {
        start = 1
    }
    
    var end = start + (Int(vm.page.selected.split(separator: " ")[0])! - 1)
    
    if (end > data.count) {
        end = data.count
    }
    
    data = data.filter { Int($0.Ayah)! >= start && Int($0.Ayah)! <= end }
    
    memorizingResetTotalCounter(vm: vm)
    memorizingResetData(vm: vm, data: data)
    
    mvm.recitationItems = data
    
    if (!surahChanged) {
        vm.scrollTarget = "0" // Android
    }
}
