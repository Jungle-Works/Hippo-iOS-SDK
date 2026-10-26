//
//  BotAddressAnswerCell.swift
//  Hippo
//
//  The customer's answer to a bot address question (message_type 25), drawn as a sent bubble:
//  a map of the spot when the answer has coordinates, then the place name in bold with the full
//  address below, and the time + tick at the bottom right. Without coordinates a pin tile sits
//  before the text instead of the map. Tapping opens Maps at the spot (or searches the address).
//
//  The map is an Apple Maps snapshot (no key needed), so the bubble's height is known up front:
//  the chat sizes this row from `BotAddressAnswerCell.height(for:)`.
//

import UIKit
import MapKit

final class BotAddressAnswerCell: UITableViewCell {

    static let identifier = "BotAddressAnswerCell"

    /// What the bubble shows.
    struct Answer {
        let name: String
        let rest: String
        let address: String
        let lat: Double?
        let lng: Double?

        var hasCoordinates: Bool {
            guard let lat = lat, let lng = lng else { return false }
            return !(lat == 0 && lng == 0)
        }

        /// From the question's content_value (address, latitude, longitude).
        init(message: HippoActionMessage) {
            let dic = message.contentValues.first ?? [:]
            let address = ((dic["address"] as? String) ?? message.responseMessage?.message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            self.address = address
            lat = BotAddressAnswerCell.double(dic["latitude"])
            lng = BotAddressAnswerCell.double(dic["longitude"])
            // Title = first part; a bare house number ("155") reads badly alone, so join the next.
            let parts = address.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            let titleParts = parts.count > 1 && parts[0].range(of: "^[\\d\\-/ ]{1,6}$", options: .regularExpression) != nil ? 2 : 1
            name = parts.isEmpty ? address : parts.prefix(titleParts).joined(separator: ", ")
            rest = parts.count > titleParts ? parts.suffix(from: titleParts).joined(separator: ", ") : ""
        }
    }

    // MARK: Metrics (shared by layout and height)

    private static let hPad: CGFloat = 12
    private static let topPad: CGFloat = 10
    private static let bottomPad: CGFloat = 7
    private static let mapInset: CGFloat = 4
    private static let mapHeight: CGFloat = 140
    private static let tileSize: CGFloat = 36
    private static let tileGap: CGFloat = 10
    private static let timeGap: CGFloat = 4
    private static let timeHeight: CGFloat = 14
    private static let rowVPad: CGFloat = 3
    private static let trailing: CGFloat = 10

    private static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    private static var mapWidth: CGFloat { (min(screenWidth * 0.72, 300) - mapInset * 2).rounded() }
    private static var maxBubbleWidth: CGFloat { min(screenWidth * 0.75, 320).rounded() }

    private static func text(for answer: Answer) -> NSAttributedString {
        let size = HippoConfig.shared.theme.inOutChatTextFont.pointSize
        let onAccent = HippoConfig.shared.colorConfig.hippoOnAccent
        let s = NSMutableAttributedString(string: answer.name, attributes: [
            .font: UIFont.systemFont(ofSize: size, weight: .semibold),
            .foregroundColor: onAccent
        ])
        if !answer.rest.isEmpty {
            let para = NSMutableParagraphStyle()
            para.paragraphSpacingBefore = 2
            s.append(NSAttributedString(string: "\n" + answer.rest, attributes: [
                .font: UIFont.systemFont(ofSize: (size * 0.88).rounded()),
                .foregroundColor: onAccent.withAlphaComponent(0.8),
                .paragraphStyle: para
            ]))
        }
        return s
    }

    private struct Frames {
        var bubble: CGSize
        var map: CGRect?
        var tile: CGRect?
        var text: CGRect
        var time: CGRect
    }

    private static func frames(for answer: Answer, timeWidth: CGFloat) -> Frames {
        let hasMap = answer.hasCoordinates
        let tileSpace = hasMap ? 0 : tileSize + tileGap
        let maxContent = (hasMap ? mapWidth + mapInset * 2 : maxBubbleWidth) - hPad * 2
        let maxText = max(40, maxContent - tileSpace)
        let measured = text(for: answer).boundingRect(with: CGSize(width: maxText, height: .greatestFiniteMagnitude),
                                                       options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let textSize = CGSize(width: ceil(min(measured.width, maxText)), height: ceil(measured.height))
        let bubbleWidth: CGFloat
        if hasMap {
            bubbleWidth = mapWidth + mapInset * 2
        } else {
            bubbleWidth = max(textSize.width + tileSpace, timeWidth) + hPad * 2
        }
        var y: CGFloat = hasMap ? mapInset : topPad
        var map: CGRect?
        if hasMap {
            map = CGRect(x: mapInset, y: y, width: mapWidth, height: mapHeight)
            y += mapHeight + 8
        }
        let rowHeight = max(textSize.height, hasMap ? 0 : tileSize)
        let tile: CGRect? = hasMap ? nil : CGRect(x: hPad, y: y + (rowHeight - tileSize) / 2, width: tileSize, height: tileSize)
        let textRect = CGRect(x: hPad + tileSpace, y: y + (rowHeight - textSize.height) / 2, width: textSize.width, height: textSize.height)
        y += rowHeight + timeGap
        let time = CGRect(x: bubbleWidth - hPad - timeWidth, y: y, width: timeWidth, height: timeHeight)
        y += timeHeight + bottomPad
        return Frames(bubble: CGSize(width: bubbleWidth, height: y), map: map, tile: tile, text: textRect, time: time)
    }

    private static let statusSize: CGFloat = 14
    private static let timeFont = UIFont.systemFont(ofSize: 11)

    private static func timeWidth(_ time: String) -> CGFloat {
        let w = (time as NSString).size(withAttributes: [.font: timeFont]).width
        return ceil(w) + 4 + statusSize
    }

    /// Row height for the answer of this address question.
    static func height(for message: HippoActionMessage) -> CGFloat {
        let time = changeDateToParticularFormat(message.responseMessage?.creationDateTime ?? message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        return frames(for: Answer(message: message), timeWidth: timeWidth(time)).bubble.height + rowVPad * 2
    }

    // MARK: Views

    private let bubble = UIView()
    private let mapView = UIImageView()
    private let tile = UIImageView()
    private let label = UILabel()
    private let timeLabel = UILabel()
    private let statusView = UIImageView()
    private var answer: Answer?
    private var snapshotKey: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        let colors = HippoConfig.shared.colorConfig
        bubble.backgroundColor = colors.hippoAccent
        mapView.contentMode = .scaleAspectFill
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 8
        mapView.backgroundColor = colors.hippoOnAccent.withAlphaComponent(0.15)
        tile.image = BotLocationIcon.pin(size: 18)
        tile.contentMode = .center
        tile.tintColor = colors.hippoOnAccent
        tile.backgroundColor = colors.hippoOnAccent.withAlphaComponent(0.2)
        tile.layer.cornerRadius = 12
        label.numberOfLines = 0
        timeLabel.font = BotAddressAnswerCell.timeFont
        timeLabel.textColor = colors.hippoOnAccent
        timeLabel.textAlignment = .right
        statusView.contentMode = .scaleAspectFit
        statusView.tintColor = colors.hippoOnAccent
        contentView.addSubview(bubble)
        [mapView, tile, label, timeLabel, statusView].forEach { bubble.addSubview($0) }
        bubble.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMaps)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(message: HippoActionMessage) {
        let answer = Answer(message: message)
        self.answer = answer
        label.attributedText = BotAddressAnswerCell.text(for: answer)
        let response = message.responseMessage
        timeLabel.text = changeDateToParticularFormat(response?.creationDateTime ?? message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        statusView.image = (response?.status ?? message.status).getIcon()?.withRenderingMode(.alwaysTemplate)
        mapView.isHidden = !answer.hasCoordinates
        tile.isHidden = answer.hasCoordinates
        if answer.hasCoordinates, let lat = answer.lat, let lng = answer.lng {
            loadMap(lat: lat, lng: lng)
        } else {
            snapshotKey = nil
            mapView.image = nil
        }
        accessibilityLabel = answer.address
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let answer = answer else { return }
        let time = timeLabel.text ?? ""
        let f = BotAddressAnswerCell.frames(for: answer, timeWidth: BotAddressAnswerCell.timeWidth(time))
        bubble.frame = CGRect(x: contentView.bounds.width - BotAddressAnswerCell.trailing - f.bubble.width,
                              y: BotAddressAnswerCell.rowVPad, width: f.bubble.width, height: f.bubble.height)
        if let map = f.map { mapView.frame = map }
        if let t = f.tile { tile.frame = t }
        label.frame = f.text
        let statusSize = BotAddressAnswerCell.statusSize
        statusView.frame = CGRect(x: f.time.maxX - statusSize, y: f.time.midY - statusSize / 2, width: statusSize, height: statusSize)
        timeLabel.frame = CGRect(x: f.time.minX, y: f.time.minY, width: f.time.width - statusSize - 4, height: f.time.height)
        bubble.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 5)
    }

    // MARK: Map

    private static let snapshots = NSCache<NSString, UIImage>()

    private func loadMap(lat: Double, lng: Double) {
        let size = CGSize(width: BotAddressAnswerCell.mapWidth, height: BotAddressAnswerCell.mapHeight)
        let dark = traitCollection.userInterfaceStyle == .dark
        let key = "\(lat),\(lng),\(Int(size.width)),\(dark)"
        snapshotKey = key
        if let cached = BotAddressAnswerCell.snapshots.object(forKey: key as NSString) {
            mapView.image = cached
            return
        }
        mapView.image = nil
        let options = MKMapSnapshotter.Options()
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        options.region = MKCoordinateRegion(center: center, latitudinalMeters: 600, longitudinalMeters: 600)
        options.size = size
        options.traitCollection = UITraitCollection(traitsFrom: [UITraitCollection(displayScale: UIScreen.main.scale),
                                                                 UITraitCollection(userInterfaceStyle: dark ? .dark : .light)])
        options.pointOfInterestFilter = .includingAll
        MKMapSnapshotter(options: options).start(with: .global(qos: .userInitiated)) { [weak self] snapshot, _ in
            guard let snapshot = snapshot else { return }
            let image = BotAddressAnswerCell.drawPin(on: snapshot.image, at: snapshot.point(for: center))
            BotAddressAnswerCell.snapshots.setObject(image, forKey: key as NSString)
            DispatchQueue.main.async {
                guard let self = self, self.snapshotKey == key else { return }
                self.mapView.image = image
            }
        }
    }

    /// The map with a red pin whose tip sits on the spot.
    private static func drawPin(on map: UIImage, at point: CGPoint) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: map.size, format: {
            let f = UIGraphicsImageRendererFormat()
            f.scale = map.scale
            return f
        }())
        return renderer.image { _ in
            map.draw(at: .zero)
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
            guard let pin = UIImage(systemName: "mappin.circle.fill", withConfiguration: config)?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                  let stem = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal) else { return }
            let stemRect = CGRect(x: point.x - stem.size.width / 2, y: point.y - stem.size.height, width: stem.size.width, height: stem.size.height)
            let pinRect = CGRect(x: point.x - pin.size.width / 2, y: stemRect.minY - pin.size.height + 3, width: pin.size.width, height: pin.size.height)
            UIColor.white.setFill()
            UIBezierPath(ovalIn: pinRect.insetBy(dx: 2, dy: 2)).fill()
            stem.draw(in: stemRect)
            pin.draw(in: pinRect)
        }
    }

    // MARK: Tap

    @objc private func openMaps() {
        guard let answer = answer else { return }
        var components = URLComponents(string: "https://maps.apple.com/")!
        if answer.hasCoordinates, let lat = answer.lat, let lng = answer.lng {
            components.queryItems = [URLQueryItem(name: "ll", value: "\(lat),\(lng)"), URLQueryItem(name: "q", value: answer.name)]
        } else {
            components.queryItems = [URLQueryItem(name: "q", value: answer.address)]
        }
        if let url = components.url {
            UIApplication.shared.open(url)
        }
    }

    // MARK: Helpers

    fileprivate static func double(_ value: Any?) -> Double? {
        switch value {
        case let d as Double: return d
        case let n as NSNumber: return n.doubleValue
        case let s as String: return Double(s.trimmingCharacters(in: .whitespaces))
        default: return nil
        }
    }
}
