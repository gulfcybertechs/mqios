import SwiftUI
import UIKit

class RecDropDown: ObservableObject
{
    var title: String = ""
    var items: [String] = []
    var selected: String = "1"
}

class RecitationViewModel: ObservableObject
{
    var initialLoad = false

    // Non-published bookkeeping never drives reader layout or playback.
    var readingPositionActive = false
    var readingPositionLoading = false
    var pendingReadingVerseID: Int?
    var readingPositionRestoration = UUID()
    // Invalidates queued page resets whenever a local Surah load replaces data.
    var surahLoadRevision = UUID()
    // Remount only the horizontal pager after an explicit load or display-mode change.
    @Published var bookLayoutRevision = UUID()

    @Published var verseTapScrollRequest: RecitationVerseTapScrollRequest?
    // Origin bookkeeping only; scrollTarget still mounts/routes the playing verse.
    var pendingAutomaticVerseScroll: RecitationVerseTapScrollRequest?

    func requestAutomaticVerseScroll(to verse: RecitationModel) {
        pendingAutomaticVerseScroll = RecitationVerseTapScrollRequest(
            verse: RecitationVerseTapScrollID(surah: verse.Surah, verseID: verse.id))
        scrollTarget = verse.id.description
    }

    @Published var selectedItem = 0
    @Published var selectedWord = ""

    @Published var audioBarVisible = false
    @Published var audioBarStatus = "play"
    @Published var audioPlaying = false
    @Published var audioPlayRequest = UUID()
    var audioRequestID = UUID()
    var audioNeedsStart = true
    var selectedWordVerseID: Int?

    func requestSelectedAudio() {
        audioPlaying = true
        audioPlayRequest = UUID()
    }

    func stopAudio(player: Player, hide: Bool) {
        // Invalidates downloads and continuation callbacks that are still pending.
        audioRequestID = UUID()
        if pendingAutomaticVerseScroll != nil {
            pendingAutomaticVerseScroll = nil
            scrollTarget = "-1"
        }
        audioPlaying = false
        audioNeedsStart = true
        player.vm = nil
        player.stop()
        audioBarStatus = "play"
        if hide { audioBarVisible = false }
    }

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

private enum RecitationReadingMode: Int, Hashable {
    case scrolling, paging
}

private struct RecitationReadingPosition: Codable, Equatable {
    let surah: String
    let page: String

    init(_ verse: RecitationModel) {
        surah = verse.Surah
        page = verse.Page
    }

    func firstVerse(in verses: [RecitationModel]) -> RecitationModel? {
        verses.first { !$0.basmalah && $0.Surah == surah && $0.Page == page }
    }
}

// Shared across full-Surah readers and independent of bookmarks and memorization.
private enum RecitationReaderPreferences {
    private static let positionKey = "quran.reader.position.v1"
    private static let modeKey = "quran.reader.mode.v1"

    static var readingMode: RecitationReadingMode {
        get {
            RecitationReadingMode(rawValue: UserDefaults.standard.integer(forKey: modeKey)) ?? .scrolling
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: modeKey) }
    }

    static var position: RecitationReadingPosition? {
        guard let data = UserDefaults.standard.data(forKey: positionKey) else { return nil }
        return try? JSONDecoder().decode(RecitationReadingPosition.self, from: data)
    }

    static func remember(_ verse: RecitationModel) {
        let next = RecitationReadingPosition(verse)
        guard position != next, let data = try? JSONEncoder().encode(next) else { return }
        UserDefaults.standard.set(data, forKey: positionKey)
    }
}

// Geometry is observed in backgrounds only; it never supplies reader dimensions.
private struct RecitationReadingVisibilityKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] { [:] }
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, frame in frame })
    }
}

private struct RecitationReadingPageState: Equatable {
    let page: RecitationBookPageID
    let alignedPage: RecitationBookPageID?
    let isScrolling: Bool
    let appliedRequest: UUID?
}

// Local appearance only; selection still uses the reader's existing binding.
private struct RecitationReadingModeSwitch: View {
    @Binding var selection: RecitationReadingMode
    let isArabic: Bool
    @Namespace private var selectionAnimation
    @Environment(\.recitationControlHeight) private var controlHeight

    var body: some View {
        HStack(spacing: 0) {
            segment(.scrolling, icon: "text.alignleft",
                label: isArabic ? "تمرير متواصل" : "Continuous scrolling")
            segment(.paging, icon: "book",
                label: isArabic ? "صفحة بصفحة" : "Page by page")
        }
        .padding(2)
        .frame(height: controlHeight)
        .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.18), value: selection)
    }

    private func segment(_ mode: RecitationReadingMode, icon: String, label: String) -> some View {
        Button {
            AppHaptics.tap()
            selection = mode
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity)
                .frame(height: max(0, controlHeight - 4))
                .background {
                    if selection == mode {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .systemBackground))
                            .matchedGeometryEffect(id: "selection", in: selectionAnimation)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
        .accessibilityAddTraits(selection == mode ? .isSelected : [])
    }
}

private struct RecitationAutoplayButton: View {
    @Binding var enabled: Bool
    let isArabic: Bool
    @Environment(\.recitationControlHeight) private var controlHeight

    var body: some View {
        Button {
            AppHaptics.tap()
            enabled.toggle()
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundStyle(enabled ? Color.white : Color.primary)
                .frame(width: controlHeight, height: controlHeight)
                .background(enabled ? colorResource.primary_500 : Color(uiColor: .tertiarySystemFill),
                    in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isArabic ? "التشغيل التلقائي عند اختيار آية" : "Autoplay on verse selection"))
        .accessibilityValue(Text(enabled ? (isArabic ? "مفعّل" : "On") : (isArabic ? "متوقف" : "Off")))
        .accessibilityAddTraits(enabled ? .isSelected : [])
    }
}

private struct RecitationTajweedButton: View {
    @Binding var enabled: Bool
    let isArabic: Bool
    let isLocked: Bool
    @Environment(\.recitationControlHeight) private var controlHeight

    private var showsColors: Bool { isLocked || enabled }

    var body: some View {
        Button {
            guard !isLocked else { return }
            AppHaptics.tap()
            enabled.toggle()
        } label: {
            Text("Tj")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(showsColors ? Color.white : Color.primary)
                .frame(width: controlHeight, height: controlHeight)
                .background(showsColors ? colorResource.primary_500 : Color(uiColor: .tertiarySystemFill),
                    in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .accessibilityLabel(Text(isArabic ? "ألوان التجويد" : "Tajweed colors"))
        .accessibilityValue(Text(showsColors ? (isArabic ? "مفعّل" : "On") : (isArabic ? "متوقف" : "Off")))
        .accessibilityAddTraits(showsColors ? .isSelected : [])
    }
}

// A printed page can contain several Surahs. Each Surah portion remains its own page.
private struct RecitationBookPageID: Hashable {
    let surah: String
    let number: Int
}

private struct RecitationBookVerseScrollID: Hashable {
    let surah: String
    let verseID: Int
}

private struct RecitationBookPage: Identifiable {
    let id: RecitationBookPageID
    let items: [RecitationModel]
    let surahItems: [RecitationModel]

    var number: Int { id.number }
    var surah: String { id.surah }

    static func group(_ items: [RecitationModel]) -> [RecitationBookPage] {
        guard let surah = items.first?.Surah else { return [] }
        return Dictionary(grouping: items, by: \.Page)
            .compactMap { entry -> RecitationBookPage? in
                guard let number = Int(entry.key), number > 0 else { return nil }
                return RecitationBookPage(id: RecitationBookPageID(surah: surah, number: number),
                    items: entry.value, surahItems: items)
            }
            .sorted { $0.number < $1.number }
    }
}

private struct RecitationBookScrollRequest: Equatable {
    let page: RecitationBookPageID
    let verseID: Int?
    var showsHeader = false
    var scrollVertically = true
    var automaticVerseScroll: RecitationVerseTapScrollRequest? = nil
    let selectionRevision: UUID?
    let loadRevision: UUID
    let revision = UUID()
}

private struct RecitationBookPageMetrics: Equatable, Sendable {
    let layoutRevision: UUID
    let height: CGFloat
    let isAligned: Bool
}

private struct RecitationBookPagingActivity: ViewModifier {
    @Binding var isScrolling: Bool
    @Binding var selectedPage: RecitationBookPageID
    @Binding var settledPage: RecitationBookPageID?
    let revision: UUID
    @Binding var currentRevision: UUID
    @GestureState private var isDragging = false

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onScrollPhaseChange { _, phase in
                guard revision == currentRevision else { return }
                // Tracking includes a finger held still midway through a swipe.
                isScrolling = phase != .idle
                // Native completion also works when lazy RTL page geometry has
                // stopped reporting an exact zero horizontal offset.
                settledPage = phase == .idle ? selectedPage : nil
            }
        } else {
            // iOS 17 also requires a fully aligned page before any resize below.
            content.simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .updating($isDragging) { _, dragging, _ in dragging = true }
            )
            .onChange(of: isDragging) { _, dragging in
                guard revision == currentRevision else { return }
                isScrolling = dragging
            }
        }
    }
}

private enum RecitationBookVerticalAnchor: Hashable {
    case pageStart
}

private struct RecitationSafeAreaRefreshRequest: Equatable {
    let phase: ScenePhase
    let revision: UUID
}

private struct RecitationBookScrollLayoutRequest: Equatable {
    let layoutRevision: UUID
    let request: RecitationBookScrollRequest
}

// Only the page bar, verses and footer belong to the horizontal pager.
// Its measured height lets the shared outer scroll view scroll the whole reader.
private struct RecitationBookPageView<Footer: View>: View {
    let page: RecitationBookPage
    let layoutRevision: UUID
    @ObservedObject var vm: RecitationViewModel
    @Binding var player: Player
    @Binding var audioHelper: AudioHelper
    let footer: Footer
    let onMetricsChange: (RecitationBookPageID, RecitationBookPageMetrics) -> Void

    var body: some View {
        let observedRevision = layoutRevision
        return VStack(spacing: 0) {
            // A single Quran page is small enough to measure all its verses.
            VStack(spacing: 0) {
                ForEach(page.items) { item in
                    RecitationItem(item: .constant(item), vm: .constant(vm), player: $player,
                        audioHelper: $audioHelper, showsBookmark: false)
                        .id(RecitationBookVerseScrollID(surah: page.surah, verseID: item.id))
                }
            }
            .background(Color(uiColor: .systemBackground).opacity(0.85), in: RoundedRectangle(cornerRadius: 4))
            .environment(\.recitationDisplayItems, page.surahItems)
            .allowsHitTesting(page.surah == vm.surah.selected.split(separator: " ").first?.description)

            footer
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        // Observe the intrinsic page before its outer slot is given a viewport height.
        // Horizontal pixels are reduced to alignment, so a drag does not publish every offset.
        .onGeometryChange(for: RecitationBookPageMetrics.self) { geometry in
            let height = geometry.size.height
            let minX = geometry.frame(in: .named("RecitationBookPager")).minX
            return RecitationBookPageMetrics(layoutRevision: observedRevision,
                height: height.isFinite && height > 0 ? height.rounded(.up) : 0,
                isAligned: minX.isFinite && abs(minX) < 0.5)
        } action: { metrics in
            onMetricsChange(page.id, metrics)
        }
    }
}

// Verse taps use an anchor owned by the outer vertical reader. A verse ID
// nested inside the horizontal pager can otherwise target that pager instead.
struct RecitationVerseTapScrollID: Hashable {
    let surah: String
    let verseID: Int
}

struct RecitationVerseTapScrollRequest: Equatable {
    let verse: RecitationVerseTapScrollID
    let revision = UUID()
}

enum RecitationVerseTapCoordinateSpace: Hashable {
    case content
}

struct RecitationVerseTapPositionsKey: PreferenceKey {
    static var defaultValue: [RecitationVerseTapScrollID: CGFloat] { [:] }

    static func reduce(value: inout [RecitationVerseTapScrollID: CGFloat],
                       nextValue: () -> [RecitationVerseTapScrollID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, y in y })
    }
}

private struct RecitationVerseTapScrollLayout: Equatable {
    let request: RecitationVerseTapScrollRequest?
    let y: CGFloat?
}

private struct RecitationVerseTapScrolling: ViewModifier {
    @ObservedObject var vm: RecitationViewModel
    let scrollView: ScrollViewProxy
    @State private var positions: [RecitationVerseTapScrollID: CGFloat] = [:]
    @State private var appliedRequest: UUID?

    init(vm: RecitationViewModel, scrollView: ScrollViewProxy) {
        self.vm = vm
        self.scrollView = scrollView
        // Changing display mode must not replay an earlier verse tap.
        _appliedRequest = State(initialValue: vm.verseTapScrollRequest?.revision)
    }

    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: RecitationVerseTapCoordinateSpace.content)
            .overlay(alignment: .top) {
                if let request = vm.verseTapScrollRequest,
                   let y = positions[request.verse], y.isFinite {
                    // An overlay supplies the target without adding content height.
                    VStack(spacing: 0) {
                        Color.clear.frame(height: max(0, y))
                        Color.clear.frame(height: 1).id(request.revision)
                    }
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
            .onPreferenceChange(RecitationVerseTapPositionsKey.self) { next in
                if positions != next { positions = next }
            }
            .task(id: RecitationVerseTapScrollLayout(request: vm.verseTapScrollRequest,
                y: vm.verseTapScrollRequest.flatMap { positions[$0.verse] })) {
                guard let request = vm.verseTapScrollRequest,
                      let y = positions[request.verse], y.isFinite,
                      appliedRequest != request.revision else { return }
                // Wait until SwiftUI has mounted the outer anchor at the verse's Y.
                await Task.yield()
                guard !Task.isCancelled,
                      vm.verseTapScrollRequest?.revision == request.revision else { return }
                withAnimation(.easeInOut(duration: 0.24)) {
                    scrollView.scrollTo(request.revision, anchor: .top)
                }
                appliedRequest = request.revision
            }
    }
}

struct RecitationView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @StateObject var vm = RecitationViewModel()    
    @State var player = Player()
    @State var audioHelper: AudioHelper = AudioHelper(player: .constant(Player()))
    @State var showScrollUp = false
    @AppStorage("quran.reader.autoplay.v1") private var verseAutoplay = true
    @AppStorage("quran.reader.tajweed.v1") private var tajweedColors = false
    @State private var readingMode = RecitationReaderPreferences.readingMode
    @State private var bookPageID = RecitationBookPageID(surah: "", number: 0)
    // Stable, lightweight page data; LazyHStack creates only nearby page views.
    @State private var bookPages: [RecitationBookPage] = []
    @State private var bookScrollRequest: RecitationBookScrollRequest?
    @State private var bookPagerLayoutRevision: UUID?
    @State private var bookPageHeights: [RecitationBookPageID: CGFloat] = [:]
    @State private var bookPagerHeight: CGFloat?
    @State private var bookPagerAlignedPage: RecitationBookPageID?
    @State private var bookPagerNativeSettledPage: RecitationBookPageID?
    @State private var bookHeaderScrollRequest = UUID()
    @State private var bookPagerIsScrolling = false
    @State private var appliedBookScrollRequest: UUID?
    @State private var committedBookPageID: RecitationBookPageID?
    @Environment(\.layoutDirection) private var readerLayoutDirection
    @Environment(\.scenePhase) private var scenePhase
    @State private var safeAreaRefreshRequest = UUID()
    
    @State var safeArea = UIApplication.shared.firstKeyWindow?.safeAreaInsets
    
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                AppBG()
                
                if isPagedReading {
                    pagedReader(geo: geo)
                } else {
                    scrollingReader(geo: geo)
                }

                //region Audio Bar
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button {
                            AppHaptics.tap()
                            vm.stopAudio(player: player, hide: true)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.primary)
                                .frame(width: 50, height: 50)
                                .background(Color(uiColor: .tertiarySystemFill))
                                .background(Color(uiColor: .systemBackground))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(currentLanguage == "Ar" ? "إغلاق مشغل الصوت" : "Close audio player"))

                        HStack(spacing: 0)
                        {
                            if (mvm.lessonSelected.StageID == 7) {

                                Button(action: { AppHaptics.tap(); loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "PrevButton", audioHelper: audioHelper) })
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

                                AppHaptics.tap()
                                toggleAudioPlayback()

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
                                Button(action: { AppHaptics.tap(); loadMemorizingAyah(vm: vm, mvm: mvm, trigger: "NextButton", audioHelper: audioHelper) })
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
                        .environment(\.layoutDirection, currentLanguage == "Ar" ? .leftToRight : readerLayoutDirection)
                        .frame(maxWidth: .infinity)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .background(colorResource.darkBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 3)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityAction(.escape) { vm.stopAudio(player: player, hide: true) }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    // A short slide makes the entrance visible for the full duration.
                    // Opacity also keeps the hidden player completely out of sight.
                    .offset(y: vm.audioBarVisible ? 0 : 100 + geo.safeAreaInsets.bottom)
                    .opacity(vm.audioBarVisible ? 1 : 0)
                    .animation(.easeInOut(duration: vm.audioBarVisible ? 0.45 : 0.30), value: vm.audioBarVisible)
                    .allowsHitTesting(vm.audioBarVisible)
                    .accessibilityHidden(!vm.audioBarVisible)
                }
                //endregion
                
                //region Scroll Up Button
                if (mvm.lessonSelected.StageID != 7 && showScrollUp) {
                    
                    var scrollUpPosition: CGFloat {
                        if isPagedReading { return -bookBottomControlSpacing }
                        
                        if (vm.audioBarVisible) {
                            return -70
                        }
                    
                        return -10
                    }
                    
                    VStack(spacing: 0)
                    {
                        Spacer()
                        
                        HStack(spacing: 0) {
                            
                            Spacer()
                            
                            Button(action: {
                                AppHaptics.tap()
                                
                                if isPagedReading {
                                    bookScrollRequest = RecitationBookScrollRequest(page: bookPageID, verseID: nil, showsHeader: true,
                                        selectionRevision: vm.verseTapScrollRequest?.revision,
                                        loadRevision: vm.surahLoadRevision)
                                    bookHeaderScrollRequest = UUID()
                                } else {
                                    vm.scrollTarget = "0"
                                }
                                
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
            .clipShape(PageBottomOverflowClip(), style: FillStyle(antialiased: false))
            .ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
            .onPreferenceChange(RecitationReadingVisibilityKey.self) { frames in
                rememberScrollingPosition(frames, geo: geo)
            }
            .onChange(of: vm.scrollTarget) { _, target in
                rememberReadingTarget(target)
            }
            .onChange(of: RecitationReadingPageState(page: bookPageID,
                alignedPage: settledBookPageID, isScrolling: bookPagerIsScrolling,
                appliedRequest: appliedBookScrollRequest)) { _, _ in
                rememberBookPosition()
            }
            .onChange(of: bookPageID) { _, _ in
                bookPageChanged()
            }
            .onChange(of: settledBookPageID) { _, _ in
                updateBookPagerHeight()
            }
            .onChange(of: vm.bookLayoutRevision) { _, revision in
                resetBookPagerLayout(for: revision)
            }
            .onChange(of: mvm.recitationItems.map(\.id)) { _, ids in
                // Legacy/memorization loaders can still temporarily empty data.
                // Native page commits retain metrics; explicit loads reset them above.
                if ids.isEmpty {
                    bookPageHeights = [:]
                    bookPagerHeight = nil
                    bookPagerAlignedPage = nil
                    bookPagerNativeSettledPage = nil
                    bookPagerIsScrolling = false
                    appliedBookScrollRequest = nil
                }
                if isPagedReading {
                    prepareBookPages()
                    // A settled swipe adopts its prepared Surah without re-aligning
                    // or clearing the pager. Dropdown/audio loads still route normally.
                    if vm.scrollTarget != "-1" || bookPageID.surah != mvm.recitationItems.first?.Surah {
                        showScrollUp = false
                        alignBookPage()
                    }
                }
            }
            .onAppear() {
                refreshReaderSafeArea()
                // Bind controls and completion callbacks to this reader's player
                // on every appearance, independently of the data-load flag.
                audioHelper = AudioHelper(player: $player)
                player.onNavigationBack = { [weak reader = vm, weak readerPlayer = player] in
                    guard let reader, let readerPlayer else { return }
                    reader.stopAudio(player: readerPlayer, hide: true)
                    reader.verseTapScrollRequest = nil
                    reader.scrollTarget = "-1"
                }
                
                if (!mvm.recitationInitialLoad) {
                    
                    mvm.recitationInitialLoad = true
                    vm.initiate(mvm: mvm)
                    
                    vm.bookmarked = getBookmark(mvm: mvm)
                    
                    if (mvm.lessonSelected.StageID == 7) {
                        
                        vm.audioBarVisible = true
                    }
                    
                    audioHelper.prepareRecitationDir()
                    
                    if (mvm.lessonSelected.StageID == 7) {
                        vm.initialLoad = true
                        loadMemorizingRecitation(vm: vm, mvm: mvm, audioHelper: audioHelper)
                    }
                }
                if isPagedReading { prepareBookPages() }
                restoreReadingPreferences()
            }
            .onDisappear {
                vm.readingPositionActive = false
                vm.readingPositionRestoration = UUID()
            }
            .onRotate { orientation in
                // Face-up/unknown notifications during locking are not UI rotations.
                guard orientation.isValidInterfaceOrientation else { return }
                safeAreaRefreshRequest = UUID()
            }
            .task(id: RecitationSafeAreaRefreshRequest(phase: scenePhase,
                revision: safeAreaRefreshRequest)) {
                guard scenePhase == .active else { return }
                refreshReaderSafeArea()
                // Recheck after window restoration. Locking again cancels this task.
                for _ in 0..<5 {
                    do { try await Task.sleep(nanoseconds: 100_000_000) }
                    catch { return }
                    guard !Task.isCancelled, scenePhase == .active else { return }
                    refreshReaderSafeArea()
                }
            }
        }
    }

    private func refreshReaderSafeArea() {
        guard scenePhase == .active,
              let window = UIApplication.shared.firstKeyWindow,
              window.windowScene?.activationState == .foregroundActive,
              !window.isHidden, window.bounds.width > 0, window.bounds.height > 0 else { return }
        let insets = window.safeAreaInsets
        guard [insets.top, insets.left, insets.bottom, insets.right]
            .allSatisfy({ $0.isFinite && $0 >= 0 }) else { return }
        // Keep valid margins through portrait window restoration. Zero insets
        // are still allowed for a fullscreen landscape window without a status bar.
        if insets == .zero {
            guard window.bounds.width > window.bounds.height,
                  window.windowScene?.statusBarManager?.isStatusBarHidden == true else { return }
        }
        if let previous = safeArea, previous == insets { return }
        safeArea = insets
    }

    private func toggleAudioPlayback() {
        guard vm.audioBarStatus != "loading" else { return }
        if vm.audioBarStatus == "stop" {
            audioHelper.pauseVerse()
            vm.audioBarStatus = "play"
            return
        }
        if mvm.lessonSelected.StageID == 7, vm.selectedItem == 0,
           let first = mvm.recitationItems.first {
            vm.selectedItem = first.id
            vm.scrollTarget = first.id.description
            vm.audioNeedsStart = true
        }
        if vm.audioNeedsStart {
            let selectedID: Int? = vm.selectedWord.isEmpty ? vm.selectedItem : vm.selectedWordVerseID
            guard let selectedID, mvm.recitationItems.contains(where: { $0.id == selectedID }) else { return }
            // Mount the selected row if it has scrolled out of the lazy page stack.
            vm.scrollTarget = selectedID.description
            vm.requestSelectedAudio()
        } else {
            audioHelper.startVerse()
            vm.audioBarStatus = "stop"
        }
    }

    private func recitationHeader(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {

            Spacer().frame(height: 10)

            Text(mvm.listSelected.Title.replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: ""))
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

            // The color key belongs to Tajweed readers, not a particular verse/page.
            if mvm.lessonSelected.requiresTajweedColors {
                RecitationTajweedLegend()
                    .background {
                        if isPagedReading {
                            // Preserve the surface previously inherited from the Quran page.
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(uiColor: .systemBackground).opacity(0.85))
                        }
                    }
            }

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
    }

    private func scrollingReader(geo: GeometryProxy) -> some View {
        ScrollViewReader { scrollView in

            ScrollView {

                recitationHeader(geo: geo)

                ZStack {

                    if (mvm.recitationItems.isEmpty) {

                        ProgressView()
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 1000), alignment: .leading)], spacing: 0) {

                        ForEach(mvm.recitationItems) { item in

                            RecitationItem(item: .constant(item), vm: .constant(vm), player: $player, audioHelper: $audioHelper,
                                readingModeControl: supportsReadingModes && item.id == mvm.recitationItems.first?.id
                                    ? AnyView(readingModeControl) : nil)
                                .background {
                                    if supportsSavedReadingPosition && !item.basmalah {
                                        GeometryReader { row in
                                            Color.clear.preference(key: RecitationReadingVisibilityKey.self,
                                                value: [item.id: row.frame(in: .global)])
                                        }
                                    }
                                }
                        }
                    }
                }
                .modifier(RecitationVerseTapScrolling(vm: vm, scrollView: scrollView))

                //region Memorizing Footer
                if (!mvm.recitationItems.isEmpty && mvm.lessonSelected.StageID == 7) {

                    let completed = mvm.recitationItems.allSatisfy { $0.memorized == true }

                    HStack
                    {
                        let completedColor = (completed) ? colorResource.danger : colorResource.orange
                        let completedText = (completed) ? mvm.home.Incomplete : mvm.home.Completed
                        let completedIcon = (completed) ? "icloud.and.arrow.down.fill" : "icloud.and.arrow.up.fill"

                        Button(action: {
                            AppHaptics.tap()

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

                        Button(action: { AppHaptics.tap(); mvm.selectedTab = Tab.account }) {

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
                    if let automatic = vm.pendingAutomaticVerseScroll,
                       automatic.verse.verseID.description == vm.scrollTarget,
                       automatic.verse.surah == mvm.recitationItems.first?.Surah {
                        vm.pendingAutomaticVerseScroll = nil
                        if vm.audioBarVisible && vm.selectedItem == automatic.verse.verseID {
                            vm.verseTapScrollRequest = automatic
                        }
                        vm.scrollTarget = "-1"
                        return
                    }
                    vm.pendingAutomaticVerseScroll = nil

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
    }

    private var supportsSavedReadingPosition: Bool {
        [2, 3, 5].contains(mvm.lessonSelected.StageID)
    }

    // These additional readers restore the selected page without hiding their controls.
    private var restoresPositionWithoutScrolling: Bool {
        supportsReadingModes && mvm.lessonSelected.StageID != 2
    }

    private func restoreReadingPreferences() {
        guard supportsSavedReadingPosition else { return }
        vm.readingPositionActive = true
        vm.readingPositionLoading = false
        vm.pendingReadingVerseID = nil
        let restoration = UUID()
        vm.readingPositionRestoration = restoration

        if supportsReadingModes {
            readingMode = RecitationReaderPreferences.readingMode
        }

        // Returning to ongoing audio keeps its current Surah and page.
        guard !vm.audioBarVisible || vm.audioBarStatus == "play" else {
            if isPagedReading { alignBookPage() }
            return
        }
        guard let saved = RecitationReaderPreferences.position,
              let target = saved.firstVerse(in: mvm.verseByVerse),
              let surah = vm.surah.items.first(where: { $0.split(separator: " ").first?.description == target.Surah }) else {
            if isPagedReading { alignBookPage(scrollVertically: !restoresPositionWithoutScrolling) }
            return
        }

        vm.pendingReadingVerseID = target.id
        if saved.firstVerse(in: mvm.recitationItems) != nil {
            applySavedReadingPosition(saved)
        } else {
            vm.readingPositionLoading = true
            vm.surah.selected = surah
            vm.surah.title = surah
            loadSurah(vm: vm, mvm: mvm, surah: target.Surah, trigger: "Surah", audioHelper: audioHelper) {
                guard vm.readingPositionActive, vm.readingPositionRestoration == restoration else { return }
                vm.readingPositionLoading = false
                applySavedReadingPosition(saved)
            }
        }
    }

    private func applySavedReadingPosition(_ saved: RecitationReadingPosition) {
        guard let verse = saved.firstVerse(in: mvm.recitationItems) else {
            vm.pendingReadingVerseID = nil
            return
        }
        if let surah = vm.surah.items.first(where: { $0.split(separator: " ").first?.description == verse.Surah }) {
            vm.surah.selected = surah
            vm.surah.title = surah
        }
        vm.ayah.title = "\(vm.ayahText) \(verse.Ayah)"
        vm.ayah.selected = vm.ayah.title
        vm.page.title = "\(mvm.home.Page) \(verse.Page)"
        vm.page.selected = vm.page.title
        vm.juzu.title = "\(vm.juzuText) \(verse.Juzu)"
        vm.juzu.selected = vm.juzu.title
        if restoresPositionWithoutScrolling {
            // Keep the restored Surah/page and dropdowns, leaving the vertical offset alone.
            vm.scrollTarget = "-1"
            if isPagedReading { alignBookPage(scrollVertically: false) }
        } else {
            // Preserve the existing Recitation/center-reader restoration route.
            vm.scrollTarget = verse.id.description
        }
    }

    private func rememberReadingTarget(_ target: String) {
        guard supportsSavedReadingPosition, vm.readingPositionActive,
              !vm.readingPositionLoading, target != "-1" else { return }
        // Keep the saved page protected until the restored target actually appears.
        if target == vm.pendingReadingVerseID?.description { return }
        let verse = target == "0"
            ? mvm.recitationItems.first(where: { !$0.basmalah })
            : mvm.recitationItems.first(where: { $0.id == Int(target) })
        guard let verse else { return }
        vm.pendingReadingVerseID = nil
        RecitationReaderPreferences.remember(verse)
    }

    private func rememberScrollingPosition(_ frames: [Int: CGRect], geo: GeometryProxy) {
        guard supportsSavedReadingPosition, !isPagedReading,
              vm.readingPositionActive, !vm.readingPositionLoading else { return }
        let viewport = geo.frame(in: .global)
        let top = viewport.minY + (safeArea?.top ?? 0) + 1
        let visible = frames.filter { $0.value.maxY > top && $0.value.minY < viewport.maxY }
        if let pending = vm.pendingReadingVerseID {
            guard visible[pending] != nil else { return }
            vm.pendingReadingVerseID = nil
        }
        guard let first = visible.min(by: { $0.value.minY < $1.value.minY }),
              let verse = mvm.recitationItems.first(where: { $0.id == first.key }) else { return }
        RecitationReaderPreferences.remember(verse)
    }

    private func rememberBookPosition() {
        guard supportsSavedReadingPosition, isPagedReading, vm.readingPositionActive,
              !vm.readingPositionLoading, !bookPagerIsScrolling,
              settledBookPageID == bookPageID,
              bookPageID.surah == mvm.recitationItems.first?.Surah,
              let page = bookPages.first(where: { $0.id == bookPageID }),
              let verse = page.items.first(where: { !$0.basmalah }) else { return }
        if let pending = vm.pendingReadingVerseID {
            guard page.items.contains(where: { $0.id == pending }),
                  let request = bookScrollRequest,
                  appliedBookScrollRequest == request.revision else { return }
            vm.pendingReadingVerseID = nil
        }
        RecitationReaderPreferences.remember(verse)
    }

    private var supportsReadingModes: Bool {
        mvm.lessonSelected.supportsRecitationReadingControls
    }

    // Paging footer and floating Up button share the same bottom clearance.
    private var bookBottomControlSpacing: CGFloat {
        vm.audioBarVisible ? 70 : 20
    }

    private var isPagedReading: Bool {
        supportsReadingModes && readingMode == .paging
    }

    private func prepareBookPages() {
        guard supportsReadingModes, bookPages.isEmpty, !mvm.verseByVerse.isEmpty else { return }
        let bySurah = Dictionary(grouping: mvm.verseByVerse, by: \.Surah)
        var pages: [RecitationBookPage] = []
        for number in 1...114 {
            let surah = number.description
            var items = (bySurah[surah] ?? []).sorted { (Int($0.Ayah) ?? 0) < (Int($1.Ayah) ?? 0) }
            guard let first = items.first else { continue }
            if mvm.recitationItems.first?.Surah == surah {
                // Retain the existing active models, including their basmalah.
                items = mvm.recitationItems
            } else if basmalah(surah: surah, mvm: mvm),
                      let source = bySurah["1"]?.first(where: { $0.Ayah == "1" }) {
                let introduction = source.copy()
                introduction.Surah = first.Surah
                introduction.SurahName = first.SurahName
                introduction.SurahNameAr = first.SurahNameAr
                introduction.SurahNameTr = first.SurahNameTr
                introduction.Ayah = "0"
                introduction.Page = first.Page
                introduction.Juzu = first.Juzu
                introduction.basmalah = true
                items.insert(introduction, at: 0)
            }
            pages.append(contentsOf: RecitationBookPage.group(items))
        }
        // Keep identities and ordering stable across Surah changes. Only page data
        // is indexed here; the native lazy pager renders the visible neighborhood.
        bookPages = pages
    }

    private func activateBookSurah(_ page: RecitationBookPage) {
        guard mvm.recitationItems.first?.Surah != page.surah,
              let name = vm.surah.items.first(where: { $0.split(separator: " ").first?.description == page.surah }) else { return }
        vm.stopAudio(player: player, hide: true)
        vm.selectedItem = 0
        vm.selectedWord = ""
        vm.selectedWordVerseID = nil
        vm.pendingReadingVerseID = nil
        vm.surah.selected = name
        vm.surah.title = name
        let count = page.surahItems.filter { !$0.basmalah }.count
        vm.ayah.items = (1...max(1, count)).map { "\(vm.ayahText) \($0)" }
        // One nonempty assignment: no loader, delay, spinner or pager replacement.
        mvm.recitationItems = page.surahItems
    }

    private func commitBookPageSelection() {
        guard isPagedReading, vm.readingPositionActive, !vm.readingPositionLoading,
              !bookPagerIsScrolling, settledBookPageID == bookPageID,
              let page = bookPages.first(where: { $0.id == bookPageID }) else { return }
        activateBookSurah(page)
        if committedBookPageID != page.id || bookScrollRequest?.verseID != nil {
            updateBookDropdowns(page: page, verseID: bookScrollRequest?.verseID)
            committedBookPageID = page.id
        }
    }

    private var readingModeControl: some View {
        HStack(spacing: 8) {
            RecitationAutoplayButton(enabled: $verseAutoplay, isArabic: currentLanguage == "Ar")
            RecitationTajweedButton(enabled: $tajweedColors, isArabic: currentLanguage == "Ar",
                isLocked: mvm.lessonSelected.requiresTajweedColors)
            RecitationReadingModeSwitch(selection: Binding(
                get: { readingMode },
                set: { mode in
                    guard mode != readingMode else { return }
                    readingMode = mode
                    RecitationReaderPreferences.readingMode = mode
                    // Resolve the selected page before the page controller mounts.
                    readingModeChanged()
                }
            ), isArabic: currentLanguage == "Ar")
            .frame(width: 132)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func pagedReader(geo: GeometryProxy) -> some View {
        let layoutRevision = vm.bookLayoutRevision
        let pageSlotHeight = max(1, bookPagerHeight ?? geo.size.height)
        return ScrollViewReader { scrollView in
            ScrollView {
                VStack(spacing: 0) {
                    recitationHeader(geo: geo)

                    if let first = mvm.recitationItems.first {
                        RecitationBookmarkRow(item: .constant(first), vm: .constant(vm),
                            audioHelper: $audioHelper, readingModeControl: AnyView(readingModeControl))
                            .padding(.top, 8)
                    }

                    if bookPages.isEmpty || mvm.recitationItems.isEmpty {
                        ProgressView()
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(alignment: .top, spacing: 0) {
                                ForEach(bookPages) { page in
                                    RecitationBookPageView(page: page, layoutRevision: layoutRevision,
                                        vm: vm, player: $player,
                                        audioHelper: $audioHelper, footer: bookPageNavigation(for: page),
                                        onMetricsChange: { pageID, metrics in
                                            receiveBookPageMetrics(page: pageID, metrics: metrics)
                                        })
                                        // Give every lazy page the same vertical bounds as the viewport.
                                        // Its inner background still measures the complete intrinsic page.
                                        .frame(height: pageSlotHeight, alignment: .top)
                                        // Keep verse/translation content in the app's UI direction.
                                        .environment(\.layoutDirection, readerLayoutDirection)
                                        .containerRelativeFrame(.horizontal)
                                        .id(page.id)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .id(layoutRevision)
                        .scrollIndicators(.hidden)
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: Binding<RecitationBookPageID?>(
                            get: { bookPageID.number > 0 ? bookPageID : nil },
                            set: { target in
                                guard layoutRevision == vm.bookLayoutRevision,
                                      let target, target != bookPageID else { return }
                                bookPageID = target
                            }
                        ), anchor: .leading)
                        .coordinateSpace(name: "RecitationBookPager")
                        .modifier(RecitationBookPagingActivity(isScrolling: $bookPagerIsScrolling,
                            selectedPage: $bookPageID, settledPage: $bookPagerNativeSettledPage,
                            revision: layoutRevision, currentRevision: $vm.bookLayoutRevision))
                        .frame(height: pageSlotHeight)
                        .onChange(of: bookPagerIsScrolling) { _, scrolling in
                            if !scrolling { updateBookPagerHeight() }
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        // This target belongs to the OUTER vertical scroll view.
                        // Nested verse IDs can instead resolve in the horizontal pager.
                        .id(RecitationBookVerticalAnchor.pageStart)
                    }
                }
                // Keep floating-player clearance outside the measured horizontal pages.
                // Player visibility must not depend on a cached/settled pager height.
                .padding(.bottom, geo.safeAreaInsets.bottom + bookBottomControlSpacing)
                .modifier(RecitationVerseTapScrolling(vm: vm, scrollView: scrollView))
            }
            .padding(.top, (safeArea?.top ?? 0) + 1)
            .padding(.leading, safeArea?.left)
            .padding(.trailing, safeArea?.right)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // The shared vertical viewport still extends behind the floating tab bar.
            .ignoresSafeArea(.container, edges: .bottom)
            .task(id: vm.scrollTarget) {
                routeBookScrollTarget()
            }
            .onChange(of: bookHeaderScrollRequest) { _, _ in
                // Explicit up taps never depend on cached horizontal alignment.
                withAnimation(.easeInOut(duration: 0.24)) {
                    scrollView.scrollTo("Header", anchor: .top)
                }
            }
            .task(id: readyBookScrollLayoutRequest) {
                guard !Task.isCancelled, let layout = readyBookScrollLayoutRequest,
                      layout.layoutRevision == layoutRevision,
                      layout.request.loadRevision == vm.surahLoadRevision,
                      layout.request.selectionRevision == vm.verseTapScrollRequest?.revision,
                      appliedBookScrollRequest != layout.request.revision else { return }
                let request = layout.request
                // Commit only after a completed native swipe, never while a finger
                // is between Surahs. The selected page view and its data stay in place.
                commitBookPageSelection()
                // Scroll vertically only after the horizontal page has settled and laid out.
                await Task.yield()
                guard !Task.isCancelled, layoutRevision == vm.bookLayoutRevision,
                      bookScrollRequest?.revision == request.revision,
                      request.page == bookPageID,
                      request.loadRevision == vm.surahLoadRevision,
                      request.selectionRevision == vm.verseTapScrollRequest?.revision else { return }
                if let automatic = request.automaticVerseScroll {
                    guard bookScrollRequest?.revision == request.revision,
                          settledBookPageID == request.page,
                          vm.pendingAutomaticVerseScroll?.revision == automatic.revision,
                          vm.audioBarVisible, vm.selectedItem == automatic.verse.verseID else { return }
                    if request.scrollVertically {
                        // Reuse the tap's outer vertical anchor after the page settles.
                        vm.verseTapScrollRequest = automatic
                    }
                    vm.pendingAutomaticVerseScroll = nil
                } else if request.scrollVertically {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        if let target = request.verseID {
                            scrollView.scrollTo(RecitationBookVerseScrollID(surah: request.page.surah,
                                verseID: target), anchor: .top)
                        } else if request.showsHeader {
                            scrollView.scrollTo("Header", anchor: .top)
                        } else {
                            scrollView.scrollTo(RecitationBookVerticalAnchor.pageStart, anchor: .top)
                        }
                    }
                }
                appliedBookScrollRequest = request.revision
            }
        }
    }

    private func receiveBookPageMetrics(page: RecitationBookPageID, metrics: RecitationBookPageMetrics) {
        guard metrics.layoutRevision == vm.bookLayoutRevision,
              metrics.height.isFinite, metrics.height > 0 else { return }
        resetBookPagerLayout(for: metrics.layoutRevision)
        if bookPageHeights[page] != metrics.height { bookPageHeights[page] = metrics.height }
        if metrics.isAligned {
            if bookPagerAlignedPage != page { bookPagerAlignedPage = page }
        } else if bookPagerAlignedPage == page {
            // An old page losing alignment must not clear a newly aligned page.
            bookPagerAlignedPage = nil
        }
        updateBookPagerHeight()
    }

    private var readyBookScrollLayoutRequest: RecitationBookScrollLayoutRequest? {
        guard isPagedReading, bookPagerLayoutRevision == vm.bookLayoutRevision,
              !bookPagerIsScrolling, !vm.readingPositionLoading,
              let request = bookScrollRequest, request.page == bookPageID,
              settledBookPageID == request.page,
              let height = bookPageHeights[request.page], bookPagerHeight == height else { return nil }
        // Only the request and readiness drive task identity, not each geometry sample.
        // Completion/selection mutations stay out of the key so the task cannot restart itself.
        return RecitationBookScrollLayoutRequest(layoutRevision: vm.bookLayoutRevision, request: request)
    }

    private var settledBookPageID: RecitationBookPageID? {
        guard !bookPagerIsScrolling else { return nil }
        if bookPagerNativeSettledPage == bookPageID || bookPagerAlignedPage == bookPageID {
            return bookPageID
        }
        return nil
    }

    private func resetBookPagerLayout(for revision: UUID) {
        guard bookPagerLayoutRevision != revision else { return }
        bookPagerLayoutRevision = revision
        bookPageHeights = [:]
        bookPagerHeight = nil
        bookPagerAlignedPage = nil
        bookPagerNativeSettledPage = nil
        bookPagerIsScrolling = false
        appliedBookScrollRequest = nil
    }

    private func updateBookPagerHeight() {
        // A newly mounted pager may already be idle, with no phase-change event.
        // Apply its first measured target height without waiting for a settled callback.
        // Later page changes keep the existing settle-before-resize rule.
        guard bookPagerLayoutRevision == vm.bookLayoutRevision, !bookPagerIsScrolling,
              bookPagerHeight == nil || settledBookPageID == bookPageID,
              let height = bookPageHeights[bookPageID], height.isFinite, height > 0,
              bookPagerHeight != height else { return }
        // Never resize the horizontal viewport while a finger or deceleration is moving it.
        // Disable inherited button animations for this separate layout update.
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) { bookPagerHeight = height }
    }

    private func bookPageNavigation(for page: RecitationBookPage) -> some View {
        let pages = bookPages
        let index = pages.firstIndex(where: { $0.id == page.id })
        let previousPage = index.flatMap { $0 > 0 ? pages[$0 - 1] : nil }
        let nextPage = index.flatMap { $0 + 1 < pages.count ? pages[$0 + 1] : nil }
        let available = !vm.readingPositionLoading
        let canGoBack = available && previousPage != nil
        let canGoForward = available && nextPage != nil

        return HStack(spacing: 16) {
            bookPageButton(icon: "chevron.right", pageNumber: previousPage?.number,
                label: currentLanguage == "Ar" ? "الصفحة السابقة" : "Previous page",
                enabled: canGoBack) {
                moveBookPage(from: page.id, by: -1)
            }
            bookPageButton(icon: "chevron.left", pageNumber: nextPage?.number,
                label: currentLanguage == "Ar" ? "الصفحة التالية" : "Next page",
                enabled: canGoForward) {
                moveBookPage(from: page.id, by: 1)
            }
        }
        .frame(maxWidth: .infinity)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func bookPageButton(icon: String, pageNumber: Int?, label: String, enabled: Bool,
                                action: @escaping () -> Void) -> some View {
        Button {
            AppHaptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if icon == "chevron.left" {
                    Image(systemName: icon)
                }
                if let pageNumber {
                    Text("\(mvm.home.Page) \(pageNumber)")
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .environment(\.layoutDirection, readerLayoutDirection)
                }
                if icon == "chevron.right" {
                    Image(systemName: icon)
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .font(.system(size: 20, weight: .semibold))
            .padding(.horizontal, 14)
            .frame(minWidth: 48)
            .frame(height: 48)
            .foregroundStyle(Color.white)
            .background(colorResource.maroon, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .accessibilityLabel(Text(pageNumber.map { "\(label), \(mvm.home.Page) \($0)" } ?? label))
    }

    private func moveBookPage(from pageID: RecitationBookPageID, by offset: Int) {
        guard isPagedReading, !vm.readingPositionLoading, pageID == bookPageID,
              let index = bookPages.firstIndex(where: { $0.id == pageID }),
              bookPages.indices.contains(index + offset) else { return }
        let target = bookPages[index + offset]
        bookScrollRequest = RecitationBookScrollRequest(page: target.id, verseID: nil,
            selectionRevision: vm.verseTapScrollRequest?.revision, loadRevision: vm.surahLoadRevision)
        withAnimation(.easeInOut(duration: 0.25)) {
            bookPageID = target.id
        }
    }

    private func readingModeChanged() {
        guard supportsReadingModes else { return }
        if isPagedReading {
            vm.bookLayoutRevision = UUID()
            prepareBookPages()
            alignBookPage(scrollVertically: false)
        } else if let page = bookPages.first(where: { $0.id == bookPageID }),
                  let target = page.items.first(where: { $0.id == bookScrollRequest?.verseID })
                    ?? page.items.first(where: { !$0.basmalah }) {
            // Complete a settled page selection if the mode changed before its task ran.
            if !bookPagerIsScrolling && settledBookPageID == page.id {
                activateBookSurah(page)
            }
            if target.Surah == mvm.recitationItems.first?.Surah {
                // Changing display style alone must not jump away from the header.
                vm.scrollTarget = "-1"
            }
        }
    }

    private func alignBookPage(scrollVertically: Bool = true) {
        guard isPagedReading, !bookPages.isEmpty,
              let surah = mvm.recitationItems.first?.Surah else { return }
        if vm.scrollTarget != "-1" {
            routeBookScrollTarget(scrollVertically: scrollVertically)
            return
        }

        let playingVerse = vm.audioBarStatus != "play"
            ? mvm.recitationItems.first(where: { $0.id == vm.selectedItem }) : nil
        let requestedNumber = playingVerse.flatMap { Int($0.Page) }
            ?? vm.page.selected.split(separator: " ").last.flatMap { Int($0) }
        let pages = bookPages.filter { $0.surah == surah }
        guard let page = pages.first(where: { $0.number == requestedNumber }) ?? pages.first else { return }
        bookPageID = page.id
        bookScrollRequest = RecitationBookScrollRequest(page: page.id, verseID: playingVerse?.id,
            scrollVertically: scrollVertically,
            selectionRevision: vm.verseTapScrollRequest?.revision, loadRevision: vm.surahLoadRevision)
        updateBookDropdowns(page: page, verseID: playingVerse?.id)
    }

    private func routeBookScrollTarget(scrollVertically: Bool = true) {
        guard isPagedReading, vm.scrollTarget != "-1", !bookPages.isEmpty,
              let surah = mvm.recitationItems.first?.Surah else { return }
        let verse = Int(vm.scrollTarget).flatMap { id in
            mvm.recitationItems.first(where: { $0.id == id })
        }
        let pages = bookPages.filter { $0.surah == surah }
        let targetPage = vm.scrollTarget == "0" ? pages.first?.number : verse.flatMap { Int($0.Page) }
        guard let page = pages.first(where: { $0.number == targetPage }) else {
            vm.scrollTarget = "-1"
            return
        }

        let automatic = vm.pendingAutomaticVerseScroll.flatMap { request in
            verse.map { RecitationVerseTapScrollID(surah: $0.Surah, verseID: $0.id) } == request.verse
                ? request : nil
        }
        if automatic == nil { vm.pendingAutomaticVerseScroll = nil }
        let followsCurrentPage = scrollVertically && automatic != nil
            && bookPageID == page.id
        bookPageID = page.id
        bookScrollRequest = RecitationBookScrollRequest(page: page.id, verseID: verse?.id,
            showsHeader: vm.scrollTarget == "0", scrollVertically: scrollVertically,
            automaticVerseScroll: automatic,
            selectionRevision: vm.verseTapScrollRequest?.revision, loadRevision: vm.surahLoadRevision)
        updateBookDropdowns(page: page, verseID: verse?.id)
        if followsCurrentPage, let automatic, vm.audioBarVisible,
           vm.selectedItem == automatic.verse.verseID {
            // This page is already selected: use the tap anchor without waiting
            // for a horizontal settling event that may never occur.
            appliedBookScrollRequest = bookScrollRequest?.revision
            vm.pendingAutomaticVerseScroll = nil
            vm.verseTapScrollRequest = automatic
        }
        vm.scrollTarget = "-1"
    }

    private func bookPageChanged() {
        guard isPagedReading, vm.scrollTarget == "-1",
              let page = bookPages.first(where: { $0.id == bookPageID }) else { return }
        if bookScrollRequest?.page != page.id {
            // Native swipes and arrows share the settled maroon-bar reset.
            bookScrollRequest = RecitationBookScrollRequest(page: page.id, verseID: nil,
                selectionRevision: vm.verseTapScrollRequest?.revision, loadRevision: vm.surahLoadRevision)
        }
    }

    private func updateBookDropdowns(page: RecitationBookPage, verseID: Int?) {
        guard let verse = page.items.first(where: { $0.id == verseID && !$0.basmalah })
                ?? page.items.first(where: { !$0.basmalah }) else { return }
        // RecDropDown's string properties aren't published themselves.
        vm.objectWillChange.send()
        vm.page.title = "\(mvm.home.Page) \(page.number)"
        vm.page.selected = vm.page.title
        vm.ayah.title = "\(vm.ayahText) \(verse.Ayah)"
        vm.ayah.selected = vm.ayah.title
        vm.juzu.title = "\(vm.juzuText) \(verse.Juzu)"
        vm.juzu.selected = vm.juzu.title
    }

}

@MainActor
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
