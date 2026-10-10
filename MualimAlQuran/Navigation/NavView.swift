import SwiftUI
import UIKit

// Shared with the preserved navigation and MainViewModel.
enum Tab: String, CaseIterable {
    case home, account, share, lang, more

    var text: String {
        switch self {
        case .home: return "Home"
        case .account: return "Account"
        case .share: return "Share"
        case .lang: return "Language"
        case .more: return "More"
        }
    }

}

struct NavView: View {
    @EnvironmentObject var mvm: MainViewModel
    @AppStorage("language") private var currentLanguage = getLanguage()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        // The system supplies the Liquid Glass pill on iOS 26+ when built
        // with the iOS 26 SDK or later, and a standard tab bar on older iOS.
        TabView(selection: $mvm.selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                NavigationView {
                    ZStack {
                        AppBG()
                        destination(for: tab)
                    }
                    .navigationBarHidden(true)
                }
                .navigationViewStyle(.stack)
                .tag(tab)
                .tabItem {
                    icon(for: tab)
                        .accessibilityLabel(Text(showsBack(for: tab) ? backLabel : tab.text))
                }
            }
        }
        .background(TabBarBackAction(onReselect: goBackInSelectedTab))
        .tint(colorResource.primary_500)
        .ignoresSafeArea(.keyboard)
    }

    private func icon(for tab: Tab) -> Image {
        if showsBack(for: tab) {
            return Image(systemName: "chevron.backward").renderingMode(.template)
        }

        switch tab {
        case .home: return symbolIcon(named: "home", for: tab)
        case .account: return symbolIcon(named: "account", for: tab)
        case .share: return symbolIcon(named: "share", for: tab)
        case .lang: return Image(uiImage: languageIcon).renderingMode(.original)
        case .more: return symbolIcon(named: "menu", for: tab)
        }
    }

    private var backLabel: String {
        currentLanguage == "Ar" ? "رجوع" : "Back"
    }

    private func showsBack(for tab: Tab) -> Bool {
        // Only the visible tab's screen level can describe its back action.
        guard mvm.selectedTab == tab else { return false }
        switch tab {
        case .home: return mvm.backLevels.contains(mvm.viewLevel)
        case .account: return mvm.accountBackLevels.contains(mvm.accountViewLevel)
        case .more: return mvm.menuBackLevels.contains(mvm.viewLevel)
        case .share, .lang: return false
        }
    }

    private func goBackInSelectedTab(nativeIndex: Int) -> Bool {
        // A pending programmatic tab change must not route a tap to another tab.
        guard Tab.allCases.indices.contains(nativeIndex),
              Tab.allCases[nativeIndex] == mvm.selectedTab else { return false }
        guard showsBack(for: mvm.selectedTab) else { return false }
        switch mvm.selectedTab {
        case .home, .more:
            guard !mvm.back else { return true }
            mvm.back = true
        case .account:
            guard !mvm.accountBack else { return true }
            mvm.accountBack = true
        case .share, .lang:
            return false
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        return true
    }

    private func symbolIcon(named name: String, for tab: Tab) -> Image {
        let template = Image(name).renderingMode(.template)
        guard mvm.selectedTab != tab, let image = UIImage(named: name) else {
            return template
        }

        // NavViewOld used Color.secondary for inactive symbols. Render that
        // color into the image so the native bar preserves it instead of
        // applying its own inactive tint. Selected symbols keep the green tint.
        let traits = UITraitCollection(traitsFrom: [
            .current,
            UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        ])
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

    // Keep the existing NavigationView containers while the screens still
    // use NavigationLink(tag:selection:). Migrate those in a separate step.
    @ViewBuilder
    private func destination(for tab: Tab) -> some View {
        switch tab {
        case .home: HomeView()
        case .account: AccountView()
        case .share: ShareView()
        case .lang: LanguageLayout()
        case .more: MoreView()
        }
    }
}

// TabView's selection binding doesn't report taps on the already selected
// tab. Intercept that one interaction through the native controller, keeping
// SwiftUI's delegate in charge of all other tab events and transitions.
private struct TabBarBackAction: UIViewControllerRepresentable {
    var onReselect: @MainActor (Int) -> Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(onReselect: onReselect)
    }

    func makeUIViewController(context: Context) -> ObserverController {
        let controller = ObserverController()
        controller.onResolve = { [weak coordinator = context.coordinator] tabController in
            coordinator?.attach(to: tabController)
        }
        return controller
    }

    func updateUIViewController(_ controller: ObserverController, context: Context) {
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
        var onReselect: @MainActor (Int) -> Bool
        private weak var controller: UITabBarController?
        // NSObject's selector queries are nonisolated; delegate changes and
        // action calls are confined to the main actor by this coordinator.
        nonisolated(unsafe) private var originalDelegate: UITabBarControllerDelegate?

        init(onReselect: @escaping @MainActor (Int) -> Bool) {
            self.onReselect = onReselect
            super.init()
        }

        func attach(to tabController: UITabBarController) {
            guard controller !== tabController || tabController.delegate !== self else { return }
            detach()
            controller = tabController
            originalDelegate = tabController.delegate
            tabController.delegate = self
        }

        func detach() {
            if let controller, controller.delegate === self {
                controller.delegate = originalDelegate
            }
            controller = nil
            originalDelegate = nil
        }

        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            if tabBarController.selectedViewController === viewController, onReselect(tabBarController.selectedIndex) {
                // Keep the current tab and let the existing screen handler
                // go back once, rather than letting UIKit pop to the root.
                return false
            }
            return originalDelegate?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
        }

        @available(iOS 18.0, *)
        func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
            if tabBarController.selectedTab === tab, onReselect(tabBarController.selectedIndex) {
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
