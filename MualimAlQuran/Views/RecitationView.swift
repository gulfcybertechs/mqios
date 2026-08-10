import SwiftUI

class RecDropDown: ObservableObject
{
    var title: String = ""
    var items: [String] = []
    var selected: String = "1"
}

class RecitationViewModel: ObservableObject
{
    var initialLoad = false

    @Published var selectedItem = 0
    @Published var selectedWord = ""

    @Published var audioBarVisible = false
    @Published var audioBarStatus = "play"
    @Published var audioPlaying = false

    @Published var bookmarked = ""

    @Published var surah = RecDropDown()
    @Published var ayah = RecDropDown()
    @Published var page = RecDropDown()
    @Published var juzu = RecDropDown()

    var memorizingTotalCounter = 15
    
    @Published var scrollTarget = "-1"
    @Published var ddlClicked = "Surah"
    
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
    
    func initiate(mvm: MainViewModel) {
        
        if (currentLanguage == "Ar") {
            surah.title = "1 الفَاتِحَة"
            ayah.title = "الآية 1"
            page.title = mvm.home.Page + " 1"
            juzu.title = "الجزء 1"
            
            surah.items = mvm.surahNamesAr
        }
        else {
            surah.title = "1 FÂTIḤAH"
            ayah.title = "Ayah 1"
            page.title = "Page 1"
            juzu.title = "Juzu 1"
            
            surah.items = mvm.surahNames
        }
        
        surah.selected = surah.items[0]
        
        var ayahDDItems: [String] = []
        for i in (1...mvm.recitationItems.count) {
            ayahDDItems.append("\(ayahText) " + i.description)
        }
        ayah.items = ayahDDItems
        ayah.selected = ayah.items[0]
        
        var pageDDItems: [String] = []
        for i in (1...604) {
            pageDDItems.append("\(mvm.home.Page) " + i.description)
        }
        page.items = pageDDItems
        page.selected = page.items[0]

        var juzuDDItems: [String] = []
        for i in (1...30) {
            juzuDDItems.append("\(juzuText) " + i.description)
        }
        juzu.items = juzuDDItems
        juzu.selected = juzu.items[0]
    }        
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct RecitationView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @StateObject var vm = RecitationViewModel()    
    @State private var offset: CGFloat = 50
    @State var player = Player()
    @State var audioHelper: AudioHelper = AudioHelper(player: .constant(Player()))
    @State var showScrollUp = false
    @Environment(\.dismiss) private var dismiss
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                AppBG()
                
                ScrollViewReader { scrollView in
                    
                    ScrollView {
                        
                        VStack(spacing: 0) {
                            
                            Spacer().frame(height: 10)
                            
                            Text(mvm.listSelected.Title.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: ""))
                                .font(.custom("opensans", size: 22))
                                .bold()
                                .lineSpacing(8)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            
                            Text(mvm.lessonSelected.Title.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: ""))
                                .font(.custom("opensans", size: 20))
                                .foregroundColor(colorResource.maroon)
                                .lineSpacing(6)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 15)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                            
                            HStack(spacing: 0) {
                                             
                                VStack(spacing: 0) {
                                    DropDown(
                                        type: .constant("1"),
                                        title: $vm.surah.title,
                                        items: $vm.surah.items,
                                        selected: $vm.surah.selected,
                                        vm: .constant(vm),
                                        audioHelper: .constant(audioHelper),
                                        geo: .constant(geo)
                                    )
                                }
                                .frame(width: (geo.size.width - 20) * 0.31)
                                
                                VStack(spacing: 0) {
                                    DropDown(
                                        type: .constant("2"),
                                        title: $vm.ayah.title,
                                        items: $vm.ayah.items,
                                        selected: $vm.ayah.selected,
                                        vm: .constant(vm),
                                        audioHelper: .constant(audioHelper),
                                        geo: .constant(geo)
                                    )
                                }
                                .frame(width: (geo.size.width - 20) * 0.23)
                                
                                VStack(spacing: 0) {
                                    DropDown(
                                        type: .constant("3"),
                                        title: $vm.page.title,
                                        items: $vm.page.items,
                                        selected: $vm.page.selected,
                                        vm: .constant(vm),
                                        audioHelper: .constant(audioHelper),
                                        geo: .constant(geo)
                                    )
                                }
                                .frame(width: (geo.size.width - 20) * 0.23)
                                
                                VStack(spacing: 0) {
                                    DropDown(
                                        type: .constant("4"),
                                        title: $vm.juzu.title,
                                        items: $vm.juzu.items,
                                        selected: $vm.juzu.selected,
                                        vm: .constant(vm),
                                        audioHelper: .constant(audioHelper),
                                        geo: .constant(geo)
                                    )
                                }
                                .frame(width: (geo.size.width - 20) * 0.23)
                            }                            
                            .background(Color(hex: "F3F3F3"))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            //.shadow(color: Color.gray, radius: 3)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                            
                        }
                        .id("Header")
                        .background(
                            GeometryReader(content: { geometry in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).origin.y)
                            })
                        )
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            
                            DispatchQueue.main.async {
                                
                                if (value < -100) {
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        showScrollUp = true
                                    }
                                }
                                else {
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        showScrollUp = false
                                    }
                                }
                            }
                        }
                        
                        ZStack {
                            
                            if (mvm.recitationItems.isEmpty) {
                                
                                ProgressView()
                            }
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 1000), alignment: .leading)], spacing: 0) {
                                                                                                
                                ForEach(mvm.recitationItems) { item in
                                    
                                    RecitationItem(item: .constant(item), vm: .constant(vm), player: $player, audioHelper: $audioHelper)
                                }
                            }
                        }
                        
                        //region Memorizing Footer
                        if (!mvm.recitationItems.isEmpty && mvm.lessonSelected.StageID == 7) {
                                                        
                            let completed = mvm.recitationItems.allSatisfy { $0.memorized == true }
                            
                            HStack
                            {
                                let completedColor = (completed) ? colorResource.danger : colorResource.orange
                                let completedText = (completed) ? mvm.home.Incomplete : mvm.home.Completed
                                let completedIcon = (completed) ? "icloud.and.arrow.down.fill" : "icloud.and.arrow.up.fill"
                                
                                Button(action: {
                                                                        
                                    $mvm.recitationItems.forEach {
                                        if (completed) {
                                            $0.memorized.wrappedValue = false
                                            removeMemorizing(userID: getUser(type: "ID"), surah: $0.Surah.wrappedValue, ayah: $0.Ayah.wrappedValue)
                                        } else {
                                            $0.memorized.wrappedValue = true
                                            setMemorizing(userID: getUser(type: "ID"), surah: $0.Surah.wrappedValue, surahName: $0.SurahNameTr.wrappedValue, ayah: $0.Ayah.wrappedValue, verses: vm.page.selected.split(separator: " ")[0].description, repetitions: vm.juzu.selected.split(separator: " ")[0].description, _from: mvm.recitationItems[0].Ayah, push: true)
                                        }
                                    }
                                })
                                {
                                    
                                    Text(completedText)
                                    
                                    Spacer().frame(width: 10)
                                    
                                    Image(systemName: completedIcon)
                                        .foregroundColor(colorResource.white)
                                        .font(.system(size: 20))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(completedColor)
                                
                                Spacer().frame(width: 10)
                                
                                Button(action: { mvm.selectedTab = Tab.account }) {
                                    
                                    Text(mvm.home.Progress)
                                    
                                    Spacer().frame(width: 5)
                                    
                                    Image(systemName: "calendar")
                                        .foregroundColor(colorResource.white)
                                        .font(.system(size: 24))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(colorResource.primary_500)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 80)
                        }
                        //endregion
                    }
                    .padding(.top, (safeArea?.top ?? 0) + 1)
                    .padding(.leading, safeArea?.left)
                    .padding(.trailing, safeArea?.right)
                    .frame(maxWidth: .infinity)
                    .task(id: vm.scrollTarget) {
                        
                        if (vm.scrollTarget != "-1") {
                            
                            var firstID = ""
                            if (!mvm.recitationItems.isEmpty) {
                                firstID = mvm.recitationItems[0].id.description
                            }
                            
                            if (vm.scrollTarget == firstID || vm.scrollTarget == "0") {
                                scrollView.scrollTo("Header")
                            }
                            else {                                
                                scrollView.scrollTo(Int(vm.scrollTarget) ?? 0, anchor: .top)
                            }
                            
                            vm.scrollTarget = "-1"
                        }
                    }
                }
                
                //region Audio Bar
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    HStack(spacing: 0)
                    {
                        if (mvm.lessonSelected.StageID == 7) {
                            
                            Button(action: { loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "PrevButton", audioHelper: audioHelper) })
                            {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .padding(10)
                            }
                            .frame(width: 50, height: 50)
                            .background(colorResource.orange)
                        }
                        
                        
                        VStack(spacing: 0) {
                            
                            if (currentLanguage == "Ar" && mvm.listSelected.id == 5) {
                                // No Reciter
                            }
                            else {
                                
                                DropDownReciter()
                            }
                        }
                        
                        Button(action: {
                            
                            if (mvm.lessonSelected.StageID == 7) {
                                
                                if (vm.selectedItem == 0 && !mvm.recitationItems.isEmpty) {
                                    
                                    // Android
                                    vm.scrollTarget = mvm.recitationItems[0].id.description
                                    vm.selectedItem = mvm.recitationItems[0].id
                                    vm.audioPlaying = true
                                }
                            }
                            
                            if (vm.audioBarStatus == "stop") {
                                audioHelper.pauseVerse()
                                vm.audioBarStatus = "play"
                            } else if (vm.audioBarStatus == "play") {
                                audioHelper.startVerse()
                                vm.audioBarStatus = "stop"
                            }
                            
                        }) 
                        {
                            
                            if (vm.audioBarStatus == "loading") {
                                
                                ProgressView()
                                
                            } else {
                                
                                var audioIcon: String {
                                    
                                    if (vm.audioBarStatus == "stop") {
                                        return "stop.circle.fill"
                                    } else {
                                        return "play.fill"
                                    }
                                }
                                
                                Image(systemName: audioIcon)
                                    .foregroundColor(colorResource.white)
                                    .font(.system(size: 24))
                            }
                        }
                        .frame(width: 50, height: 50)
                        .background(colorResource.primary_500)
                        
                        if (mvm.lessonSelected.StageID == 7) {
                            Button(action: { loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "NextButton", audioHelper: audioHelper) })
                            {
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .padding(10)
                            }
                            .frame(width: 50, height: 50)
                            .background(colorResource.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    //.shadow(color: Color.black, radius: 13, x: 5, y: 5)
                    .background(colorResource.darkBlue)
                    .offset(x: 0.0, y: offset)
                }
                .task(id: vm.audioBarVisible) {
                    
                    withAnimation {
                        
                        if (vm.audioBarVisible) {
                            offset = 0
                        }
                        else {
                            offset = 50
                        }
                    }
                }
                //endregion
                
                //region Scroll Up Button
                if (mvm.lessonSelected.StageID != 7 && showScrollUp) {
                    
                    var scrollUpPosition: CGFloat {
                        
                        if (vm.audioBarVisible) {
                            return -60
                        }
                    
                        return -10
                    }
                    
                    VStack(spacing: 0)
                    {
                        Spacer()
                        
                        HStack(spacing: 0) {
                            
                            Spacer()
                            
                            Button(action: {
                                
                                vm.scrollTarget = "0"
                                
                            }) {
                                Image(systemName: "chevron.up")
                                    .foregroundColor(colorResource.white)
                                    .frame(width: 48, height: 48)
                                    .padding(10)
                            }
                            .frame(width: 48, height: 48)
                            .background(colorResource.maroon)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .offset(x: (-10), y: scrollUpPosition)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                }
                //endregion                
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity)
            .clipped()
            .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
            .onAppear() {
                
                mvm.viewLevel = "lesson"
                mvm.back = false                
                
                if (!mvm.recitationInitialLoad) {
                    
                    mvm.recitationInitialLoad = true
                    vm.initiate(mvm: mvm)
                    
                    vm.bookmarked = getBookmark(mvm: mvm)
                    
                    if (mvm.lessonSelected.StageID == 7) {
                        
                        vm.audioBarVisible = true
                    }
                    
                    audioHelper = AudioHelper(player: $player)
                    audioHelper.prepareRecitationDir()
                    
                    if (mvm.lessonSelected.StageID == 7) {
                        vm.initialLoad = true
                        loadMemorizingRecitation(vm: vm, mvm: mvm, audioHelper: audioHelper)
                    }
                }
            } 
            .task(id: mvm.backForce) {
                if (mvm.backForce) { dismiss() }
            }
            .task(id: mvm.back) {
                if (mvm.back) {
                    mvm.back = false
                    if (mvm.lessonSelected.StageID == 7) { mvm.listSelected = ListModel() }
                    dismiss();
                }
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
}

func loadMemorizingRecitation(vm: RecitationViewModel, mvm: MainViewModel, audioHelper: AudioHelper) {

    @AppStorage("language") var currentLanguage = getLanguage()
    
    var ayahText:String {
        if (currentLanguage == "Ar") {
            "آيات"
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
    
    var timesText:String {
        if (currentLanguage == "Ar") {
            "مرات"
        }
        else {
            "Times"
        }
    }
    
    vm.page.title =  "3 \(ayahText)"
    vm.page.selected = "3 \(ayahText)"
    if (getMemorizingAyah() != "") {
        vm.page.title = getMemorizingAyah() + " \(ayahText)"
        vm.page.selected = getMemorizingAyah() + " \(ayahText)"
    }

    vm.juzu.title = "3 \(timesText)"
    vm.juzu.selected = "3 \(timesText)"
    if (getMemorizingTimes() != "") {
        vm.juzu.title = getMemorizingTimes() + " \(timesText)"
        vm.juzu.selected = getMemorizingTimes() + " \(timesText)"
    }

    if (mvm.lessonSelected.FromMemorizing) {

        vm.surah.selected = vm.surah.items.first { $0.split(separator: " ")[0] == mvm.lessonSelected.MemorizingSurah }!
        vm.surah.title = vm.surah.items.first { $0.split(separator: " ")[0] == mvm.lessonSelected.MemorizingSurah }!

        vm.ayah.selected = "\(ayahText) \(mvm.lessonSelected.MemorizingAyah)"
        vm.ayah.title = "\(ayahText) \(mvm.lessonSelected.MemorizingAyah)"

        loadSurah(vm: vm, mvm: mvm, surah: vm.surah.selected, trigger: "Surah", audioHelper: audioHelper)
    }

    memorizingResetTotalCounter(vm: vm)

    let data = mvm.recitationItems.filter { Int($0.Ayah)! <= Int(vm.page.selected.split(separator: " ")[0])! }
    mvm.recitationItems.removeAll()
    mvm.recitationItems = data

    memorizingResetData(vm: vm, data: mvm.recitationItems)

    var pageDDItems: [String] = []
    pageDDItems.append("3 \(ayahText)")
    pageDDItems.append("5 \(ayahText)")
    pageDDItems.append("7 \(ayahText)")
    vm.page.items = pageDDItems

    var juzuDDItems: [String] = []
    juzuDDItems.append("3 \(timesText)")
    juzuDDItems.append("5 \(timesText)")
    juzuDDItems.append("7 \(timesText)")
    vm.juzu.items = juzuDDItems
}
