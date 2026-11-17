//
//  LinkPreview.swift
//  Hippo
//
//  WhatsApp-style link previews for chat bubbles, the bot video card (message_type 24) and the
//  floating video player they open.
//

import UIKit
import AVFoundation
import WebKit

// MARK: - Model

/// What a link preview card shows: title, description, image and domain, plus whether the link
/// can be played in the floating player (YouTube, or a direct video file).
struct LinkMeta: Codable {
    var url: String
    var title: String?
    var description: String?
    var imageUrl: String?
    var siteName: String?
    /// YouTube video id, when the link is a YouTube video.
    var youtubeId: String?
    /// A directly playable video file (og:video or a .mp4 link), when there is one.
    var videoUrl: String?

    init(url: String) {
        self.url = url
    }

    var isPlayable: Bool {
        return !(youtubeId ?? "").isEmpty || !(videoUrl ?? "").isEmpty
    }

    /// Worth a card at all: something besides the bare link.
    var hasContent: Bool {
        return !(title ?? "").isEmpty || !(imageUrl ?? "").isEmpty
    }

    /// "www.netflix.com" style host for the card's last line.
    var domain: String {
        return URL(string: url)?.host ?? url
    }

    var playUrl: String? {
        if let id = youtubeId, !id.isEmpty { return "https://www.youtube.com/watch?v=" + id }
        return videoUrl
    }
}

// MARK: - Loader

/// Fetches link preview data for chat messages.
///
/// - YouTube: the official oEmbed endpoint for the title and channel, and the video's thumbnail.
/// - Other pages: Open Graph / Twitter / HTML meta tags, with a link-preview user agent so sites
///   serve their share metadata.
/// - Direct images / videos: the file itself.
///
/// Results are cached in memory and on disk (so reopening a chat doesn't refetch), requests for
/// the same link are coalesced, and failures are remembered for the session.
enum LinkMetaLoader {

    private static let userAgent = "Mozilla/5.0 (compatible; facebookexternalhit/1.1; +http://www.facebook.com/externalhit_uatext.php)"
    private static let maxBody = 1024 * 1024

    private static var memory: [String: LinkMeta] = [:]
    private static var failed = Set<String>()
    private static var pending: [String: [(LinkMeta?) -> Void]] = [:]

    private static let youtubeRegex = try? NSRegularExpression(
        pattern: "(?:youtube\\.com/(?:watch\\?(?:.*&)?v=|embed/|shorts/|live/|v/)|youtu\\.be/)([A-Za-z0-9_-]{6,})")
    private static let videoFileRegex = try? NSRegularExpression(pattern: "\\.(mp4|m4v|webm|3gp|mov)(\\?.*)?$", options: .caseInsensitive)
    private static let imageFileRegex = try? NSRegularExpression(pattern: "\\.(jpe?g|png|gif|webp)(\\?.*)?$", options: .caseInsensitive)

    /// YouTube video id from watch / youtu.be / embed / shorts / live links, or nil.
    static func youtubeId(_ url: String?) -> String? {
        guard let url = url, let regex = youtubeRegex,
              let m = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
              let r = Range(m.range(at: 1), in: url) else { return nil }
        return String(url[r])
    }

    static func isDirectVideo(_ url: String?) -> Bool {
        guard let url = url, let regex = videoFileRegex else { return false }
        return regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) != nil
    }

    private static func isImageFile(_ url: String) -> Bool {
        guard let regex = imageFileRegex else { return false }
        return regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) != nil
    }

    /// Cached result, or nil if not loaded yet. Main thread.
    static func peek(_ url: String) -> LinkMeta? {
        if let m = memory[url] { return m }
        guard let data = try? Data(contentsOf: diskFile(url)),
              let m = try? JSONDecoder().decode(LinkMeta.self, from: data) else { return nil }
        memory[url] = m
        return m
    }

    static func hasFailed(_ url: String) -> Bool {
        return failed.contains(url)
    }

    /// Loads (or returns the cached) preview for `url`. Completion on the main thread; nil when
    /// nothing useful could be read.
    static func load(_ url: String, completion: @escaping (LinkMeta?) -> Void) {
        if let cached = peek(url) {
            completion(cached)
            return
        }
        if failed.contains(url) {
            completion(nil)
            return
        }
        if pending[url] != nil {
            pending[url]?.append(completion)
            return
        }
        pending[url] = [completion]
        fetch(url) { meta in
            let result = meta.flatMap { $0.hasContent || $0.isPlayable ? $0 : nil }
            DispatchQueue.main.async {
                if let result = result {
                    memory[url] = result
                    if let data = try? JSONEncoder().encode(result) {
                        try? data.write(to: diskFile(url))
                    }
                } else {
                    failed.insert(url)
                }
                let waiting = pending.removeValue(forKey: url) ?? []
                waiting.forEach { $0(result) }
            }
        }
    }

    private static func diskFile(_ url: String) -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("hippo_link_meta", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = "lm_" + String(UInt(bitPattern: url.hashValueStable), radix: 16) + "_\(url.count).json"
        return dir.appendingPathComponent(name)
    }

    // MARK: Fetching

    private static func request(_ url: URL) -> URLRequest {
        var r = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 8)
        r.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return r
    }

    private static func fetch(_ link: String, completion: @escaping (LinkMeta?) -> Void) {
        var meta = LinkMeta(url: link)
        if let yt = youtubeId(link) {
            meta.youtubeId = yt
            meta.siteName = "YouTube"
            meta.imageUrl = "https://img.youtube.com/vi/\(yt)/hqdefault.jpg"
            var comps = URLComponents(string: "https://www.youtube.com/oembed")
            comps?.queryItems = [URLQueryItem(name: "format", value: "json"), URLQueryItem(name: "url", value: link)]
            guard let oembed = comps?.url else {
                completion(meta)
                return
            }
            URLSession.shared.dataTask(with: request(oembed)) { data, _, _ in
                if let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
                    meta.title = json["title"] as? String
                    meta.description = json["author_name"] as? String
                }
                // The thumbnail alone still makes a playable card.
                completion(meta)
            }.resume()
            return
        }
        if isDirectVideo(link) {
            meta.videoUrl = link
            completion(meta)
            return
        }
        if isImageFile(link) {
            meta.imageUrl = link
            completion(meta)
            return
        }
        guard let url = URL(string: link) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: request(url)) { data, response, _ in
            guard let data = data, let http = response as? HTTPURLResponse else {
                completion(nil)
                return
            }
            let finalUrl = http.url?.absoluteString ?? link
            let type = (http.mimeType ?? "").lowercased()
            if type.hasPrefix("image/") {
                meta.imageUrl = finalUrl
                completion(meta)
                return
            }
            if type.hasPrefix("video/") {
                meta.videoUrl = finalUrl
                completion(meta)
                return
            }
            guard type.contains("html") else {
                completion(meta)
                return
            }
            let body = data.prefix(maxBody)
            var encoding = String.Encoding.utf8
            if let name = http.textEncodingName {
                let cf = CFStringConvertIANACharSetNameToEncoding(name as CFString)
                if cf != kCFStringEncodingInvalidId {
                    encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cf))
                }
            }
            let html = String(data: body, encoding: encoding) ?? String(data: body, encoding: .isoLatin1) ?? ""
            let base = http.url ?? url
            let tags = metaTags(html)
            func first(_ keys: [String]) -> String? {
                for k in keys { if let v = tags[k], !v.isEmpty { return v } }
                return nil
            }
            func absolute(_ keys: [String]) -> String? {
                guard var v = first(keys) else { return nil }
                if v.hasPrefix("//") { v = "https:" + v }
                return URL(string: v, relativeTo: base)?.absoluteString ?? v
            }
            meta.title = clean(first(["og:title", "twitter:title"]) ?? titleTag(html))
            meta.description = clean(first(["og:description", "twitter:description", "description"]))
            meta.imageUrl = absolute(["og:image:secure_url", "og:image", "og:image:url", "twitter:image", "twitter:image:src"])
            meta.siteName = first(["og:site_name"])
            let video = absolute(["og:video:secure_url", "og:video:url", "og:video"])
            if isDirectVideo(video) { meta.videoUrl = video }
            if let yt = youtubeId(video) { meta.youtubeId = yt }
            completion(meta)
        }.resume()
    }

    /// property / name -> content for every <meta> tag (first one wins).
    private static func metaTags(_ html: String) -> [String: String] {
        var out: [String: String] = [:]
        guard let tagRegex = try? NSRegularExpression(pattern: "<meta\\s[^>]*>", options: .caseInsensitive),
              let attrRegex = try? NSRegularExpression(pattern: "([a-zA-Z:_-]+)\\s*=\\s*(\"([^\"]*)\"|'([^']*)')") else { return out }
        let ns = html as NSString
        for tag in tagRegex.matches(in: html, range: NSRange(location: 0, length: ns.length)) {
            let t = ns.substring(with: tag.range)
            let tns = t as NSString
            var attrs: [String: String] = [:]
            for a in attrRegex.matches(in: t, range: NSRange(location: 0, length: tns.length)) {
                let name = tns.substring(with: a.range(at: 1)).lowercased()
                let r = a.range(at: 3).location != NSNotFound ? a.range(at: 3) : a.range(at: 4)
                attrs[name] = r.location != NSNotFound ? tns.substring(with: r) : ""
            }
            guard let key = (attrs["property"] ?? attrs["name"])?.lowercased(), let content = attrs["content"] else { continue }
            if out[key] == nil { out[key] = decodeEntities(content.trimmingCharacters(in: .whitespacesAndNewlines)) }
        }
        return out
    }

    private static func titleTag(_ html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "<title[^>]*>([\\s\\S]*?)</title>", options: .caseInsensitive),
              let m = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let r = Range(m.range(at: 1), in: html) else { return nil }
        return decodeEntities(String(html[r]))
    }

    private static func clean(_ s: String?) -> String? {
        guard let s = s else { return nil }
        let t = s.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
        return t.isEmpty ? nil : t
    }

    static func decodeEntities(_ s: String) -> String {
        guard s.contains("&") else { return s }
        var out = s
        let named = ["&amp;": "&", "&quot;": "\"", "&#39;": "'", "&apos;": "'", "&lt;": "<", "&gt;": ">", "&nbsp;": " "]
        for (k, v) in named { out = out.replacingOccurrences(of: k, with: v) }
        guard let regex = try? NSRegularExpression(pattern: "&#(x?)([0-9a-fA-F]+);") else { return out }
        let ns = out as NSString
        var result = ""
        var last = 0
        for m in regex.matches(in: out, range: NSRange(location: 0, length: ns.length)) {
            result += ns.substring(with: NSRange(location: last, length: m.range.location - last))
            let hex = ns.substring(with: m.range(at: 1)) == "x"
            let num = ns.substring(with: m.range(at: 2))
            if let code = UInt32(num, radix: hex ? 16 : 10), let scalar = Unicode.Scalar(code) {
                result += String(Character(scalar))
            } else {
                result += ns.substring(with: m.range)
            }
            last = m.range.location + m.range.length
        }
        result += ns.substring(from: last)
        return result
    }

    /// First web link in a message (after HTML is stripped), normalised to https.
    static func firstUrl(in message: String?) -> String? {
        guard var text = message, !text.isEmpty else { return nil }
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        text = decodeEntities(text)
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        for m in detector.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            guard let r = Range(m.range, in: text) else { continue }
            let raw = String(text[r])
            let lower = raw.lowercased()
            if lower.hasPrefix("http://") || lower.hasPrefix("https://") { return raw }
            if lower.hasPrefix("www.") { return "https://" + raw }
        }
        return nil
    }
}

private extension String {
    /// Stable across launches (Swift's hashValue is seeded per process): FNV-1a.
    var hashValueStable: Int {
        var h: UInt64 = 0xcbf29ce484222325
        for b in utf8 {
            h ^= UInt64(b)
            h = h &* 0x100000001b3
        }
        return Int(truncatingIfNeeded: h)
    }
}

// MARK: - Card

/// Link preview card: 16:9 thumbnail (with a play button for videos, or "Playing in picture in
/// picture" while it floats), title, description and domain. Tapping a video plays it in the
/// floating player; other links open in the browser.
final class LinkPreviewCardView: UIView {

    /// The card's link changed size (became visible / hidden) after an async load.
    var onContentChanged: (() -> Void)?

    private(set) var url: String?
    private var meta: LinkMeta?
    private var sent = false
    private var forcePlay = false

    private let media = UIView()
    private let imageView = UIImageView()
    private let play = UIImageView()
    private let pipLabel = UILabel()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let domainLabel = UILabel()
    private let textStack = UIStackView()
    private var mediaHeight: NSLayoutConstraint!

    /// The card's final width. Self-sizing measures rows at temporary widths first; sizing the
    /// thumbnail and wrapping the text for the final width keeps the row height right.
    var fixedWidth: CGFloat = 272 {
        didSet { applyFixedWidth() }
    }

    private func applyFixedWidth() {
        mediaHeight.constant = (fixedWidth * 9 / 16).rounded()
        let textWidth = fixedWidth - 20
        [titleLabel, descLabel, domainLabel].forEach { $0.preferredMaxLayoutWidth = textWidth }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(red: 0x1F / 255, green: 0x24 / 255, blue: 0x30 / 255, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        media.addSubview(imageView)

        play.image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        play.tintColor = .white
        play.contentMode = .center
        play.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        play.layer.cornerRadius = 24
        play.translatesAutoresizingMaskIntoConstraints = false
        media.addSubview(play)

        pipLabel.text = HippoStrings.videoPlayingInPip
        pipLabel.textColor = .white
        pipLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        pipLabel.textAlignment = .center
        pipLabel.numberOfLines = 2
        pipLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        pipLabel.translatesAutoresizingMaskIntoConstraints = false
        media.addSubview(pipLabel)

        mediaHeight = media.heightAnchor.constraint(equalToConstant: 153)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: media.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: media.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: media.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: media.trailingAnchor),
            play.centerXAnchor.constraint(equalTo: media.centerXAnchor),
            play.centerYAnchor.constraint(equalTo: media.centerYAnchor),
            play.widthAnchor.constraint(equalToConstant: 48),
            play.heightAnchor.constraint(equalToConstant: 48),
            pipLabel.topAnchor.constraint(equalTo: media.topAnchor),
            pipLabel.bottomAnchor.constraint(equalTo: media.bottomAnchor),
            pipLabel.leadingAnchor.constraint(equalTo: media.leadingAnchor),
            pipLabel.trailingAnchor.constraint(equalTo: media.trailingAnchor),
            mediaHeight
        ])

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2
        descLabel.font = UIFont.systemFont(ofSize: 12.5)
        descLabel.numberOfLines = 2
        domainLabel.font = UIFont.systemFont(ofSize: 12)
        domainLabel.numberOfLines = 1
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.isLayoutMarginsRelativeArrangement = true
        textStack.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 9, right: 10)
        [titleLabel, descLabel, domainLabel].forEach { textStack.addArrangedSubview($0) }

        let stack = UIStackView(arrangedSubviews: [media, textStack])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        applyFixedWidth()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        NotificationCenter.default.addObserver(self, selector: #selector(playbackChanged), name: HippoFloatingVideoPlayer.didChange, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Text bubble preview: hidden until there is something to show.
    /// - Parameter sent: true on the visitor's own (accent) bubble.
    func bind(messageText: String?, sent: Bool) {
        self.sent = sent
        forcePlay = false
        let link = LinkMetaLoader.firstUrl(in: messageText)
        url = link
        guard let link = link else {
            setVisible(false)
            return
        }
        if let cached = LinkMetaLoader.peek(link) {
            apply(cached)
            return
        }
        setVisible(false)
        guard !LinkMetaLoader.hasFailed(link) else { return }
        LinkMetaLoader.load(link) { [weak self] meta in
            guard let self = self, self.url == link else { return }
            let wasHidden = self.isHidden
            self.apply(meta)
            if wasHidden != self.isHidden { self.onContentChanged?() }
        }
    }

    /// Bot embedded video: always a playable card. A YouTube thumbnail (or a dark placeholder)
    /// shows straight away; title and channel fill in once the preview loads.
    func bindVideo(link: String?) {
        sent = false
        forcePlay = true
        url = link
        guard let link = link, !link.isEmpty else {
            setVisible(false)
            return
        }
        if let cached = LinkMetaLoader.peek(link) {
            apply(cached)
            return
        }
        var base = LinkMeta(url: link)
        base.youtubeId = LinkMetaLoader.youtubeId(link)
        if let yt = base.youtubeId {
            base.imageUrl = "https://img.youtube.com/vi/\(yt)/hqdefault.jpg"
        } else if LinkMetaLoader.isDirectVideo(link) {
            base.videoUrl = link
        }
        apply(base)
        guard !LinkMetaLoader.hasFailed(link) else { return }
        LinkMetaLoader.load(link) { [weak self] meta in
            guard let self = self, self.url == link, let meta = meta else { return }
            self.apply(meta)
            self.onContentChanged?()
        }
    }

    private func setVisible(_ visible: Bool) {
        isHidden = !visible
    }

    private func apply(_ meta: LinkMeta?) {
        guard let meta = meta, forcePlay || meta.hasContent || meta.isPlayable else {
            self.meta = nil
            setVisible(false)
            return
        }
        self.meta = meta
        let colors = HippoConfig.shared.colorConfig
        let primary = sent ? colors.hippoOnAccent : colors.hippoTextPrimary
        let secondary = sent ? colors.hippoOnAccent.withAlphaComponent(0.75) : colors.hippoTextMuted
        backgroundColor = sent ? colors.hippoOnAccent.withAlphaComponent(0.15) : colors.hippoTextPrimary.withAlphaComponent(0.05)

        let playable = forcePlay || meta.isPlayable
        let hasMedia = !(meta.imageUrl ?? "").isEmpty || playable
        media.isHidden = !hasMedia
        if hasMedia {
            imageView.kf.cancelDownloadTask()
            imageView.image = nil
            if let src = meta.imageUrl, let u = URL(string: src) {
                imageView.kf.setImage(with: u)
            } else if let video = meta.videoUrl, let u = URL(string: video) {
                LinkPreviewCardView.frame(of: u) { [weak self] image in
                    guard let self = self, self.meta?.videoUrl == video else { return }
                    self.imageView.image = image
                }
            }
            refreshPlayback()
        }
        set(titleLabel, meta.title, primary)
        set(descLabel, meta.description, secondary)
        set(domainLabel, meta.domain, secondary)
        textStack.isHidden = titleLabel.isHidden && descLabel.isHidden && domainLabel.isHidden
        setVisible(true)
    }

    private func refreshPlayback() {
        guard let meta = meta else { return }
        let playable = forcePlay || meta.isPlayable
        let playUrl = meta.isPlayable ? meta.playUrl : meta.url
        let playingHere = playable && HippoFloatingVideoPlayer.shared.isPlaying(playUrl)
        play.isHidden = !playable || playingHere
        pipLabel.isHidden = !playingHere
    }

    @objc private func playbackChanged() {
        refreshPlayback()
    }

    private func set(_ label: UILabel, _ text: String?, _ color: UIColor) {
        label.text = text
        label.textColor = color
        label.isHidden = (text ?? "").isEmpty
    }

    @objc private func tapped() {
        guard let meta = meta else { return }
        if forcePlay || meta.isPlayable {
            HippoFloatingVideoPlayer.shared.play(meta.isPlayable ? (meta.playUrl ?? meta.url) : meta.url)
        } else if let u = URL(string: meta.url) {
            UIApplication.shared.open(u)
        }
    }

    private static var frames: [URL: UIImage] = [:]

    /// A frame from a direct video file, off the main thread.
    private static func frame(of url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = frames[url] {
            completion(cached)
            return
        }
        DispatchQueue.global(qos: .utility).async {
            let generator = AVAssetImageGenerator(asset: AVAsset(url: url))
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 640, height: 640)
            let image = (try? generator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 600), actualTime: nil)).map { UIImage(cgImage: $0) }
            DispatchQueue.main.async {
                if let image = image { frames[url] = image }
                completion(image)
            }
        }
    }
}

// MARK: - Bubble attachment

/// Puts a link preview card at the top of a text bubble, with the text re-pinned below it.
/// The xib pins the text view's top to the bubble; that constraint is swapped while a card shows.
final class BubbleLinkPreview {

    let card = LinkPreviewCardView()
    private weak var bubble: UIView?
    private weak var textView: UIView?
    private var textTopToBubble: NSLayoutConstraint?
    private var cardConstraints: [NSLayoutConstraint] = []
    private var textTopToCard: NSLayoutConstraint?

    init(bubble: UIView, textView: UIView) {
        self.bubble = bubble
        self.textView = textView
        textTopToBubble = bubble.constraints.first {
            ($0.firstItem === textView && $0.firstAttribute == .top && $0.secondItem === bubble && $0.secondAttribute == .top)
                || ($0.secondItem === textView && $0.secondAttribute == .top && $0.firstItem === bubble && $0.firstAttribute == .top)
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(card)
        // A fixed width: the bubble stretches to the card, and the card's 16:9 thumbnail and
        // text measure once at their final width (a width that only settles during self-sizing
        // leaves the row's height stale).
        let cardWidth = min(UIScreen.main.bounds.width * 0.72, 300).rounded()
        card.fixedWidth = cardWidth
        let width = card.widthAnchor.constraint(equalToConstant: cardWidth)
        width.priority = .init(999)
        cardConstraints = [
            card.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 4),
            card.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -4),
            width
        ]
        textTopToCard = textView.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 4)
        card.isHidden = true
    }

    /// Shows the card for the message's first link (or hides it). `onHeightChange` runs when an
    /// async load changes whether the card shows.
    func bind(messageText: String?, sent: Bool, onHeightChange: @escaping () -> Void) {
        card.onContentChanged = { [weak self] in
            self?.applyVisibility()
            onHeightChange()
        }
        card.bind(messageText: messageText, sent: sent)
        applyVisibility()
    }

    private func applyVisibility() {
        let show = !card.isHidden
        if show {
            textTopToBubble?.isActive = false
            NSLayoutConstraint.activate(cardConstraints + [textTopToCard!])
        } else {
            NSLayoutConstraint.deactivate(cardConstraints + [textTopToCard!])
            textTopToBubble?.isActive = true
        }
    }
}

extension UIView {
    /// Re-measures the table row this view sits in (async content changed its height).
    func relayoutEnclosingTableRow() {
        var v: UIView? = superview
        while let current = v, !(current is UITableView) { v = current.superview }
        guard let table = v as? UITableView else { return }
        UIView.performWithoutAnimation {
            table.beginUpdates()
            table.endUpdates()
        }
    }
}

// MARK: - Bot video cell (message_type 24)

/// Bot embedded video as a playable card in a received bubble, with the time below.
final class BotVideoCardCell: UITableViewCell {

    static let identifier = "BotVideoCardCell"

    private let bubble = UIView()
    private let card = LinkPreviewCardView()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        let colors = HippoConfig.shared.colorConfig
        bubble.backgroundColor = colors.hippoReceiver
        bubble.layer.cornerRadius = 12
        bubble.layer.borderWidth = 1
        bubble.layer.borderColor = colors.hippoBorder.cgColor
        bubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubble)
        card.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(card)
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = colors.hippoTextMuted
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubble.widthAnchor.constraint(equalToConstant: 280),
            card.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 4),
            card.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -4),
            timeLabel.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -6)
        ])
        card.fixedWidth = 272
        card.onContentChanged = { [weak self] in self?.relayoutEnclosingTableRow() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(message: HippoMessage) {
        card.bindVideo(link: message.customAction?.videoLink)
        timeLabel.text = changeDateToParticularFormat(message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
    }
}

// MARK: - Floating player

/// Plays a chat video (bot embedded video, or a video link preview) in a small window that floats
/// over the app and can be dragged to any corner, like WhatsApp's in-chat player.
///
/// YouTube links load just the YouTube player (any link shape), direct video files an HTML5
/// player, anything else the page itself. Chat cards show "Playing in picture in picture" for
/// the link playing; they listen for `didChange`.
final class HippoFloatingVideoPlayer: NSObject {

    static let shared = HippoFloatingVideoPlayer()
    static let didChange = Notification.Name("HippoFloatingVideoPlayerDidChange")

    private(set) var nowPlaying: String?
    private var container: UIView?
    private var webView: WKWebView?

    func isPlaying(_ url: String?) -> Bool {
        guard let url = url else { return false }
        return url == nowPlaying
    }

    func play(_ link: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first else { return }
        if container == nil {
            build(in: window)
        }
        guard let webView = webView else { return }
        let base = URL(string: "https://hippochat.io")
        if let yt = LinkMetaLoader.youtubeId(link) {
            let html = "<html><head><meta name='viewport' content='width=device-width,initial-scale=1'><style>html,body{margin:0;background:#000;height:100%}iframe{border:0;width:100%;height:100%}</style></head><body>"
                + "<iframe src='https://www.youtube.com/embed/\(yt)?autoplay=1&playsinline=1&rel=0&modestbranding=1' allow='autoplay; encrypted-media; picture-in-picture' allowfullscreen></iframe></body></html>"
            webView.loadHTMLString(html, baseURL: base)
        } else if LinkMetaLoader.isDirectVideo(link) {
            let safe = link.replacingOccurrences(of: "'", with: "%27")
            let html = "<html><head><meta name='viewport' content='width=device-width,initial-scale=1'><style>html,body{margin:0;background:#000;height:100%}video{width:100%;height:100%}</style></head><body>"
                + "<video src='\(safe)' autoplay playsinline controls></video></body></html>"
            webView.loadHTMLString(html, baseURL: base)
        } else if let u = URL(string: link) {
            webView.load(URLRequest(url: u))
        }
        nowPlaying = link
        window.bringSubviewToFront(container!)
        NotificationCenter.default.post(name: HippoFloatingVideoPlayer.didChange, object: nil)
    }

    func stop() {
        webView?.stopLoading()
        webView?.loadHTMLString("", baseURL: nil)
        container?.removeFromSuperview()
        container = nil
        webView = nil
        nowPlaying = nil
        NotificationCenter.default.post(name: HippoFloatingVideoPlayer.didChange, object: nil)
    }

    private func build(in window: UIWindow) {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        let web = WKWebView(frame: .zero, configuration: config)
        web.backgroundColor = .black
        web.isOpaque = false
        web.scrollView.isScrollEnabled = false

        let width = min(window.bounds.width - 32, 360)
        let height = width * 9 / 16
        let box = UIView(frame: CGRect(x: window.bounds.width - width - 16,
                                       y: window.safeAreaInsets.top + 60, width: width, height: height))
        box.backgroundColor = .black
        box.layer.cornerRadius = 12
        box.layer.shadowColor = UIColor.black.cgColor
        box.layer.shadowOpacity = 0.3
        box.layer.shadowRadius = 12
        box.layer.shadowOffset = CGSize(width: 0, height: 6)
        let clip = UIView(frame: box.bounds)
        clip.layer.cornerRadius = 12
        clip.clipsToBounds = true
        clip.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        box.addSubview(clip)
        web.frame = clip.bounds
        web.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clip.addSubview(web)

        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        close.tintColor = .white
        close.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        close.layer.cornerRadius = 14
        close.frame = CGRect(x: width - 34, y: 6, width: 28, height: 28)
        close.autoresizingMask = [.flexibleLeftMargin]
        close.accessibilityLabel = "Close"
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        box.addSubview(close)

        // Drag by a grab strip along the top so the player's own controls keep their touches.
        let grab = UIView(frame: CGRect(x: 0, y: 0, width: width - 40, height: 30))
        grab.autoresizingMask = [.flexibleWidth]
        grab.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragged(_:))))
        box.addSubview(grab)

        window.addSubview(box)
        container = box
        webView = web
    }

    @objc private func closeTapped() {
        stop()
    }

    /// Follows the finger, then snaps to the nearest corner inside the safe area.
    @objc private func dragged(_ g: UIPanGestureRecognizer) {
        guard let box = container, let window = box.superview else { return }
        let t = g.translation(in: window)
        box.center = CGPoint(x: box.center.x + t.x, y: box.center.y + t.y)
        g.setTranslation(.zero, in: window)
        guard g.state == .ended || g.state == .cancelled else { return }
        let insets = window.safeAreaInsets
        let left = insets.left + 16 + box.bounds.width / 2
        let right = window.bounds.width - insets.right - 16 - box.bounds.width / 2
        let top = insets.top + 16 + box.bounds.height / 2
        let bottom = window.bounds.height - insets.bottom - 90 - box.bounds.height / 2
        let target = CGPoint(x: box.center.x < window.bounds.midX ? left : right,
                             y: box.center.y < window.bounds.midY ? top : bottom)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: [], animations: {
            box.center = target
        })
    }
}
