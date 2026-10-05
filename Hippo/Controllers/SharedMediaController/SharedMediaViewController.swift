//
//  SharedMediaViewController.swift
//  HippoAgent
//
//  Created by sreshta bhagat on 15/03/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import QuickLook

final class SharedMediaViewController: UIViewController {

    // MARK: Layout metrics
    //
    // Measured off the design: a 3-up grid inset 16pt from each edge with 8pt
    // gutters, so a tile is (width - 32 - 16) / 3.

    private enum Grid {
        static let sideInset: CGFloat = 16
        static let spacing: CGFloat = 8
        static let columns: CGFloat = 3
    }

    @IBOutlet private var viewNavigationBar : NavigationBar!
    @IBOutlet private weak var tabBar: SharedMediaTabBar!
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SharedMediaCell", bundle: FuguFlowManager.bundle), forCellWithReuseIdentifier: "SharedMediaCell")
            collectionView.register(SharedMediaDocCell.self,
                                    forCellWithReuseIdentifier: SharedMediaDocCell.reuseIdentifier)
        }
    }

    //MARK:- Variables

    /// Everything the API returned, in response order.
    private var allMedia = [ShareMediaModel]()
    /// The slice backing the collection view, recomputed on load and on tab change.
    private var visibleItems = [ShareMediaModel]()
    private var selectedTab: SharedMediaTab = .media

    var channelId : Int?
    var downloadingDoc = [String:String]()
    var qldataSource: HippoQLDataSource?
    /// Backs the swipeable Quick Look viewer opened from the Media tab.
    private var mediaGallery: SharedMediaGalleryDataSource?
    private var informationView: InformationView?
    /// Set when the request itself failed, which is offered a retry — as opposed to a
    /// channel that genuinely has no attachments.
    private var loadFailed = false

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTabBar()
        setupNavigationBar()
        getMediaData()
        addNotificationObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            self.view.overrideUserInterfaceStyle = .light
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadCompleted(_:)), name: Notification.Name.fileDownloadCompleted, object: nil)
    }

    @objc func fileDownloadCompleted(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String else {
            return
        }
        refreshRow(for: url)
        mediaGallery?.downloadFinished(url: url)

        // Only jump into the preview for the file the user actually tapped; a
        // download kicked off from the row's own button just settles in place.
        guard let name = downloadingDoc.removeValue(forKey: url) else { return }
        openFile(url: url, name: name)
    }

    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.backgroundColor = HippoConfig.shared.colorConfig.hippoSurface
        collectionView.alwaysBounceVertical = true
    }

    private func setupTabBar() {
        tabBar.select(selectedTab, animated: false)
        tabBar.onSelect = { [weak self] tab in
            self?.switchTo(tab)
        }
    }

    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        viewNavigationBar.title = HippoStrings.sharedMediaTitle
        viewNavigationBar.leftButton.addTarget(self, action: #selector(backBtn), for: .touchUpInside)
        viewNavigationBar.addBottomShadow()
    }

    //MARK:- Tabs

    private func switchTo(_ tab: SharedMediaTab) {
        selectedTab = tab
        applyCurrentTab()
    }

    private func applyCurrentTab() {
        visibleItems = allMedia.sharedMediaItems(for: selectedTab)
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        updateInformationView()
    }

    //MARK:- Private Functions
    private func getMediaData(){

        guard let channelId = channelId else {
            return
        }

        var params: [String : Any] = ["channel_id" : channelId]
        if currentUserType() == .agent {
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }else {
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }

        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.SharedMedia.rawValue) { [weak self] (response, error, _, statusCode) in
            guard let self = self else { return }

            guard error == nil,
                  let response = response as? [String: Any],
                  let data = response["data"] as? Array<Any> else {
                // A failed request and an empty channel used to look identical; only
                // the former is worth offering a retry for.
                self.loadFailed = true
                self.allMedia = []
                self.applyCurrentTab()
                return
            }

            guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
                self.loadFailed = true
                self.allMedia = []
                self.applyCurrentTab()
                return
            }

            let jsonDecoder = JSONDecoder()
            let decodedData = try? jsonDecoder.decode([ShareMediaModel].self, from: jsonData)

            self.loadFailed = false
            self.allMedia = decodedData ?? [ShareMediaModel]()
            self.applyCurrentTab()
        }
    }

    @objc private func retryTapped() {
        loadFailed = false
        updateInformationView()
        getMediaData()
    }

    /// Reloads just the row whose download state changed, rather than the whole list.
    private func refreshRow(for url: String) {
        guard let index = visibleItems.firstIndex(where: { $0.openURL == url }) else { return }
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension SharedMediaViewController {

    /// The empty state is a sibling of the collection view, not a subview of it, so it
    /// stays put instead of scrolling with the content.
    private func updateInformationView() {
        guard visibleItems.isEmpty else {
            informationView?.isHidden = true
            return
        }

        if informationView == nil {
            let infoView = InformationView.loadView(collectionView.frame)
            infoView.translatesAutoresizingMaskIntoConstraints = false
            // Below the tab bar in the z-order, so the strip it spans still takes taps.
            view.insertSubview(infoView, belowSubview: tabBar)
            NSLayoutConstraint.activate([
                // Centred on everything under the navigation bar, not just the collection
                // view: anchoring to the collection view would centre it in a region that
                // starts below the tab bar, which reads as sitting too low on the screen.
                infoView.topAnchor.constraint(equalTo: viewNavigationBar.bottomAnchor),
                infoView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                infoView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
                infoView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
            ])
            infoView.button_Info.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
            informationView = infoView
        }

        informationView?.informationLabel.text = emptyStateMessage
        // Same empty-state logo as the chat list / support chat empty states instead
        // of a blank 120pt gap above the label.
        informationView?.informationImageView.contentMode = .scaleAspectFit
        informationView?.informationImageView.image = emptyStateImage
        informationView?.isButtonInfoHidden = !loadFailed
        informationView?.button_Info.setTitle(HippoConfig.shared.theme.chatListRetryBtnText ?? HippoStrings.retry, for: .normal)
        informationView?.isHidden = false
    }

    private var emptyStateMessage: String {
        guard !loadFailed else { return HippoStrings.somethingWentWrong }
        switch selectedTab {
        case .media:
            return HippoStrings.sharedMediaNoMedia
        case .docs:
            return HippoStrings.sharedMediaNoDocs
        }
    }

    /// The artwork follows the tab, so an empty Docs tab doesn't show the gallery
    /// illustration. A failed load keeps the current tab's artwork — the label and the
    /// retry button already say what went wrong.
    private var emptyStateImage: UIImage? {
        switch selectedTab {
        case .media:
            return HippoConfig.shared.theme.noMediaImage
        case .docs:
            return HippoConfig.shared.theme.noDocsImage
        }
    }
}

extension SharedMediaViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = visibleItems[indexPath.item]

        switch selectedTab {
        case .media:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharedMediaCell", for: indexPath) as! SharedMediaCell
            cell.configure(with: item)
            return cell

        case .docs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharedMediaDocCell.reuseIdentifier, for: indexPath) as! SharedMediaDocCell
            cell.configure(with: item,
                           isLastRow: indexPath.item == visibleItems.count - 1) { [weak self] in
                self?.startDownload(for: item, openWhenDone: false)
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = visibleItems[indexPath.item]

        // Photos and videos open together so the viewer can swipe between them.
        if selectedTab == .media {
            openMediaGallery(startingAt: indexPath.item)
            return
        }

        // Images, videos, audio and documents all open in the native Quick Look
        // viewer once downloaded.
        guard let url = item.openURL else {
            showAlert(title: "", message: HippoStrings.somethingWentWrong, actionComplete: nil)
            return
        }
        guard DownloadManager.shared.isFileDownloadedWith(url: url) else {
            startDownload(for: item, openWhenDone: true)
            return
        }

        openFile(url: url, name: item.file_name ?? "")
    }

    private func openMediaGallery(startingAt index: Int) {
        let gallery = SharedMediaGalleryDataSource(items: visibleItems)
        let qlPreview = QLPreviewController()
        gallery.controller = qlPreview
        mediaGallery = gallery
        qlPreview.dataSource = gallery
        qlPreview.delegate = gallery
        qlPreview.currentPreviewItemIndex = index
        qlPreview.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(qlPreview, animated: true)
    }

    private func startDownload(for item: ShareMediaModel, openWhenDone: Bool) {
        guard let url = item.openURL,
              !DownloadManager.shared.isFileBeingDownloadedWith(url: url) else { return }

        if openWhenDone {
            downloadingDoc[url] = item.file_name ?? ""
        }
        DownloadManager.shared.downloadFileWith(url: url, name: item.downloadFileName)
        refreshRow(for: url)
    }

    func openFile(url: String, name: String) {
        guard  DownloadManager.shared.isFileDownloadedWith(url: url) else {
            HippoConfig.shared.log.debug("-------\nERROR\nFile is not downloaded\n--------", level: .error)
            return
        }
        var fileName = name
        if fileName.count > 10 {
            let stringIndex = fileName.index(fileName.startIndex, offsetBy: 9)
            fileName = String(fileName[..<stringIndex])
        }
        openQuicklookFor(fileURL: url, fileName: fileName)
    }

    func openQuicklookFor(fileURL: String, fileName: String) {
        guard let localPath = DownloadManager.shared.getLocalPathOf(url: fileURL) else {
            return
        }
        let url = URL(fileURLWithPath: localPath)

        let qlItem = QuickLookItem(previewItemURL: url, previewItemTitle: fileName)

        let qlPreview = QLPreviewController()
        self.qldataSource = HippoQLDataSource(previewItems: [qlItem])
        qlPreview.delegate = self.qldataSource
        qlPreview.dataSource = self.qldataSource
        qlPreview.title = fileName
        qlPreview.navigationItem.hidesBackButton = false
        qlPreview.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(qlPreview, animated: true)
    }
}


extension SharedMediaViewController: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - Grid.sideInset * 2

        switch selectedTab {
        case .media:
            let totalSpacing = Grid.spacing * (Grid.columns - 1)
            let side = ((availableWidth - totalSpacing) / Grid.columns).rounded(.down)
            return CGSize(width: side, height: side)

        case .docs:
            // Rows run edge to edge; the cell insets its own content.
            return CGSize(width: collectionView.bounds.width,
                          height: SharedMediaDocCell.preferredHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch selectedTab {
        case .media:
            return UIEdgeInsets(top: 0, left: Grid.sideInset,
                                bottom: Grid.sideInset, right: Grid.sideInset)
        case .docs:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return selectedTab == .media ? Grid.spacing : 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return selectedTab == .media ? Grid.spacing : 0
    }
}

// MARK: - Media gallery

/// Quick Look data source for the Media tab: every photo and video in the tab, so the
/// viewer swipes between them. Quick Look only previews local files, so each item is
/// downloaded when Quick Look first asks for it (the current one and its neighbours);
/// until it lands, the grid's cached thumbnail stands in and is swapped out after.
final class SharedMediaGalleryDataSource: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    private let items: [ShareMediaModel]
    weak var controller: QLPreviewController?

    init(items: [ShareMediaModel]) {
        self.items = items
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = items[index]
        let title = item.file_name
        guard let url = item.openURL else {
            return QuickLookItem(previewItemURL: nil, previewItemTitle: title)
        }
        if DownloadManager.shared.isFileDownloadedWith(url: url),
           let localPath = DownloadManager.shared.getLocalPathOf(url: url) {
            return QuickLookItem(previewItemURL: URL(fileURLWithPath: localPath), previewItemTitle: title)
        }
        DownloadManager.shared.downloadFileWith(url: url, name: item.downloadFileName)
        return QuickLookItem(previewItemURL: placeholderURL(for: item), previewItemTitle: title)
    }

    /// Swaps a placeholder for the real file once its download lands.
    func downloadFinished(url: String) {
        guard let controller = controller,
              let index = items.firstIndex(where: { $0.openURL == url }) else { return }
        if index == controller.currentPreviewItemIndex {
            controller.refreshCurrentPreviewItem()
        } else {
            // A neighbour Quick Look already preloaded with its placeholder.
            let current = controller.currentPreviewItemIndex
            controller.reloadData()
            controller.currentPreviewItemIndex = current
        }
    }

    /// The tile's thumbnail from the image cache, written to a temp file. Same URL the
    /// grid cell loads, so it is normally already in memory.
    private func placeholderURL(for item: ShareMediaModel) -> URL? {
        let thumbnail = item.fileType == .video ? item.thumbnail_url
                                                : (item.thumbnail_url ?? item.image_url ?? item.url)
        guard let key = thumbnail.flatMap({ URL(string: $0)?.absoluteString }),
              let image = ImageCache.default.retrieveImageInMemoryCache(forKey: key),
              let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("hippo-media-placeholder-\(abs(key.hashValue)).jpg")
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            return nil
        }
    }
}
