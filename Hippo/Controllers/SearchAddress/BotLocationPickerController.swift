//
//  BotLocationPickerController.swift
//  Hippo
//
//  Location picker for a bot address question (design 12, without the live map): a search
//  field, "Use current location", nearby places with distances, and search results. One tap on
//  any row returns it; the chat sends it straight away.
//
//  Search uses the existing Jungleworks place search (SearchAdressVM), biased to the visitor's
//  position when known. The current address comes from CLGeocoder and the nearby list from
//  MapKit's points of interest around the visitor - no API key needed. Location access is asked
//  with the system prompt only; once it has been refused, the row opens the app's Settings.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

final class BotLocationPickerController: UIViewController {

    /// Called after the picker closes, with the place the visitor tapped.
    var onPick: ((Address) -> Void)?

    /// A row in the list.
    struct Place {
        let name: String
        let address: String
        let lat: Double
        let lng: Double
    }

    private static let searchDelay: TimeInterval = 0.5
    private static let minQuery = 3

    private let colors = HippoConfig.shared.colorConfig
    private let searchField = UITextField()
    private let clearButton = UIButton(type: .system)
    private let currentSub = UILabel()
    private let currentSpinner = UIActivityIndicatorView(style: .medium)
    private let sectionLabel = UILabel()
    private let emptyLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var nearbySearch: MKLocalSearch?
    private let searchVM = SearchAdressVM()

    private var here: CLLocation?
    private var currentPlace: Place?
    private var nearby: [Place] = []
    private var rows: [Place] = []
    /// The visitor tapped "Use current location" before we had it: send once it arrives.
    private var sendCurrentWhenReady = false
    private var fetching = false
    private var lastQuery = ""
    private var searchWork: DispatchWorkItem?

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.hippoSurface
        buildViews()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        searchVM.responseRecieved = { [weak self] in
            DispatchQueue.main.async { self?.searchFinished() }
        }

        if hasLocationPermission {
            fetchLocation()
        } else {
            currentSub.text = HippoStrings.locTapToAllow
        }
        showNearby()
    }

    deinit {
        nearbySearch?.cancel()
        geocoder.cancelGeocode()
        searchWork?.cancel()
    }

    // MARK: - Views

    private func buildViews() {
        // Top bar: back chevron + title.
        let bar = UIView()
        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        back.tintColor = colors.hippoTextPrimary
        back.addTarget(self, action: #selector(close), for: .touchUpInside)
        back.accessibilityLabel = HippoStrings.cancel
        let title = UILabel()
        title.text = HippoStrings.locSelect
        title.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        title.textColor = colors.hippoTextPrimary
        let barShadow = UIView()
        barShadow.backgroundColor = colors.hippoBorder

        // Search field.
        let searchBox = UIView()
        searchBox.backgroundColor = colors.hippoSurfaceInput
        searchBox.layer.cornerRadius = 12
        let searchIcon = UIImageView(image: BotLocationIcon.search(size: 20))
        searchIcon.tintColor = colors.hippoTextMuted
        searchIcon.contentMode = .scaleAspectFit
        searchField.font = UIFont.systemFont(ofSize: 15)
        searchField.textColor = colors.hippoTextPrimary
        searchField.attributedPlaceholder = NSAttributedString(string: HippoStrings.locSearchHint, attributes: [.foregroundColor: colors.hippoTextMuted])
        searchField.returnKeyType = .search
        searchField.autocapitalizationType = .words
        searchField.autocorrectionType = .no
        searchField.textContentType = .fullStreetAddress
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        clearButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)), for: .normal)
        clearButton.tintColor = colors.hippoTextMuted
        clearButton.isHidden = true
        clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)

        // "Use current location".
        let currentRow = UIControl()
        currentRow.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
        let currentIcon = BotLocationPickerController.roundIcon(image: BotLocationIcon.current(size: 20), tint: colors.hippoAccent, background: colors.hippoAccentSubtle)
        let currentTitle = UILabel()
        currentTitle.text = HippoStrings.locUseCurrent
        currentTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        currentTitle.textColor = colors.hippoAccent
        currentSub.font = UIFont.systemFont(ofSize: 13)
        currentSub.textColor = colors.hippoTextMuted
        currentSub.lineBreakMode = .byTruncatingTail
        currentSpinner.color = colors.hippoAccent
        currentSpinner.hidesWhenStopped = true
        let currentText = UIStackView(arrangedSubviews: [currentTitle, currentSub])
        currentText.axis = .vertical
        currentText.spacing = 2
        currentText.isUserInteractionEnabled = false
        let divider = UIView()
        divider.backgroundColor = colors.hippoBorder

        // "NEARBY" header and the empty / searching line.
        sectionLabel.text = HippoStrings.locNearby.uppercased()
        sectionLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        sectionLabel.textColor = colors.hippoTextMuted
        sectionLabel.isHidden = true
        emptyLabel.font = UIFont.systemFont(ofSize: 14)
        emptyLabel.textColor = colors.hippoTextMuted
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.contentInset.bottom = 16
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.identifier)

        for v in [bar, back, title, barShadow, searchBox, searchIcon, searchField, clearButton, currentRow, currentIcon, currentText, currentSpinner, divider, sectionLabel, tableView, emptyLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(bar)
        bar.addSubview(back)
        bar.addSubview(title)
        bar.addSubview(barShadow)
        view.addSubview(searchBox)
        searchBox.addSubview(searchIcon)
        searchBox.addSubview(searchField)
        searchBox.addSubview(clearButton)
        view.addSubview(currentRow)
        currentRow.addSubview(currentIcon)
        currentRow.addSubview(currentText)
        currentRow.addSubview(currentSpinner)
        view.addSubview(divider)
        view.addSubview(sectionLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: safe.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: 56),
            back.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 6),
            back.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 44),
            back.heightAnchor.constraint(equalToConstant: 44),
            title.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 4),
            title.trailingAnchor.constraint(lessThanOrEqualTo: bar.trailingAnchor, constant: -16),
            title.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            barShadow.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            barShadow.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            barShadow.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            barShadow.heightAnchor.constraint(equalToConstant: 0.5),

            searchBox.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 12),
            searchBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBox.heightAnchor.constraint(equalToConstant: 46),
            searchIcon.leadingAnchor.constraint(equalTo: searchBox.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: searchBox.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            searchField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 10),
            searchField.topAnchor.constraint(equalTo: searchBox.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchBox.bottomAnchor),
            clearButton.leadingAnchor.constraint(equalTo: searchField.trailingAnchor),
            clearButton.trailingAnchor.constraint(equalTo: searchBox.trailingAnchor, constant: -4),
            clearButton.centerYAnchor.constraint(equalTo: searchBox.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 38),
            clearButton.heightAnchor.constraint(equalToConstant: 38),

            currentRow.topAnchor.constraint(equalTo: searchBox.bottomAnchor, constant: 6),
            currentRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currentRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
            currentIcon.leadingAnchor.constraint(equalTo: currentRow.leadingAnchor, constant: 16),
            currentIcon.centerYAnchor.constraint(equalTo: currentRow.centerYAnchor),
            currentText.leadingAnchor.constraint(equalTo: currentIcon.trailingAnchor, constant: 14),
            currentText.topAnchor.constraint(equalTo: currentRow.topAnchor, constant: 12),
            currentText.bottomAnchor.constraint(equalTo: currentRow.bottomAnchor, constant: -12),
            currentSpinner.leadingAnchor.constraint(equalTo: currentText.trailingAnchor, constant: 8),
            currentSpinner.trailingAnchor.constraint(equalTo: currentRow.trailingAnchor, constant: -16),
            currentSpinner.centerYAnchor.constraint(equalTo: currentRow.centerYAnchor),

            divider.topAnchor.constraint(equalTo: currentRow.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            sectionLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            sectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 32),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        currentSpinner.setContentHuggingPriority(.required, for: .horizontal)
        // The list starts right under the divider, or under the "Nearby" header when it shows.
        listTop = tableView.topAnchor.constraint(equalTo: divider.bottomAnchor)
        listTopUnderHeader = tableView.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 4)
        setListUnderHeader(false)
    }

    private var listTop: NSLayoutConstraint?
    private var listTopUnderHeader: NSLayoutConstraint?

    private func setListUnderHeader(_ underHeader: Bool) {
        sectionLabel.isHidden = !underHeader
        if underHeader {
            listTop?.isActive = false
            listTopUnderHeader?.isActive = true
        } else {
            listTopUnderHeader?.isActive = false
            listTop?.isActive = true
        }
    }

    /// 40pt circle with an icon in it, as in the design's row icons.
    static func roundIcon(image: UIImage, tint: UIColor, background: UIColor) -> UIView {
        let circle = UIView()
        circle.backgroundColor = background
        circle.layer.cornerRadius = 20
        let icon = UIImageView(image: image)
        icon.tintColor = tint
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(icon)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 40),
            circle.heightAnchor.constraint(equalToConstant: 40),
            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        return circle
    }

    @objc private func close() {
        view.endEditing(true)
        dismiss(animated: true)
    }

    // MARK: - Current location

    private var authorization: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }

    private var hasLocationPermission: Bool {
        return authorization == .authorizedWhenInUse || authorization == .authorizedAlways
    }

    @objc private func currentLocationTapped() {
        if let place = currentPlace {
            send(place)
            return
        }
        sendCurrentWhenReady = true
        switch authorization {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // The system no longer shows its prompt: the only way back is the app's settings.
            sendCurrentWhenReady = false
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        default:
            if !fetching { fetchLocation() }
        }
    }

    private func fetchLocation() {
        guard hasLocationPermission else { return }
        fetching = true
        currentSpinner.startAnimating()
        currentSub.text = HippoStrings.locFinding
        // A recent cached fix is instant; otherwise ask for a fresh one.
        if let cached = locationManager.location, Date().timeIntervalSince(cached.timestamp) < 120 {
            onLocation(cached)
        } else {
            locationManager.requestLocation()
        }
    }

    private func onLocation(_ location: CLLocation?) {
        guard let location = location else {
            fetching = false
            currentSpinner.stopAnimating()
            currentSub.text = HippoStrings.locUnavailable
            sendCurrentWhenReady = false
            return
        }
        here = location
        searchVM.bias = (location.coordinate.latitude, location.coordinate.longitude)
        let lat = location.coordinate.latitude, lng = location.coordinate.longitude
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self = self else { return }
            let current = placemarks?.first.flatMap { BotLocationPickerController.place(from: $0, lat: lat, lng: lng) }
                ?? Place(name: BotLocationPickerController.coordinates(lat, lng), address: BotLocationPickerController.coordinates(lat, lng), lat: lat, lng: lng)
            self.fetching = false
            self.currentSpinner.stopAnimating()
            self.currentPlace = current
            self.currentSub.text = current.address
            if self.sendCurrentWhenReady {
                self.sendCurrentWhenReady = false
                self.send(current)
                return
            }
            self.loadNearby(around: location, excluding: current)
        }
    }

    /// Points of interest around the visitor, nearest first.
    private func loadNearby(around location: CLLocation, excluding current: Place) {
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 600)
        let search = MKLocalSearch(request: request)
        nearbySearch = search
        search.start { [weak self] response, _ in
            guard let self = self else { return }
            var seen: Set<String> = [current.address]
            var places: [Place] = []
            for item in response?.mapItems ?? [] {
                let c = item.placemark.coordinate
                guard var p = BotLocationPickerController.place(from: item.placemark, lat: c.latitude, lng: c.longitude) else { continue }
                if let name = item.name, !name.isEmpty {
                    p = Place(name: name, address: p.address, lat: p.lat, lng: p.lng)
                }
                if seen.insert(p.name + "|" + p.address).inserted { places.append(p) }
            }
            places.sort { self.distance(to: $0) < self.distance(to: $1) }
            self.nearby = Array(places.prefix(12))
            if (self.searchField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty {
                self.showNearby()
            }
        }
    }

    // MARK: - Search

    @objc private func searchChanged() {
        let q = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        clearButton.isHidden = q.isEmpty
        searchWork?.cancel()
        if q.isEmpty {
            lastQuery = ""
            showNearby()
        } else if q.count >= BotLocationPickerController.minQuery {
            let work = DispatchWorkItem { [weak self] in self?.runSearch() }
            searchWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + BotLocationPickerController.searchDelay, execute: work)
        }
    }

    @objc private func clearSearch() {
        searchField.text = ""
        searchChanged()
    }

    private func runSearch() {
        let q = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= BotLocationPickerController.minQuery, q.caseInsensitiveCompare(lastQuery) != .orderedSame else { return }
        lastQuery = q
        setListUnderHeader(false)
        emptyLabel.text = HippoStrings.locSearching
        emptyLabel.isHidden = !rows.isEmpty
        searchVM.searchText = q
    }

    private func searchFinished() {
        let q = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        // Stale answer, or the field was cleared meanwhile.
        guard !q.isEmpty, q.caseInsensitiveCompare(lastQuery) == .orderedSame else { return }
        var places: [Place] = []
        for i in 0..<searchVM.getAddressCount() {
            let a = searchVM.getaddress(indexPath: i)
            guard let address = a.address, !address.isEmpty else { continue }
            places.append(Place(name: a.name ?? "", address: address, lat: a.lat ?? 0, lng: a.lng ?? 0))
        }
        rows = places
        tableView.reloadData()
        emptyLabel.text = HippoStrings.locNoResults
        emptyLabel.isHidden = !places.isEmpty
    }

    /// Empty search: the nearby list, only when location is on and something was found.
    private func showNearby() {
        emptyLabel.isHidden = true
        rows = nearby
        setListUnderHeader(!nearby.isEmpty)
        tableView.reloadData()
    }

    // MARK: - Result

    private func send(_ place: Place) {
        view.endEditing(true)
        var address = Address()
        address.address = place.address
        address.name = place.name
        address.lat = place.lat
        address.lng = place.lng
        let onPick = self.onPick
        dismiss(animated: true) {
            onPick?(address)
        }
    }

    // MARK: - Helpers

    private func distance(to place: Place) -> CLLocationDistance {
        guard let here = here else { return .greatestFiniteMagnitude }
        return here.distance(from: CLLocation(latitude: place.lat, longitude: place.lng))
    }

    /// "120 m", "1.2 km", "11 km"; empty when the visitor's position is unknown or the place is right there.
    fileprivate func distanceText(_ place: Place) -> String {
        guard here != nil, !(place.lat == 0 && place.lng == 0) else { return "" }
        let m = distance(to: place)
        // Same building / spot: "0 m" says nothing, so no distance.
        if m < 10 { return "" }
        if m < 1000 { return "\(Int((m / 10).rounded()) * 10) m" }
        if m < 10_000 { return String(format: "%.1f km", m / 1000) }
        return "\(Int((m / 1000).rounded())) km"
    }

    static func coordinates(_ lat: Double, _ lng: Double) -> String {
        return String(format: "%.5f, %.5f", locale: Locale(identifier: "en_US_POSIX"), lat, lng)
    }

    /// Name + one-line address of a placemark. A bare house number is a poor name, so the
    /// street / area is used then.
    static func place(from placemark: CLPlacemark, lat: Double, lng: Double) -> Place? {
        var line = ""
        if let postal = placemark.postalAddress {
            line = CNPostalAddressFormatter.string(from: postal, style: .mailingAddress)
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        }
        if line.isEmpty {
            line = [placemark.name, placemark.subLocality, placemark.locality, placemark.administrativeArea, placemark.country]
                .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        }
        guard !line.isEmpty else { return nil }
        var name = placemark.name ?? ""
        if name.isEmpty || name.range(of: "^[\\d\\-/ ]+$", options: .regularExpression) != nil {
            name = [placemark.thoroughfare, placemark.subLocality, placemark.locality].compactMap { $0 }.first { !$0.isEmpty } ?? line
        }
        return Place(name: name, address: line, lat: lat, lng: lng)
    }
}

// MARK: - CLLocationManagerDelegate

extension BotLocationPickerController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if hasLocationPermission {
            // Allowing turns location on and shows nearby places; it doesn't send by itself.
            sendCurrentWhenReady = false
            if currentPlace == nil, !fetching { fetchLocation() }
        } else if authorization == .denied || authorization == .restricted {
            sendCurrentWhenReady = false
            fetching = false
            currentSpinner.stopAnimating()
            currentSub.text = HippoStrings.locTapToAllow
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard fetching, here == nil else { return }
        onLocation(locations.last)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard fetching, here == nil else { return }
        onLocation(manager.location)
    }
}

// MARK: - Search field

extension BotLocationPickerController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchWork?.cancel()
        runSearch()
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - List

extension BotLocationPickerController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier, for: indexPath) as! PlaceCell
        let p = rows[indexPath.row]
        let title = !p.name.isEmpty ? p.name : (p.address.components(separatedBy: ",").first ?? p.address)
        let dist = distanceText(p)
        // Distance first: long addresses would otherwise cut it off.
        cell.set(name: title, detail: dist.isEmpty ? p.address : dist + " · " + p.address)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        send(rows[indexPath.row])
    }

    /// One place: pin, name, distance · address.
    final class PlaceCell: UITableViewCell {
        static let identifier = "BotLocationPlaceCell"
        private let nameLabel = UILabel()
        private let detailLabel = UILabel()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            let colors = HippoConfig.shared.colorConfig
            backgroundColor = .clear
            let selected = UIView()
            selected.backgroundColor = colors.hippoSurfaceInput
            selectedBackgroundView = selected
            let icon = BotLocationPickerController.roundIcon(image: BotLocationIcon.pin(size: 18), tint: colors.hippoTextMuted, background: colors.hippoSurfaceInput)
            nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            nameLabel.textColor = colors.hippoTextPrimary
            detailLabel.font = UIFont.systemFont(ofSize: 13)
            detailLabel.textColor = colors.hippoTextMuted
            let text = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
            text.axis = .vertical
            text.spacing = 2
            icon.translatesAutoresizingMaskIntoConstraints = false
            text.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(icon)
            contentView.addSubview(text)
            let minHeight = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
            minHeight.priority = .init(999)
            NSLayoutConstraint.activate([
                minHeight,
                icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                text.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14),
                text.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                text.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func set(name: String, detail: String) {
            nameLabel.text = name
            detailLabel.text = detail
        }
    }
}

// MARK: - Icons

/// The location icons from the Android SDK (hippo_ic_loc_pin / _current / _search), drawn from
/// the same 24×24 outline paths. Template images: tint them like any other icon.
enum BotLocationIcon {

    /// Outlined teardrop pin with a hollow centre.
    static func pin(size: CGFloat) -> UIImage {
        return draw(size: size, lineWidth: 1.9) { p in
            p.move(to: CGPoint(x: 12, y: 21))
            p.addCurve(to: CGPoint(x: 5.5, y: 10), controlPoint1: CGPoint(x: 12, y: 21), controlPoint2: CGPoint(x: 5.5, y: 15.4))
            p.addArc(withCenter: CGPoint(x: 12, y: 10), radius: 6.5, startAngle: .pi, endAngle: 0, clockwise: true)
            p.addCurve(to: CGPoint(x: 12, y: 21), controlPoint1: CGPoint(x: 18.5, y: 15.4), controlPoint2: CGPoint(x: 12, y: 21))
            p.close()
            p.append(UIBezierPath(arcCenter: CGPoint(x: 12, y: 10), radius: 2.5, startAngle: 0, endAngle: .pi * 2, clockwise: true))
        }
    }

    /// Crosshair: "Use current location".
    static func current(size: CGFloat) -> UIImage {
        return draw(size: size, lineWidth: 2) { p in
            p.append(UIBezierPath(arcCenter: CGPoint(x: 12, y: 12), radius: 7, startAngle: 0, endAngle: .pi * 2, clockwise: true))
            p.append(UIBezierPath(arcCenter: CGPoint(x: 12, y: 12), radius: 2.5, startAngle: 0, endAngle: .pi * 2, clockwise: true))
            for (a, b) in [((12, 2), (12, 5)), ((12, 19), (12, 22)), ((2, 12), (5, 12)), ((19, 12), (22, 12))] {
                p.move(to: CGPoint(x: a.0, y: a.1))
                p.addLine(to: CGPoint(x: b.0, y: b.1))
            }
        }
    }

    /// Magnifier for the search field.
    static func search(size: CGFloat) -> UIImage {
        return draw(size: size, lineWidth: 2) { p in
            p.append(UIBezierPath(arcCenter: CGPoint(x: 11, y: 11), radius: 7, startAngle: 0, endAngle: .pi * 2, clockwise: true))
            p.move(to: CGPoint(x: 16.5, y: 16.5))
            p.addLine(to: CGPoint(x: 20, y: 20))
        }
    }

    private static func draw(size: CGFloat, lineWidth: CGFloat, build: (UIBezierPath) -> Void) -> UIImage {
        let image = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            let path = UIBezierPath()
            build(path)
            path.apply(CGAffineTransform(scaleX: size / 24, y: size / 24))
            path.lineWidth = lineWidth * size / 24
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            UIColor.black.setStroke()
            path.stroke()
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}
