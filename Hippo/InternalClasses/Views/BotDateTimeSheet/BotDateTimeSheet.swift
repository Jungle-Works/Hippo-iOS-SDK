//
//  BotDateTimeSheet.swift
//  Hippo
//
//  Bottom sheet that answers a bot date/time question (bot_response_type 18 / 19 / 20).
//

import UIKit

/// What a bot date/time question asks for, read from its custom action:
///
///     bot_response_type "18" -> date_scroller  (date; a format with no day token = month & year)
///     bot_response_type "19" -> time_scroller  (time; fields follow the format: HH:mm, HH:mm:ss, mm:ss)
///     bot_response_type "20" -> calendar_time  (date + time)
///
/// date_time_format is a moment.js-style pattern ("YYYY-MM-DD HH:mm:ss") or "milliseconds";
/// allowed_date_time is 0 = any, 1 = future only, 2 = past only. The format is applied only to
/// the value that is sent - the sheet itself always shows a readable date.
struct BotDateTimeSpec {

    enum Mode { case date, time, dateTime, month }

    let mode: Mode
    /// The raw format from the bot, never empty.
    let format: String
    let allowed: AllowedDateTimeType
    let hasHours: Bool
    let hasMinutes: Bool
    let hasSeconds: Bool

    init(message: HippoMessage?) {
        self.init(action: message?.actionableMessage)
    }

    init(action: FuguActionableMessage?) {
        let raw = (action?.dateTimeFormat ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        allowed = action?.allowedDateTime ?? .all
        switch action?.botResponseType {
        case .time?:
            mode = .time
            format = raw.isEmpty ? "HH:mm" : raw
        case .dateTime?:
            mode = .dateTime
            format = raw.isEmpty ? "YYYY-MM-DD HH:mm" : raw
        default:
            let f = raw.isEmpty ? "YYYY-MM-DD" : raw
            format = f
            let isMs = f.lowercased() == "milliseconds"
            mode = !isMs && !f.contains("D") && !f.contains("d") && f.contains("M") ? .month : .date
        }
        if mode == .time && format.lowercased() != "milliseconds" {
            var h = format.contains("H") || format.contains("h")
            var m = format.contains("m")
            let s = format.contains("s")
            if !h && !m && !s {
                h = true
                m = true
            }
            hasHours = h
            hasMinutes = m
            hasSeconds = s
        } else {
            hasHours = true
            hasMinutes = true
            hasSeconds = false
        }
    }

    var isMilliseconds: Bool {
        return format.lowercased() == "milliseconds"
    }

    var hasCalendar: Bool {
        return mode == .date || mode == .dateTime
    }

    /// The value to send, in the bot's format.
    func formatValue(_ date: Date) -> String {
        if isMilliseconds {
            return String(Int64(date.timeIntervalSince1970 * 1000))
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        // A date-only question answers with the date alone: a "YYYY-MM-DD HH:mm:ss" format
        // would otherwise send "2026-10-16 00:00:00".
        let pattern = mode == .date || mode == .month ? BotDateTimeSpec.dateOnly(format) : format
        formatter.dateFormat = BotDateTimeSpec.toApplePattern(pattern)
        let value = formatter.string(from: date)
        if !value.isEmpty {
            return value
        }
        // A pattern we could not translate: fall back to an unambiguous ISO-style value.
        formatter.dateFormat = mode == .time ? "HH:mm:ss" : mode == .dateTime ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// The moment.js pattern without its time part: time tokens (H h m s S A a Z) are dropped,
    /// along with separators and literals that no longer sit between two date tokens
    /// ("YYYY-MM-DD HH:mm:ss" -> "YYYY-MM-DD", "DD/MM/YYYY[T]HH:mm" -> "DD/MM/YYYY").
    /// A pattern with no date token left is returned unchanged.
    static func dateOnly(_ moment: String) -> String {
        enum Kind { case date, time, literal }
        var segments: [(text: String, kind: Kind)] = []
        let chars = Array(moment)
        let n = chars.count
        var i = 0
        while i < n {
            let c = chars[i]
            if c == "[" {
                var end = i + 1
                while end < n && chars[end] != "]" { end += 1 }
                segments.append((String(chars[i..<min(n, end + 1)]), .literal))
                i = min(n, end + 1)
                continue
            }
            if !c.isLetter {
                segments.append((String(c), .literal))
                i += 1
                continue
            }
            var j = i
            while j < n && chars[j] == c { j += 1 }
            if c == "D" && j - i == 1 && j < n && chars[j] == "o" { j += 1 } // "Do"
            let kind: Kind
            switch c {
            case "Y", "y", "M", "D", "d": kind = .date
            case "H", "h", "m", "s", "S", "A", "a", "Z": kind = .time
            default: kind = .literal
            }
            segments.append((String(chars[i..<j]), kind))
            i = j
        }
        guard segments.contains(where: { $0.kind == .date }) else { return moment }
        // Keep date tokens, plus the literals between two of them with no time token in
        // between, and the leading literals when no time token comes before the first date.
        var out = ""
        var between = ""
        var broken = false
        for seg in segments {
            switch seg.kind {
            case .date:
                if !broken { out += between }
                between = ""
                broken = false
                out += seg.text
            case .time:
                broken = true
            case .literal:
                between += seg.text
            }
        }
        return out
    }

    /// Translates a moment.js-style pattern into a DateFormatter one. The two disagree on the
    /// common tokens (moment "YYYY"/"DD" are Apple's week-year/day-of-year), so this is a
    /// token-by-token map rather than a blanket replace. Unknown letters become quoted literals.
    static func toApplePattern(_ moment: String) -> String {
        let chars = Array(moment)
        var out = ""
        var i = 0
        let n = chars.count
        while i < n {
            let c = chars[i]
            if c == "[" {
                var end = i + 1
                while end < n && chars[end] != "]" { end += 1 }
                appendLiteral(&out, String(chars[min(i + 1, n)..<end]))
                i = min(n, end + 1)
                continue
            }
            if !c.isLetter {
                out += c == "'" ? "''" : String(c)
                i += 1
                continue
            }
            var j = i
            while j < n && chars[j] == c { j += 1 }
            let len = j - i
            // "Do" = day of month with ordinal; DateFormatter has no ordinal, use the plain day.
            if c == "D" && len == 1 && j < n && chars[j] == "o" {
                out += "d"
                i = j + 1
                continue
            }
            if let mapped = mapToken(c, len) {
                out += mapped
            } else {
                appendLiteral(&out, String(chars[i..<j]))
            }
            i = j
        }
        return out
    }

    private static func mapToken(_ c: Character, _ len: Int) -> String? {
        switch c {
        case "Y", "y": return len == 2 ? "yy" : "yyyy"
        case "M": return String(repeating: "M", count: min(len, 4))
        case "D": return len >= 2 ? "dd" : "d"
        case "d":
            if len >= 4 { return "EEEE" }
            if len == 3 { return "EEE" }
            return nil // moment "d"/"dd" = weekday number/min name: no equivalent
        case "H": return len >= 2 ? "HH" : "H"
        case "h": return len >= 2 ? "hh" : "h"
        case "m": return len >= 2 ? "mm" : "m"
        case "s": return len >= 2 ? "ss" : "s"
        case "S": return String(repeating: "S", count: min(len, 3))
        case "A", "a": return "a"
        case "Z": return len >= 2 ? "xx" : "xxx"
        default: return nil
        }
    }

    private static func appendLiteral(_ out: inout String, _ text: String) {
        guard !text.isEmpty else { return }
        out += "'" + text.replacingOccurrences(of: "'", with: "''") + "'"
    }
}

protocol BotDateTimeSheetDelegate: AnyObject {
    /// - Parameter value: the answer in the bot's format, ready to send.
    func botDateTimePicked(_ value: String)
}

/// Bottom sheet that answers a bot date/time question.
///
/// - Date: calendar; the month title opens a month & year wheel.
/// - Date & time: calendar plus a 24-hour time row (type, or nudge with the arrows); the sheet
///   lifts above the keypad while typing.
/// - Time: one wheel per field in the bot's format (HH:mm, HH:mm:ss, mm:ss).
/// - Month: the month & year wheel on its own.
///
/// Confirm stays disabled until the answer is complete and allowed, then hands the value - in
/// the bot's format - to the delegate.
final class BotDateTimeSheet: UIViewController {

    private enum TimeField { case hour, minute, second }

    private static let yearsBack = 100
    private static let yearsAhead = 20

    weak var delegate: BotDateTimeSheetDelegate?

    private let spec: BotDateTimeSpec
    private let colors = HippoConfig.shared.colorConfig
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = Calendar.current.firstWeekday
        return c
    }()

    // Answer state (month is 1...12)
    private var selY = -1, selM = -1, selD = -1
    private var viewY = 0, viewM = 0
    private var hour = 0, minute = 0, second = 0
    private var monthYearOpen = false
    private let yearFrom: Int
    private let yearTo: Int
    private var timeFields: [TimeField] = []
    private var isRewritingTimeField = false

    // Views
    private let dimView = UIView()
    private let card = UIView()
    private var cardBottom: NSLayoutConstraint!
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let selectedValueLabel = UILabel()
    private let calendarHeader = UIView()
    private let monthPill = UIButton(type: .custom)
    private let monthLabel = UILabel()
    private let monthChevron = UIImageView()
    private let monthNav = UIStackView()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let calendarGrid = BotCalendarGridView()
    private let monthYearSection = UIStackView()
    private let monthYearPicker = UIPickerView()
    private let timeRowSection = UIStackView()
    private let hourBox = BotTimeBox()
    private let minuteBox = BotTimeBox()
    private let timeErrorLabel = UILabel()
    private let timeWheelSection = UIStackView()
    private let timePicker = UIPickerView()
    private let confirmButton = UIButton(type: .custom)

    init(spec: BotDateTimeSpec) {
        self.spec = spec
        let now = Date()
        let cal = Calendar(identifier: .gregorian)
        let thisYear = cal.component(.year, from: now)
        yearFrom = spec.allowed == .future ? thisYear : thisYear - BotDateTimeSheet.yearsBack
        yearTo = spec.allowed == .past ? thisYear : thisYear + BotDateTimeSheet.yearsAhead
        super.init(nibName: nil, bundle: nil)
        viewY = thisYear
        viewM = cal.component(.month, from: now)
        hour = cal.component(.hour, from: now)
        minute = cal.component(.minute, from: now)
        if spec.mode == .month {
            selY = viewY
            selM = viewM
        }
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildLayout()
        refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        card.transform = CGAffineTransform(translationX: 0, y: card.bounds.height + 40)
        dimView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.card.transform = .identity
            self.dimView.alpha = 1
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func close(then: (() -> Void)? = nil) {
        view.endEditing(true)
        UIView.animate(withDuration: 0.22, animations: {
            self.card.transform = CGAffineTransform(translationX: 0, y: self.card.bounds.height + 40)
            self.dimView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false, completion: then)
        })
    }

    // MARK: - Layout

    private func buildLayout() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))
        view.addSubview(dimView)

        card.backgroundColor = colors.hippoSurface
        card.layer.cornerRadius = 20
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        // Content scrolls so the card can shrink above the keypad instead of squashing the
        // calendar rows into each other.
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.contentInsetAdjustmentBehavior = .never
        card.addSubview(scrollView)

        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        // Hug the content when there is room; give way to the top limit when the keypad is up.
        let fitContent = scrollView.heightAnchor.constraint(equalTo: stack.heightAnchor)
        fitContent.priority = .defaultHigh

        cardBottom = card.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: card.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: card.safeAreaLayoutGuide.bottomAnchor),
            fitContent,
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardBottom
        ])

        stack.addArrangedSubview(makeHandle())
        stack.addArrangedSubview(makeTitleRow())
        stack.addArrangedSubview(makeSelectedRow())
        if spec.hasCalendar {
            stack.addArrangedSubview(makeCalendarHeader())
            stack.addArrangedSubview(padded(calendarGrid, left: 14, right: 14, top: 2, bottom: 0))
            calendarGrid.allowed = spec.allowed
            calendarGrid.colors = colors
            calendarGrid.onPick = { [weak self] y, m, d in
                guard let self = self else { return }
                self.selY = y
                self.selM = m
                self.selD = d
                self.refresh()
            }
        }
        stack.addArrangedSubview(makeMonthYearSection())
        if spec.mode == .dateTime {
            stack.addArrangedSubview(makeTimeRowSection())
        }
        if spec.mode == .time {
            stack.addArrangedSubview(makeTimeWheelSection())
        }
        stack.addArrangedSubview(makeConfirm())
    }

    private func makeHandle() -> UIView {
        let wrap = UIView()
        let handle = UIView()
        handle.backgroundColor = colors.hippoBorder
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(handle)
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
            handle.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            handle.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.heightAnchor.constraint(equalToConstant: 5)
        ])
        return wrap
    }

    private func makeTitleRow() -> UIView {
        titleLabel.text = titleText()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = colors.hippoTextPrimary

        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)), for: .normal)
        close.tintColor = colors.hippoTextMuted
        close.backgroundColor = colors.hippoSurfaceInput
        close.layer.cornerRadius = 16
        close.accessibilityLabel = "Close"
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        close.widthAnchor.constraint(equalToConstant: 32).isActive = true
        close.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let row = UIStackView(arrangedSubviews: [titleLabel, close])
        row.alignment = .center
        return padded(row, left: 20, right: 20, top: 14, bottom: 6)
    }

    private func makeSelectedRow() -> UIView {
        let label = UILabel()
        label.text = HippoStrings.botSelected
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = colors.hippoTextMuted
        label.setContentHuggingPriority(.required, for: .horizontal)
        selectedValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        let row = UIStackView(arrangedSubviews: [label, selectedValueLabel])
        row.spacing = 8
        row.alignment = .firstBaseline
        return padded(row, left: 20, right: 20, top: 0, bottom: 6)
    }

    private func makeCalendarHeader() -> UIView {
        monthLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        monthLabel.textColor = colors.hippoTextPrimary
        monthLabel.isUserInteractionEnabled = false
        monthChevron.tintColor = colors.hippoAccent
        monthChevron.contentMode = .scaleAspectFit
        monthChevron.isUserInteractionEnabled = false
        let pillContent = UIStackView(arrangedSubviews: [monthLabel, monthChevron])
        pillContent.spacing = 6
        pillContent.alignment = .center
        pillContent.isUserInteractionEnabled = false
        pillContent.translatesAutoresizingMaskIntoConstraints = false
        monthPill.addSubview(pillContent)
        monthPill.layer.cornerRadius = 18
        monthPill.addTarget(self, action: #selector(monthPillTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            pillContent.leadingAnchor.constraint(equalTo: monthPill.leadingAnchor, constant: 12),
            pillContent.trailingAnchor.constraint(equalTo: monthPill.trailingAnchor, constant: -12),
            pillContent.centerYAnchor.constraint(equalTo: monthPill.centerYAnchor),
            monthPill.heightAnchor.constraint(equalToConstant: 36),
            monthChevron.widthAnchor.constraint(equalToConstant: 14),
            monthChevron.heightAnchor.constraint(equalToConstant: 14)
        ])

        for (button, icon, label) in [(prevButton, "chevron.left", "Previous month"), (nextButton, "chevron.right", "Next month")] {
            button.setImage(UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)), for: .normal)
            button.tintColor = colors.hippoTextPrimary
            button.backgroundColor = colors.hippoSurfaceInput
            button.layer.cornerRadius = 17
            button.accessibilityLabel = label
            button.widthAnchor.constraint(equalToConstant: 34).isActive = true
            button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        }
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        monthNav.addArrangedSubview(prevButton)
        monthNav.addArrangedSubview(nextButton)
        monthNav.spacing = 6

        let row = UIStackView(arrangedSubviews: [monthPill, UIView(), monthNav])
        row.alignment = .center
        return padded(row, left: 14, right: 20, top: 6, bottom: 4)
    }

    private func makeMonthYearSection() -> UIView {
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        monthYearPicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        let monthIndex = (spec.mode == .month ? selM : viewM) - 1
        let year = spec.mode == .month ? selY : viewY
        monthYearPicker.selectRow(monthIndex, inComponent: 0, animated: false)
        monthYearPicker.selectRow(max(0, year - yearFrom), inComponent: 1, animated: false)

        monthYearSection.axis = .vertical
        monthYearSection.spacing = 4
        monthYearSection.addArrangedSubview(padded(monthYearPicker, left: 16, right: 16, top: 8, bottom: 0))
        monthYearSection.addArrangedSubview(hintLabel(HippoStrings.botScrollHint))
        return monthYearSection
    }

    private func makeTimeRowSection() -> UIView {
        let divider = UIView()
        divider.backgroundColor = colors.hippoBorder
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let title = UILabel()
        title.text = HippoStrings.botTime
        title.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        title.textColor = colors.hippoTextPrimary
        let hint = UILabel()
        hint.text = HippoStrings.botTimeHint
        hint.font = UIFont.systemFont(ofSize: 12)
        hint.textColor = colors.hippoTextMuted
        let titles = UIStackView(arrangedSubviews: [title, hint])
        titles.axis = .vertical
        titles.spacing = 3

        let colon = UILabel()
        colon.text = ":"
        colon.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        colon.textColor = colors.hippoTextMuted

        for (box, isHour) in [(hourBox, true), (minuteBox, false)] {
            box.colors = colors
            box.field.delegate = self
            box.field.inputAccessoryView = makeKeyboardToolbar()
            box.field.addTarget(self, action: #selector(timeFieldChanged(_:)), for: .editingChanged)
            box.onStep = { [weak self] dir in self?.bumpTime(isHour: isHour, dir: dir) }
        }
        hourBox.field.text = pad(hour)
        minuteBox.field.text = pad(minute)

        let row = UIStackView(arrangedSubviews: [titles, UIView(), hourBox, colon, minuteBox])
        row.alignment = .center
        row.spacing = 6
        row.setCustomSpacing(0, after: titles)

        timeErrorLabel.font = UIFont.systemFont(ofSize: 12.5)
        timeErrorLabel.textColor = colors.hippoError
        timeErrorLabel.numberOfLines = 0

        timeRowSection.axis = .vertical
        timeRowSection.spacing = 12
        timeRowSection.addArrangedSubview(divider)
        timeRowSection.addArrangedSubview(row)
        timeRowSection.addArrangedSubview(timeErrorLabel)
        timeRowSection.setCustomSpacing(8, after: row)
        return padded(timeRowSection, left: 20, right: 20, top: 8, bottom: 0)
    }

    private func makeTimeWheelSection() -> UIView {
        if spec.hasHours { timeFields.append(.hour) }
        if spec.hasMinutes { timeFields.append(.minute) }
        if spec.hasSeconds { timeFields.append(.second) }

        let labels = UIStackView()
        labels.distribution = .fillEqually
        for field in timeFields {
            let label = UILabel()
            label.text = field == .hour ? HippoStrings.botHours : field == .minute ? HippoStrings.botMinutes : HippoStrings.botSeconds
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = colors.hippoTextMuted
            label.textAlignment = .center
            labels.addArrangedSubview(label)
        }

        timePicker.dataSource = self
        timePicker.delegate = self
        timePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        for (index, field) in timeFields.enumerated() {
            let value = field == .hour ? hour : field == .minute ? minute : second
            timePicker.selectRow(value, inComponent: index * 2, animated: false)
        }

        timeWheelSection.axis = .vertical
        timeWheelSection.spacing = 4
        timeWheelSection.addArrangedSubview(padded(labels, left: 16, right: 16, top: 8, bottom: 0))
        timeWheelSection.addArrangedSubview(padded(timePicker, left: 16, right: 16, top: 0, bottom: 0))
        timeWheelSection.addArrangedSubview(hintLabel(HippoStrings.botScrollHint24h))
        return timeWheelSection
    }

    private func makeConfirm() -> UIView {
        confirmButton.layer.cornerRadius = 12
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        confirmButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return padded(confirmButton, left: 20, right: 20, top: 14, bottom: 20)
    }

    private func makeKeyboardToolbar() -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        let done = UIBarButtonItem(title: HippoStrings.botDone, style: .done, target: self, action: #selector(keyboardDoneTapped))
        done.tintColor = colors.hippoAccent
        bar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), done]
        bar.sizeToFit()
        return bar
    }

    private func hintLabel(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = colors.hippoTextMuted
        label.textAlignment = .center
        return padded(label, left: 20, right: 20, top: 0, bottom: 0)
    }

    private func padded(_ content: UIView, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> UIView {
        let wrap = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: left),
            content.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -right),
            content.topAnchor.constraint(equalTo: wrap.topAnchor, constant: top),
            content.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -bottom)
        ])
        return wrap
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        close()
    }

    @objc private func monthPillTapped() {
        if monthYearOpen {
            applyMonthYearWheel()
        } else {
            view.endEditing(true)
            monthYearOpen = true
            monthYearPicker.selectRow(viewM - 1, inComponent: 0, animated: false)
            monthYearPicker.selectRow(max(0, viewY - yearFrom), inComponent: 1, animated: false)
            refresh()
        }
    }

    @objc private func prevTapped() {
        shiftMonth(-1)
    }

    @objc private func nextTapped() {
        shiftMonth(1)
    }

    @objc private func keyboardDoneTapped() {
        commitTypedTime()
        view.endEditing(true)
        refresh()
    }

    @objc private func confirmTapped() {
        if monthYearOpen && spec.hasCalendar {
            applyMonthYearWheel()
            return
        }
        commitTypedTime()
        guard isComplete, !violatesRule else { return }
        let value = spec.formatValue(answer())
        let delegate = self.delegate
        close {
            delegate?.botDateTimePicked(value)
        }
    }

    @objc private func timeFieldChanged(_ field: UITextField) {
        // Our own text rewrites below can fire editingChanged again - ignore those.
        guard !isRewritingTimeField else { return }
        isRewritingTimeField = true
        defer { isRewritingTimeField = false }

        let digits = (field.text ?? "").filter { $0.isNumber }
        let trimmed = String(digits.prefix(2))
        if trimmed != field.text {
            field.text = trimmed
        }
        guard trimmed.count == 2 else { return }
        // Two digits typed: clamp, then hand over to minutes (or finish).
        let isHour = field === hourBox.field
        let value = parse(trimmed, max: isHour ? 23 : 59, fallback: 0)
        if isHour {
            hour = value
        } else {
            minute = value
        }
        if field.text != pad(value) {
            field.text = pad(value)
        }
        if isHour {
            // Move focus after the keyboard finishes this edit, not in the middle of it.
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.hourBox.field.isFirstResponder else { return }
                self.minuteBox.field.becomeFirstResponder()
            }
        }
        refresh()
    }

    private func shiftMonth(_ dir: Int) {
        if dir < 0 && !canGoBack { return }
        if dir > 0 && !canGoForward { return }
        viewM += dir
        if viewM < 1 {
            viewM = 12
            viewY -= 1
        } else if viewM > 12 {
            viewM = 1
            viewY += 1
        }
        refresh()
    }

    private var nowMonthKey: Int {
        let now = Date()
        return calendar.component(.year, from: now) * 12 + calendar.component(.month, from: now) - 1
    }

    private var canGoBack: Bool {
        if spec.allowed != .future { return viewY * 12 + viewM - 1 > yearFrom * 12 }
        return viewY * 12 + viewM - 1 > nowMonthKey
    }

    private var canGoForward: Bool {
        if spec.allowed != .past { return viewY * 12 + viewM - 1 < yearTo * 12 + 11 }
        return viewY * 12 + viewM - 1 < nowMonthKey
    }

    /// Calendar's month title wheel: Done jumps the grid to the picked month (kept in range).
    private func applyMonthYearWheel() {
        let y = yearFrom + monthYearPicker.selectedRow(inComponent: 1)
        let m = monthYearPicker.selectedRow(inComponent: 0)
        var key = y * 12 + m
        if spec.allowed == .future && key < nowMonthKey { key = nowMonthKey }
        if spec.allowed == .past && key > nowMonthKey { key = nowMonthKey }
        viewY = key / 12
        viewM = key % 12 + 1
        monthYearOpen = false
        refresh()
    }

    private func bumpTime(isHour: Bool, dir: Int) {
        commitTypedTime()
        if isHour {
            hour = (hour + dir + 24) % 24
        } else {
            minute = (minute + dir + 60) % 60
        }
        hourBox.field.text = pad(hour)
        minuteBox.field.text = pad(minute)
        refresh()
    }

    /// Folds whatever is typed in the time row into hour/minute, clamped and re-padded.
    private func commitTypedTime() {
        guard spec.mode == .dateTime else { return }
        hour = parse(hourBox.field.text ?? "", max: 23, fallback: hour)
        minute = parse(minuteBox.field.text ?? "", max: 59, fallback: minute)
        if !hourBox.field.isFirstResponder { hourBox.field.text = pad(hour) }
        if !minuteBox.field.isFirstResponder { minuteBox.field.text = pad(minute) }
    }

    @objc private func keyboardWillChange(_ note: Notification) {
        guard let info = note.userInfo,
              let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let local = view.convert(frame, from: nil)
        let overlap = note.name == UIResponder.keyboardWillHideNotification ? 0 : max(0, view.bounds.maxY - local.minY)
        cardBottom.constant = -overlap
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            // Keypad up: show the time row and Confirm. Keypad down: back to the top.
            let maxOffset = max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height)
            self.scrollView.contentOffset = CGPoint(x: 0, y: overlap > 0 ? maxOffset : 0)
        }
    }

    // MARK: - State -> view

    private func refresh() {
        let wheelOnly = spec.mode == .month
        let showMonthYearWheel = wheelOnly || (spec.hasCalendar && monthYearOpen)
        monthYearSection.isHidden = !showMonthYearWheel

        if spec.hasCalendar {
            calendarGrid.superview?.isHidden = monthYearOpen
            monthNav.isHidden = monthYearOpen
            if spec.mode == .dateTime {
                timeRowSection.superview?.isHidden = monthYearOpen
            }
            var comps = DateComponents()
            comps.day = 1
            if monthYearOpen {
                comps.year = yearFrom + monthYearPicker.selectedRow(inComponent: 1)
                comps.month = monthYearPicker.selectedRow(inComponent: 0) + 1
            } else {
                comps.year = viewY
                comps.month = viewM
            }
            monthLabel.text = capitalise(formatted(calendar.date(from: comps) ?? Date(), template: "LLLLyyyy"))
            monthChevron.image = UIImage(systemName: monthYearOpen ? "chevron.up" : "chevron.down",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
            monthPill.backgroundColor = monthYearOpen ? colors.hippoAccentSubtle : colors.hippoSurfaceInput
            prevButton.alpha = canGoBack ? 1 : 0.35
            nextButton.alpha = canGoForward ? 1 : 0.35
            calendarGrid.setState(year: viewY, month: viewM, selY: selY, selM: selM, selD: selD)
        }

        // "Selected" summary
        let complete = isComplete
        selectedValueLabel.text = complete ? summary() : HippoStrings.botNoDateSelected
        selectedValueLabel.textColor = complete ? colors.hippoTextPrimary : colors.hippoTextMuted.withAlphaComponent(0.7)

        // Rule check for date & time (the calendar already blocks whole days).
        let violates = complete && violatesRule
        if spec.mode == .dateTime {
            timeErrorLabel.isHidden = !violates
            timeErrorLabel.text = spec.allowed == .future ? HippoStrings.botTimeInPast : HippoStrings.botTimeInFuture
            hourBox.refreshStyle()
            minuteBox.refreshStyle()
        }

        let monthYearDone = monthYearOpen && spec.hasCalendar
        let enabled = monthYearDone || (complete && !violates)
        confirmButton.setTitle(monthYearDone ? HippoStrings.botDone : HippoStrings.botConfirm, for: .normal)
        confirmButton.backgroundColor = enabled ? colors.hippoAccent : colors.hippoAccentSubtle
        confirmButton.setTitleColor(enabled ? colors.hippoOnAccent : colors.hippoAccent.withAlphaComponent(0.5), for: .normal)
        confirmButton.isEnabled = enabled
    }

    private var isComplete: Bool {
        return spec.hasCalendar ? selD > 0 : true
    }

    /// Date & time / month against the bot's past/future rule. Whole days are blocked by the calendar.
    private var violatesRule: Bool {
        if spec.mode == .month {
            let key = selY * 12 + selM - 1
            return (spec.allowed == .future && key < nowMonthKey) || (spec.allowed == .past && key > nowMonthKey)
        }
        guard spec.mode == .dateTime, spec.allowed != .all else { return false }
        var nowComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        nowComps.second = 0
        let now = calendar.date(from: nowComps) ?? Date()
        let picked = answer()
        return spec.allowed == .future ? picked < now : picked > now
    }

    /// The picked moment. Time-only answers sit on today's date.
    private func answer() -> Date {
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        switch spec.mode {
        case .date:
            comps = DateComponents(year: selY, month: selM, day: selD, hour: 0, minute: 0, second: 0)
        case .dateTime:
            comps = DateComponents(year: selY, month: selM, day: selD, hour: hour, minute: minute, second: 0)
        case .month:
            comps = DateComponents(year: selY, month: selM, day: 1, hour: 0, minute: 0, second: 0)
        case .time:
            comps.hour = spec.hasHours ? hour : 0
            comps.minute = spec.hasMinutes ? minute : 0
            comps.second = spec.hasSeconds ? second : 0
        }
        return calendar.date(from: comps) ?? Date()
    }

    /// Readable value for the "Selected" line, independent of the bot's send format.
    private func summary() -> String {
        switch spec.mode {
        case .date:
            return formatted(answer(), template: "EEEdMMMyyyy")
        case .dateTime:
            return formatted(answer(), template: "EEEdMMMyyyy") + " · " + pad(hour) + ":" + pad(minute)
        case .month:
            return capitalise(formatted(answer(), template: "LLLLyyyy"))
        case .time:
            var parts: [String] = []
            if spec.hasHours { parts.append(pad(hour)) }
            if spec.hasMinutes { parts.append(pad(minute)) }
            if spec.hasSeconds { parts.append(pad(second)) }
            return parts.joined(separator: ":")
        }
    }

    private func titleText() -> String {
        switch spec.mode {
        case .time: return HippoStrings.selectTime
        case .dateTime: return HippoStrings.selectDateTime
        case .month: return HippoStrings.botSelectMonth
        case .date: return HippoStrings.selectDate
        }
    }

    // MARK: - Helpers

    private func formatted(_ date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }

    private func parse(_ text: String, max upper: Int, fallback: Int) -> Int {
        guard let value = Int(text.trimmingCharacters(in: .whitespaces)) else { return fallback }
        return Swift.max(0, Swift.min(upper, value))
    }

    private func pad(_ value: Int) -> String {
        return value < 10 ? "0\(value)" : "\(value)"
    }

    private func capitalise(_ text: String) -> String {
        guard let first = text.first else { return text }
        return String(first).uppercased() + text.dropFirst()
    }
}

// MARK: - Wheels

extension BotDateTimeSheet: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView === monthYearPicker { return 2 }
        // One wheel per field with a ":" column between them.
        return Swift.max(0, timeFields.count * 2 - 1)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === monthYearPicker {
            return component == 0 ? 12 : yearTo - yearFrom + 1
        }
        if component % 2 == 1 { return 1 }
        return timeFields[component / 2] == .hour ? 24 : 60
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let total = pickerView.bounds.width > 0 ? pickerView.bounds.width : UIScreen.main.bounds.width - 32
        if pickerView === monthYearPicker {
            return component == 0 ? total * 0.58 : total * 0.36
        }
        if component % 2 == 1 { return 20 }
        let columns = CGFloat(timeFields.count)
        return (total - 20 * (columns - 1)) / columns - 6
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.textColor = colors.hippoTextPrimary
        if pickerView === monthYearPicker {
            label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            if component == 0 {
                let names = DateFormatter().standaloneMonthSymbols ?? []
                label.text = row < names.count ? capitalise(names[row]) : ""
            } else {
                label.text = String(yearFrom + row)
            }
        } else if component % 2 == 1 {
            label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
            label.text = ":"
        } else {
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 21, weight: .medium)
            label.text = pad(row)
        }
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === monthYearPicker {
            // In the calendar's month-title wheel these only move the label; Done applies them.
            if spec.mode == .month {
                selM = pickerView.selectedRow(inComponent: 0) + 1
                selY = yearFrom + pickerView.selectedRow(inComponent: 1)
            }
        } else if component % 2 == 0 {
            switch timeFields[component / 2] {
            case .hour: hour = row
            case .minute: minute = row
            case .second: second = row
            }
        }
        refresh()
    }
}

extension BotDateTimeSheet: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Select the value so typing replaces it.
        DispatchQueue.main.async {
            guard textField.isFirstResponder else { return }
            textField.selectAll(nil)
        }
        hourBox.refreshStyle()
        minuteBox.refreshStyle()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        commitTypedTime()
        refresh()
    }
}

// MARK: - Calendar grid

/// Month grid for the sheet: weekday header plus day cells. Days outside the allowed range are
/// not tappable; today gets accent text and a dot; the picked day is a filled accent circle.
final class BotCalendarGridView: UIView {

    var onPick: ((Int, Int, Int) -> Void)?
    var allowed: AllowedDateTimeType = .all
    var colors = HippoConfig.shared.colorConfig

    private static let cellHeight: CGFloat = 40
    private static let circle: CGFloat = 36

    private let stack = UIStackView()
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = Calendar.current.firstWeekday
        return c
    }()
    private var year = 0, month = 0
    private var stateKey = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(year: Int, month: Int, selY: Int, selM: Int, selD: Int) {
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let key = "\(year)-\(month)-\(selY)-\(selM)-\(selD)-\(today.day ?? 0)"
        guard key != stateKey else { return }
        stateKey = key
        self.year = year
        self.month = month
        rebuild(selY: selY, selM: selM, selD: selD, today: today)
    }

    private func rebuild(selY: Int, selM: Int, selD: Int, today: DateComponents) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Weekday header, starting at the locale's first weekday.
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let header = UIStackView()
        header.distribution = .fillEqually
        for i in 0..<7 {
            let label = UILabel()
            label.text = symbols[(calendar.firstWeekday - 1 + i) % 7]
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = colors.hippoTextMuted
            label.textAlignment = .center
            header.addArrangedSubview(label)
        }
        header.heightAnchor.constraint(equalToConstant: 26).isActive = true
        stack.addArrangedSubview(header)

        guard let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let days = calendar.range(of: .day, in: .month, for: first)?.count else { return }
        let lead = (calendar.component(.weekday, from: first) - calendar.firstWeekday + 7) % 7
        let cells = Int(ceil(Double(lead + days) / 7.0)) * 7
        let todayKey = dayKey(today.year ?? 0, today.month ?? 0, today.day ?? 0)

        var row: UIStackView?
        for i in 0..<cells {
            if i % 7 == 0 {
                let r = UIStackView()
                r.distribution = .fillEqually
                r.heightAnchor.constraint(equalToConstant: BotCalendarGridView.cellHeight).isActive = true
                stack.addArrangedSubview(r)
                row = r
            }
            let day = i - lead + 1
            guard day >= 1 && day <= days else {
                row?.addArrangedSubview(UIView())
                continue
            }
            let key = dayKey(year, month, day)
            let enabled = allowed == .future ? key >= todayKey : allowed == .past ? key <= todayKey : true
            let selected = selY == year && selM == month && selD == day
            row?.addArrangedSubview(cell(day: day, enabled: enabled, selected: selected, isToday: key == todayKey))
        }
    }

    private func dayKey(_ y: Int, _ m: Int, _ d: Int) -> Int {
        return y * 10000 + m * 100 + d
    }

    private func cell(day: Int, enabled: Bool, selected: Bool, isToday: Bool) -> UIView {
        let button = UIButton(type: .custom)
        button.tag = day
        button.isEnabled = enabled
        button.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)

        let circle = UIView()
        circle.isUserInteractionEnabled = false
        circle.layer.cornerRadius = BotCalendarGridView.circle / 2
        circle.backgroundColor = selected ? colors.hippoAccent : .clear
        circle.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(circle)

        let label = UILabel()
        label.text = "\(day)"
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: selected || isToday ? .semibold : .regular)
        label.textColor = selected ? colors.hippoOnAccent
            : !enabled ? colors.hippoTextMuted.withAlphaComponent(0.45)
            : isToday ? colors.hippoAccent : colors.hippoTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(label)

        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: BotCalendarGridView.circle),
            circle.heightAnchor.constraint(equalToConstant: BotCalendarGridView.circle),
            label.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: isToday && !selected ? -2 : 0)
        ])

        if isToday && !selected {
            let dot = UIView()
            dot.isUserInteractionEnabled = false
            dot.backgroundColor = colors.hippoAccent
            dot.layer.cornerRadius = 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            circle.addSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4),
                dot.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                dot.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 1)
            ])
        }
        button.accessibilityLabel = "\(day)"
        if selected { button.accessibilityTraits.insert(.selected) }
        return button
    }

    @objc private func dayTapped(_ sender: UIButton) {
        onPick?(year, month, sender.tag)
    }
}

// MARK: - Time box

/// "HH" / "mm" box in the date & time row: a two-digit field with up / down arrows.
final class BotTimeBox: UIView {

    let field = UITextField()
    var onStep: ((Int) -> Void)?
    var colors = HippoConfig.shared.colorConfig {
        didSet { refreshStyle() }
    }

    private let up = UIButton(type: .system)
    private let down = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        field.keyboardType = .numberPad
        // Plain two-digit box: no autocorrect or suggestions. An autocorrect pass here re-fires
        // editingChanged while we rewrite the text, which looped until the app crashed.
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.smartInsertDeleteType = .no
        field.smartQuotesType = .no
        field.smartDashesType = .no
        if #available(iOS 17.0, *) {
            field.inlinePredictionType = .no
        }
        field.textAlignment = .center
        field.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
        field.tintColor = colors.hippoAccent

        for (button, icon, dir) in [(up, "chevron.up", 1), (down, "chevron.down", -1)] {
            button.setImage(UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)), for: .normal)
            button.tag = dir
            button.addTarget(self, action: #selector(stepTapped(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 22).isActive = true
            button.heightAnchor.constraint(equalToConstant: 17).isActive = true
        }
        let arrows = UIStackView(arrangedSubviews: [up, down])
        arrows.axis = .vertical

        let row = UIStackView(arrangedSubviews: [field, arrows])
        row.alignment = .center
        row.spacing = 2
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 42),
            field.widthAnchor.constraint(equalToConstant: 28),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            row.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(boxTapped)))
        refreshStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshStyle() {
        let on = field.isFirstResponder
        backgroundColor = on ? colors.hippoSurface : colors.hippoSurfaceInput
        layer.borderWidth = on ? 2 : 0
        layer.borderColor = colors.hippoAccent.cgColor
        field.textColor = colors.hippoTextPrimary
        up.tintColor = colors.hippoTextMuted
        down.tintColor = colors.hippoTextMuted
    }

    @objc private func boxTapped() {
        field.becomeFirstResponder()
    }

    @objc private func stepTapped(_ sender: UIButton) {
        onStep?(sender.tag)
    }
}
