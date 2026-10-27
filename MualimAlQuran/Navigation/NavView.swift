import SwiftUI
import UIKit

// Shared with the preserved navigation and MainViewModel.
enum Tab: String, CaseIterable {
    // Keep the legacy share case for the preserved navigation files;
    // its center slot is now the dedicated Quran reader in NavView.
    case home, account, share, lang, more

    var text: String {
        switch self {
        case .home: return "Home"
        case .account: return "Account"
        case .share: return "Qur’an"
        case .lang: return "Language"
        case .more: return "More"
        }
    }

}

// Route identities describe screens; mutable lesson/reader data stays in its
// existing view models. Each tab retains its own independent history.
enum AccountPage: Hashable {
    case forgot, create, google, apple
}

enum AppRoute: Hashable {
    case stage(Int)
    case tajweedRules
    case lesson(Int)
    case recitation(stageID: Int)
    case ql, qlVocabulary, qlExamples
    case tajweed, tajweedExamples
    case infoPage(String), downloads, language, share
    case account(AccountPage)
}

@MainActor
final class AppNavigationRouter: ObservableObject {
    @Published private(set) var paths: [Tab: [AppRoute]] = [:]
    var didRemoveRoutes: ((Tab, [AppRoute]) -> Void)?

    func path(for tab: Tab) -> [AppRoute] { paths[tab] ?? [] }

    func canGoBack(in tab: Tab) -> Bool { !path(for: tab).isEmpty }

    func binding(for tab: Tab) -> Binding<[AppRoute]> {
        Binding(get: { self.path(for: tab) }, set: { self.setPath($0, in: tab) })
    }

    func push(_ route: AppRoute, in tab: Tab) {
        var next = path(for: tab)
        guard next.last != route else { return }
        next.append(route)
        setPath(next, in: tab)
    }

    @discardableResult
    func goBack(in tab: Tab) -> Bool {
        var next = path(for: tab)
        guard !next.isEmpty else { return false }
        next.removeLast()
        setPath(next, in: tab)
        return true
    }

    func returnToRoot(in tab: Tab) { setPath([], in: tab) }

    func showAccountPage(_ page: AccountPage) {
        // These forms replace the inline login content; they cannot nest.
        setPath([.account(page)], in: .account)
    }

    func resetAll() {
        // One audio cancellation for the complete explicit reset.
        let removed = paths
        paths = [:]
        // A root Quran reader can be playing even when every path is empty.
        AppNavigationAudio.stopForBack()
        for (tab, routes) in removed where !routes.isEmpty {
            didRemoveRoutes?(tab, routes)
        }
    }

    func setPath(_ next: [AppRoute], in tab: Tab) {
        let previous = path(for: tab)
        guard previous != next else { return }
        let sharedCount = zip(previous, next).prefix(while: { $0.0 == $0.1 }).count
        let removed = Array(previous.dropFirst(sharedCount))
        paths[tab] = next
        // Native Back/swipe writes this same binding. A programmatic pop has
        // already committed it, so a repeated native write cannot stop twice.
        if !removed.isEmpty {
            AppNavigationAudio.stopForBack()
            didRemoveRoutes?(tab, removed)
        }
    }
}

struct NavView: View {
    @EnvironmentObject var mvm: MainViewModel
    @StateObject private var navigation = AppNavigationRouter()
    @AppStorage("language") private var currentLanguage = getLanguage()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        // The system supplies the Liquid Glass pill on iOS 26+ when built
        // with the iOS 26 SDK or later, and a standard tab bar on older iOS.
        TabView(selection: $mvm.selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabStack(for: tab)
                .tag(tab)
                .tabItem {
                    icon(for: tab)
                        .accessibilityLabel(Text(showsBack(for: tab) ? backLabel : tab.text))
                }
            }
        }
        .environmentObject(navigation)
        .background(TabBarBackAction(isArabic: currentLanguage == "Ar", onReselect: goBackInSelectedTab))
        .tint(colorResource.primary_500)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            navigation.didRemoveRoutes = { [weak mvm, weak navigation] tab, removed in
                // Leaving memorization retains its original selection cleanup.
                // Switching tabs keeps the path and does not execute this.
                if tab == .home, removed.contains(.recitation(stageID: 7)),
                   navigation?.path(for: .home).contains(.recitation(stageID: 7)) != true {
                    mvm?.listSelected = ListModel()
                }
            }
        }
    }

    private func icon(for tab: Tab) -> Image {
        if showsBack(for: tab) {
            return Image(systemName: "chevron.backward").renderingMode(.template)
        }

        switch tab {
        case .home: return symbolIcon(named: "home", for: tab)
        case .account: return symbolIcon(named: "account", for: tab)
        case .share: return symbolIcon(named: "quran-tab", for: tab)
        case .lang: return Image(uiImage: languageIcon).renderingMode(.original)
        case .more: return symbolIcon(named: "menu", for: tab)
        }
    }

    private var backLabel: String {
        currentLanguage == "Ar" ? "رجوع" : "Back"
    }

    private func showsBack(for tab: Tab) -> Bool {
        mvm.selectedTab == tab && navigation.canGoBack(in: tab)
    }

    private func goBackInSelectedTab(nativeIndex: Int) -> Bool {
        // Reject callbacks for a tab whose programmatic selection is pending.
        guard Tab.allCases.indices.contains(nativeIndex),
              Tab.allCases[nativeIndex] == mvm.selectedTab else { return false }
        return navigation.goBack(in: mvm.selectedTab)
    }

    private func symbolIcon(named name: String, for tab: Tab) -> Image {
        let template = Image(name).renderingMode(.template)
        guard mvm.selectedTab != tab, let image = UIImage(named: name) else {
            return template
        }

        // NavViewOld used Color.secondary for inactive symbols. Render that
        // color into the image so the native bar preserves it instead of
        // applying its own inactive tint. Selected symbols keep the green tint.
        let traits = UITraitCollection.current.modifyingTraits {
            $0.userInterfaceStyle = colorScheme == .dark ? .dark : .light
        }
        let inactiveColor = UIColor(Color.secondary).resolvedColor(with: traits)
        return Image(uiImage: image.withTintColor(inactiveColor, renderingMode: .alwaysOriginal))
            .renderingMode(.original)
    }

    private var languageIcon: UIImage {
        guard let image = UIImage(named: currentLanguage.lowercased())?.withRenderingMode(.alwaysOriginal) else {
            return (UIImage(systemName: "globe") ?? UIImage()).withRenderingMode(.alwaysOriginal)
        }

        // Match NavViewOld: 40-point width, one-point selection border,
        // two-point flag corners and four-point outer corners.
        let padding: CGFloat = 1
        let scale = min(38 / image.size.width, 22 / image.size.height)
        let flagSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let size = CGSize(width: flagSize.width + padding * 2, height: flagSize.height + padding * 2)
        let borderColor = UIColor(Color(hex: mvm.selectedTab == .lang ? "#aab25b" : "#88888a"))

        return UIGraphicsImageRenderer(size: size).image { _ in
            let outerRect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: outerRect, cornerRadius: 4).addClip()
            borderColor.setFill()
            UIRectFill(outerRect)

            let flagRect = outerRect.insetBy(dx: padding, dy: padding)
            UIBezierPath(roundedRect: flagRect, cornerRadius: 2).addClip()
            image.draw(in: flagRect)
        }
        // Preserve the bitmap colors at the UIKit tab-item level as well
        // as the SwiftUI Image level, in both selected and inactive states.
        .withRenderingMode(.alwaysOriginal)
    }

    @ViewBuilder
    private func tabStack(for tab: Tab) -> some View {
        if tab == .account {
            // Login's forms/OAuth progress are inline, rather than pushed
            // screens. Their entries still use the router's single Back action.
            NavigationStack { tabRoot(for: tab) }
        } else {
            NavigationStack(path: navigation.binding(for: tab)) {
                tabRoot(for: tab)
                    .navigationDestination(for: AppRoute.self) { route in
                        routeDestination(route)
                    }
            }
        }
    }

    private func tabRoot(for tab: Tab) -> some View {
        ZStack {
            if tab != .lang && tab != .share { AppBG() }
            destination(for: tab)
        }
        .navigationBarHidden(true)
    }

    // Register once at each stack root, outside lazy grids and retained parents.
    @ViewBuilder
    private func routeDestination(_ route: AppRoute) -> some View {
        switch route {
        case .stage(let id):
            if let index = mvm.stages.firstIndex(where: { $0.id == id }) {
                StageView(stage: $mvm.stages[index])
            }
        case .tajweedRules:
            if let index = mvm.stageLessons.firstIndex(where: { $0.id == 51 }) {
                StageView1(stage: $mvm.stageLessons[index])
            }
        case .lesson(let id):
            if let index = mvm.stageLessons.firstIndex(where: { $0.id == id }) {
                LessonView(lesson: $mvm.stageLessons[index])
            }
        case .recitation: RecitationView()
        case .ql: QLView()
        case .qlVocabulary: QLVocView()
        case .qlExamples: QLExView()
        case .tajweed: TajweedView()
        case .tajweedExamples:
            TajweedExView()
                .environment(\.layoutDirection, getLanguage() == "Ar" ? .rightToLeft : .leftToRight)
        case .infoPage: PageLayout()
        case .downloads: DownloadLayout()
        case .language: LanguageLayout()
        case .share: ShareView()
        case .account: EmptyView() // Rendered inline by LoginLayout.
        }
    }

    @ViewBuilder
    private func destination(for tab: Tab) -> some View {
        switch tab {
        case .home: HomeView()
        case .account: AccountView()
        case .share: QuranShortcutView().id(currentLanguage)
        case .lang: LanguageLayout()
        case .more: MoreView()
        }
    }
}

// Own reader state keeps the Home tab's lesson, surah and back stack intact.
private struct QuranShortcutView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @StateObject private var reader = MainViewModel()
    @State private var isPrepared = false

    var body: some View {
        Group {
            if isPrepared {
                RecitationView()
                    .environmentObject(reader)
            } else {
                ProgressView()
            }
        }
        .task(id: mvm.loading) {
            guard !mvm.loading, !isPrepared,
                  let stage = mvm.stages.first(where: { $0.id == 2 }),
                  let lesson = mvm.lessons.first(where: { $0.StageID == 2 && $0.Number == 6 }) else { return }
            reader.home = mvm.home
            reader.listType = "recitation"
            reader.listSelected = stage.copy()
            reader.lessonSelected = lesson.copy()
            reader.surahNames = mvm.surahNames
            reader.surahNamesAr = mvm.surahNamesAr
            reader.verse1 = mvm.verse1.map { $0.copy() }
            reader.verseByVerse = mvm.verseByVerse.map { $0.copy() }
            reader.recitationItems = reader.verse1
            reader.loading = false
            reader.recitationInitialLoad = false
            isPrepared = true
        }
    }
}

// TabView's selection binding doesn't report taps on the already selected
// tab. Intercept that one interaction through the native controller, keeping
// SwiftUI's delegate in charge of all other tab events and transitions.
private struct TabBarBackAction: UIViewControllerRepresentable {
    var isArabic: Bool
    var onReselect: @MainActor (Int) -> Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isArabic: isArabic, onReselect: onReselect)
    }

    func makeUIViewController(context: Context) -> ObserverController {
        let controller = ObserverController()
        controller.onResolve = { [weak coordinator = context.coordinator] tabController in
            coordinator?.attach(to: tabController)
        }
        return controller
    }

    func updateUIViewController(_ controller: ObserverController, context: Context) {
        context.coordinator.isArabic = isArabic
        context.coordinator.onReselect = onReselect
        controller.resolveTabController()
    }

    static func dismantleUIViewController(_ controller: ObserverController, coordinator: Coordinator) {
        controller.onResolve = nil
        coordinator.detach()
    }

    final class ObserverController: UIViewController {
        var onResolve: (@MainActor (UITabBarController) -> Void)?

        override func loadView() {
            let background = UIView()
            background.backgroundColor = .clear
            background.isUserInteractionEnabled = false
            view = background
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            resolveTabController()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            resolveTabController()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            resolveTabController()
        }

        func resolveTabController() {
            // The background is hosted beside TabView. Search the nearest
            // containing controller using public containment APIs only.
            var ancestor = parent
            while let controller = ancestor {
                if let tabController = findTabController(in: controller) {
                    onResolve?(tabController)
                    return
                }
                ancestor = controller.parent
            }
        }

        private func findTabController(in controller: UIViewController) -> UITabBarController? {
            if let tabController = controller as? UITabBarController {
                return tabController
            }
            for child in controller.children {
                if let tabController = findTabController(in: child) {
                    return tabController
                }
            }
            return nil
        }
    }

    @MainActor
    final class Coordinator: NSObject, UITabBarControllerDelegate {
        var isArabic: Bool
        var onReselect: @MainActor (Int) -> Bool
        private weak var controller: UITabBarController?
        private var handledBackIndex: Int?
        private var navigationDirections: [NavigationDirectionState] = []
        // NSObject's selector queries are nonisolated; delegate changes and
        // action calls are confined to the main actor by this coordinator.
        nonisolated(unsafe) private var originalDelegate: UITabBarControllerDelegate?

        init(isArabic: Bool, onReselect: @escaping @MainActor (Int) -> Bool) {
            self.isArabic = isArabic
            self.onReselect = onReselect
            super.init()
        }

        func attach(to tabController: UITabBarController) {
            if controller !== tabController {
                detach()
                controller = tabController
            }
            if tabController.delegate !== self {
                originalDelegate = tabController.delegate
                tabController.delegate = self
            }
            // Reapply on language updates and when a lazy tab first lays out.
            updateNavigationDirection(in: tabController)
        }

        func detach() {
            restoreNavigationDirections()
            if let controller, controller.delegate === self {
                controller.delegate = originalDelegate
            }
            controller = nil
            originalDelegate = nil
        }

        private func updateNavigationDirection(in tabController: UITabBarController) {
            guard isArabic else {
                restoreNavigationDirections()
                return
            }
            navigationDirections.removeAll { $0.controller == nil }
            for navigationController in navigationControllers(in: tabController) where navigationController.isViewLoaded {
                let state: NavigationDirectionState
                if let existing = navigationDirections.first(where: { $0.controller === navigationController }) {
                    state = existing
                } else {
                    state = NavigationDirectionState(navigationController)
                    navigationDirections.append(state)
                }
                state.applyArabicDirection()
            }
        }

        private func restoreNavigationDirections() {
            navigationDirections.forEach { $0.restore() }
            navigationDirections.removeAll()
        }

        private func navigationControllers(in controller: UIViewController) -> [UINavigationController] {
            if let navigationController = controller as? UINavigationController {
                return [navigationController]
            }
            return controller.children.flatMap { navigationControllers(in: $0) }
        }

        // Scope RTL to the native navigation host. Keep UIKit's own animator,
        // SwiftUI's navigation delegate, paths and content layout untouched.
        @MainActor
        private final class NavigationDirectionState {
            weak var controller: UINavigationController?
            private let viewSemantic: UISemanticContentAttribute
            private let barSemantic: UISemanticContentAttribute
            private weak var popGesture: UIScreenEdgePanGestureRecognizer?
            private var popEdges: UIRectEdge?

            init(_ controller: UINavigationController) {
                self.controller = controller
                viewSemantic = controller.view.semanticContentAttribute
                barSemantic = controller.navigationBar.semanticContentAttribute
            }

            func applyArabicDirection() {
                guard let controller else { return }
                let gesture = controller.interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer
                if popGesture !== gesture {
                    restorePopEdge()
                    popGesture = gesture
                    popEdges = gesture?.edges
                }
                if controller.view.semanticContentAttribute != .forceRightToLeft {
                    controller.view.semanticContentAttribute = .forceRightToLeft
                }
                if controller.navigationBar.semanticContentAttribute != .forceRightToLeft {
                    controller.navigationBar.semanticContentAttribute = .forceRightToLeft
                }
                if let popGesture, popGesture.state != .began, popGesture.state != .changed,
                   popGesture.edges != .right {
                    popGesture.edges = .right
                }
            }

            func restore() {
                if let controller {
                    if controller.view.semanticContentAttribute == .forceRightToLeft {
                        controller.view.semanticContentAttribute = viewSemantic
                    }
                    if controller.navigationBar.semanticContentAttribute == .forceRightToLeft {
                        controller.navigationBar.semanticContentAttribute = barSemantic
                    }
                }
                restorePopEdge()
            }

            private func restorePopEdge() {
                if let popGesture, let popEdges, popGesture.edges == .right {
                    popGesture.edges = popEdges
                }
            }
        }

        private func handleBack(at index: Int) -> Bool {
            if handledBackIndex == index { return true }
            guard onReselect(index) else { return false }
            handledBackIndex = index
            DispatchQueue.main.async { [weak self] in self?.handledBackIndex = nil }
            return true
        }

        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            AppHaptics.tap()
            if tabBarController.selectedViewController === viewController, handleBack(at: tabBarController.selectedIndex) {
                // The router removed one entry; prevent UIKit reselection
                // from also applying its default pop-to-root behavior.
                return false
            }
            return originalDelegate?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
        }

        @available(iOS 18.0, *)
        func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
            AppHaptics.tap()
            if tabBarController.selectedTab === tab, handleBack(at: tabBarController.selectedIndex) {
                return false
            }
            return originalDelegate?.tabBarController?(tabBarController, shouldSelectTab: tab) ?? true
        }

        override func responds(to selector: Selector!) -> Bool {
            super.responds(to: selector) || originalDelegate?.responds(to: selector) == true
        }

        override func forwardingTarget(for selector: Selector!) -> Any? {
            if let originalDelegate, originalDelegate.responds(to: selector) {
                return originalDelegate
            }
            return super.forwardingTarget(for: selector)
        }
    }
}
