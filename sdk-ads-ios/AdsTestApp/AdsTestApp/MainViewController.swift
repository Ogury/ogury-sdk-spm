//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
internal import ComposableArchitecture
import SwiftUI
import AdsCardLibrary
import SnapKit
import CoreServices
import UniformTypeIdentifiers
import UserDefault

class MainViewController: UIViewController {
    lazy var store = Store(initialState: AppFeature.State()) {
        AppFeature(adHostingViewController: self, adDelegate: self)
    }
    lazy var rootView = AppView(store: self.store)
    lazy var adViewController = UIHostingController(rootView: rootView)
    @UserDefault("lastAdapterVersion")
    var lastVersion: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
        Task {
            await SdkLauncher.shared.launch()
            SdkLauncher.shared.adapter.setAllowedTypes(["Publisher", "Internal", "Requests", "Mraid", "Monitoring", "SDK Callbacks"])
            SdkLauncher.shared.adapter.setLogLevel(.all)
        }
        addViewToHierarchy()
        startNotifiers()
    }
    
    private func start() {
        // load default preferences from various files
        SettingsController.loadPreferences()
        loadCards()
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: AdColorPalette.Text.primary(onAccent: false).color,
            .font : UIFont(name: "PPTelegraf-Regular", size: 26)!
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: AdColorPalette.Text.primary(onAccent: false).color,
            .font : UIFont(name: "PPTelegraf-Regular", size: 20)!
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: AdColorPalette.Text.primary(onAccent: false).color,
            .font : UIFont(name: "PPTelegraf-Regular", size: 16)!
        ], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: AdColorPalette.Primary.supplementary.color,
            .font : UIFont(name: "PPTelegraf-Regular", size: 16)!
        ], for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: AdColorPalette.Primary.supplementary.color,
            .font : UIFont(name: "PPTelegraf-Regular", size: 16)!
        ], for: .highlighted)
        UIPageControl.appearance().currentPageIndicatorTintColor = AdColorPalette.Primary.accent.color
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }
    
    private func startNotifiers() {
        NotificationCenter
            .default
            .addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { _ in
                self.saveCards()
        }
    }
    
    private func addViewToHierarchy() {
        view.addSubview(adViewController.view)
        addChild(adViewController)
        adViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadCards() {
        ViewStore(store, observe: { $0 }).send(.loadCards)
    }
    
    private func saveCards() {
        ViewStore(store, observe: { $0 }).send(.saveCards)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adViewController.view.frame = view.bounds
        checkForWhatsNew()
        if SettingsController().startConsentWithApplication {
            showConsentNotice()
        }
    }
    
    private func checkForWhatsNew() {
        defer { lastVersion = SdkLauncher.shared.adapter.sdkVersions }
        if lastVersion == nil || lastVersion! != SdkLauncher.shared.adapter.sdkVersions {
            ViewStore(store, observe: { $0 }).send(.main(.showWhatsNew(SdkLauncher.shared.adapter.whatsNew ?? "")))
        }
    }
    
    func loadFile(at url: URL) {
        ViewStore(store, observe: { $0 }).send(.importFile(url))
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        presentedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        presentedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

extension MainViewController: AdLifeCycleDelegate, ApplicationDelegate {
    func viewController(for adManager: any AdManager) -> UIViewController? {
        self
    }
    
    func focusLogs(on cardId: String) {
        ViewStore(store, observe: { $0 }).send(.focusLogs(on: cardId))
    }
    
    func deleteCard(withId id: UUID) {
        ViewStore(store, observe: { $0 }).send(.deleteCard(id: id))
    }
    
    func saveSet() {
        ViewStore(store, observe: { $0 }).send(.saveCards)
    }
    
    func share(json: String, filename: String) {
        UIApplication.topViewController()?.dismiss(animated: true)
        guard let url = createTemporaryFile(text: json, filename: filename) else { return }
        print("📄 File exported to \(url.absoluteString)")
        let metaData = LinkPresentationItemSource.metaData(title: "Share your Ads set",
                                                           url: url,
                                                           fileName: "shareImageData",
                                                           fileType: "png")
        let item = LinkPresentationItemSource(metaData: metaData)
        let ac = UIActivityViewController(activityItems: [item], applicationActivities: nil)
       ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems:[Any]?, error: Error?) in
      }
        present(ac, animated: true)
    }
    
    func createTemporaryFile(text: String, filename: String) -> URL? {
        do {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).\(UTType.adsTestAppExtension)")
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating temporary file: \(error)")
            return nil
        }
    }
    
    func showImportPanel() {
        UIApplication.topViewController()?.dismiss(animated: true)
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.adsTestAppType])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Set to true if you want to allow multiple file selection
        present(documentPicker, animated: true, completion: nil)
    }
    
    @discardableResult
    func createDocumentFile(text: String, filename: String) -> URL? {
        do {
            let fileURL = getDocumentsDirectory().appendingPathComponent("\(filename).\(UTType.adsTestAppExtension)")
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating temporary file: \(error)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func showConsentNotice() {
        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))
            ConsentController.resetConsent(viewController: self)
        }
    }
    
    func enableTestModeForAllCards(_ enable: Bool) {
        ViewStore(store, observe: { $0 }).send(.forceTestMode(enable))
    }
}

extension MainViewController: UIDocumentPickerDelegate {
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            return
        }
        print("📄 load File at \(selectedURL.absoluteString)")
        loadFile(at: selectedURL)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
