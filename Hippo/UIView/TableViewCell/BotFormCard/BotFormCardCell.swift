//
//  BotFormCardCell.swift
//  Hippo
//
//  Customer card for a bot lead form (leadForm) or ticket form (createTicket).
//

import UIKit

// MARK: - Spec

/// A lead / ticket form read from the message's `leadsDataArray` (built from content_value's
/// questions / params / data_type and the server's `values`).
///
/// The step to show is the first unanswered one - or, on a ticket form, a value the server
/// prefilled (email / name, editable until the description is answered) that the visitor hasn't
/// confirmed yet. Answers go out one at a time, so the form is complete when every question has
/// a value. "N/A" marks a skipped step.
struct BotFormSpec {

    static let skipped = "N/A"

    enum Kind { case email, phone, number, text, area, attachments, group, priority }

    struct Field {
        let param: String
        let question: String
        let kind: Kind
        /// Ticket attachments and priority can be skipped; nothing else can.
        let skippable: Bool

        var label: String {
            switch kind {
            case .email: return HippoStrings.formLabelEmail
            case .phone: return HippoStrings.formLabelPhone
            case .area: return HippoStrings.formLabelDescription
            case .attachments: return HippoStrings.formLabelAttachments
            case .group: return HippoStrings.formLabelGroup
            case .priority: return HippoStrings.formLabelPriority
            default:
                if param.lowercased() == "name" { return HippoStrings.formLabelName }
                if param.lowercased() == "subject" { return HippoStrings.formLabelSubject }
                return question
            }
        }

        var placeholder: String {
            switch kind {
            case .email: return HippoStrings.formPhEmail
            case .phone: return HippoStrings.formPhPhone
            case .area: return HippoStrings.formPhDescription
            case .group: return HippoStrings.formPhGroup
            case .priority: return HippoStrings.formPhPriority
            default:
                if param.lowercased() == "name" { return HippoStrings.formPhName }
                if param.lowercased() == "subject" { return HippoStrings.formPhSubject }
                return HippoStrings.formTypeAnswer
            }
        }

        /// Error for an invalid answer, or nil when the answer is fine.
        func validate(_ value: String) -> String? {
            let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if v.isEmpty { return HippoStrings.formErrEmpty }
            switch kind {
            case .email: return BotFormSpec.isValidEmail(v) ? nil : HippoStrings.formErrEmail
            case .phone: return v.isValidPhoneNumber() ? nil : HippoStrings.formErrPhone
            case .number: return Double(v) != nil ? nil : HippoStrings.formErrNumber
            default: return nil
            }
        }
    }

    let isTicket: Bool
    let fields: [Field]
    /// Answer per step, nil while unanswered.
    let values: [String?]
    let skippedOut: Bool
    /// Lead form the bot lets the visitor skip (is_skip_button): a "Skip" beside each open step
    /// ends the whole form (is_skip_event), as the old lead form's Skip button did.
    let canSkipForm: Bool
    /// Ticket steps the server prefilled that the visitor hasn't confirmed yet.
    let pendingPrefill: Set<Int>

    init(message: HippoMessage, confirmed: Set<Int>) {
        isTicket = message.type == .createTicket
        let data = message.leadsDataArray
        var fields: [Field] = []
        var values: [String?] = []
        var pending = Set<Int>()
        for (i, d) in data.enumerated() {
            let kind = BotFormSpec.kindOf(data: d, isTicket: message.type == .createTicket)
            let skippable = message.type == .createTicket && (kind == .attachments || kind == .priority)
            fields.append(Field(param: d.param ?? "", question: d.title, kind: kind, skippable: skippable))
            var value: String? = d.isCompleted && !d.value.isEmpty ? d.value : nil
            // Attachments come back from the server as "name and N more": use the raw JSON.
            if kind == .attachments, value != nil, i < message.content.values.count,
               !BotFormSpec.attachmentNames(message.content.values[i]).isEmpty,
               BotFormSpec.attachmentNames(value ?? "").isEmpty {
                value = message.content.values[i]
            }
            values.append(value)
            if message.type == .createTicket, d.isCompleted, d.shouldBeEditable, !confirmed.contains(i) {
                pending.insert(i)
            }
        }
        self.fields = fields
        self.values = values
        self.pendingPrefill = pending
        skippedOut = message.isSkipEvent
        canSkipForm = !isTicket && message.isSkipBotEnabled && !message.isSkipEvent
    }

    /// Ticket params_id names the field reliably; params / data_type are the fallback.
    private static func kindOf(data: FormData, isTicket: Bool) -> Kind {
        if isTicket, let id = data.paramId, let field = CreateTicketFields(rawValue: id) {
            switch field {
            case .email: return .email
            case .name, .subject: return .text
            case .description: return .area
            case .attachments: return .attachments
            case .issueType: return .group
            case .priority: return .priority
            }
        }
        let p = (data.param ?? "").lowercased()
        let t = data.dataType.lowercased()
        if p == "email" || t == "email" { return .email }
        if p == "phone" || t == "phone" || t == "telephone" { return .phone }
        if p == "description" { return .area }
        if p == "attachments" || t == "attachment" { return .attachments }
        if p == "issuetype" { return .group }
        if p == "priority" { return .priority }
        if t == "number" { return .number }
        return .text
    }

    var count: Int {
        return fields.count
    }

    /// Step to show, or nil when every step is answered.
    var currentIndex: Int? {
        if let first = pendingPrefill.min() {
            let open = values.firstIndex(where: { $0 == nil })
            if open == nil || first < open! { return first }
        }
        return values.firstIndex(where: { $0 == nil })
    }

    /// A ticket form can't be skipped as a whole; a lead form ends on is_skip_event.
    var isComplete: Bool {
        if fields.isEmpty { return true }
        if currentIndex == nil { return true }
        return !isTicket && skippedOut
    }

    func value(at index: Int) -> String? {
        return index < values.count ? values[index] : nil
    }

    static func isSkipped(_ value: String?) -> Bool {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else { return true }
        return v.caseInsensitiveCompare(skipped) == .orderedSame
    }

    /// Value of the first field of this kind, e.g. the email for the ticket confirmation.
    func value(of kind: Kind) -> String? {
        guard let i = fields.firstIndex(where: { $0.kind == kind }) else { return nil }
        let v = value(at: i)
        return BotFormSpec.isSkipped(v) ? nil : v
    }

    static func isValidEmail(_ value: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }

    /// Attachments are stored as a JSON array of {fileName, url}.
    static func attachmentNames(_ raw: String) -> [String] {
        guard let data = raw.data(using: .utf8),
              let list = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] else { return [] }
        return list.map { $0["fileName"] as? String ?? "" }
    }
}

// MARK: - Host

protocol BotFormCardHost: AnyObject {
    /// Record and send one answer. `message.leadsDataArray` is updated before this returns.
    func botForm(submit value: String, at index: Int, of message: HippoMessage)
    /// Open the attachment chooser for this step; uploads land in the step's attachmentUrl.
    func botForm(pickAttachmentAt index: Int, of message: HippoMessage)
    /// Group type / priority options for the ticket form.
    func botFormLoadOptions(group: Bool, completion: @escaping ([String]) -> Void)
    /// The card's height changed without a table reload (error shown, file removed...).
    func botFormNeedsLayout(_ cell: BotFormCardCell)
    /// One of the card's fields is about to take the keyboard.
    func botFormFieldWillFocus()
    /// The focused field let go of the keyboard.
    func botFormFieldDidEnd()
    /// Skip the whole lead form (is_skip_event), for a bot that allows it.
    func botFormSkip(_ message: HippoMessage)
}

// MARK: - Cell

final class BotFormCardCell: UITableViewCell {

    static let identifier = "BotFormCardCell"

    let card = BotFormCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        let preferred = card.widthAnchor.constraint(equalToConstant: 320)
        preferred.priority = .defaultHigh
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10), // same left edge as chat bubbles
            card.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),
            preferred
        ])
        card.onNeedsLayout = { [weak self] in
            guard let self = self else { return }
            self.card.host?.botFormNeedsLayout(self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(message: HippoMessage, ticketId: String?, host: BotFormCardHost) {
        card.bind(message: message, ticketId: ticketId, host: host)
    }
}

// MARK: - Card

/// Open form: a step counter with a progress bar, the answered steps as rows with green checks
/// (skipped ones in grey), then one large question with the right input for its field - email /
/// text / phone keyboards, a multi-line description, an upload area, or a dropdown for group and
/// priority. Errors show inline and keep the keyboard up. Ticket attachments and priority can be
/// skipped.
///
/// Finished form: a "Submitted" card (lead) or a "Ticket created" confirmation (ticket).
///
/// Drafts and picked options live in static maps keyed by message + step, so they survive
/// table reloads.
final class BotFormCardView: UIView {

    private static var drafts: [String: String] = [:]
    private static var countryCodes: [String: String] = [:]
    private static var options: [Bool: [String]] = [:]

    weak var host: BotFormCardHost?
    var onNeedsLayout: (() -> Void)?

    private var message: HippoMessage?
    private var spec: BotFormSpec?
    private var ticketId: String?
    private var key = ""
    private var errorText: String?
    private var refocusAfterRender = false
    /// Step shown by the last render, or -1 for a finished card.
    private(set) var renderedIndex = -1
    private var renderedSignature = ""
    private weak var activeField: UIView?

    private let colors = HippoConfig.shared.colorConfig
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        stack.axis = .vertical
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

    // MARK: Binding

    func bind(message: HippoMessage, ticketId: String?, host: BotFormCardHost) {
        let newKey = BotFormCardView.key(of: message)
        let sameMessage = newKey == key
        self.message = message
        self.host = host
        self.ticketId = ticketId
        self.key = newKey
        let spec = BotFormSpec(message: message, confirmed: BotFormCardView.confirmed(for: newKey))
        self.spec = spec
        if !sameMessage {
            errorText = nil
            refocusAfterRender = false
        }
        // A refresh for the step already on screen (e.g. the server echo of the previous answer)
        // must not rebuild the card: that would drop the focused field and the keyboard.
        let signature = renderSignature(spec)
        if sameMessage, signature == renderedSignature, hasFocusedField {
            return
        }
        render()
    }

    private func renderSignature(_ spec: BotFormSpec) -> String {
        let files = message.map { m -> String in
            guard let i = spec.currentIndex, i < m.leadsDataArray.count else { return "" }
            return m.leadsDataArray[i].attachmentUrl.map { "\($0.name ?? "")\($0.isUploaded == true)\($0.isFailed)" }.joined()
        } ?? ""
        return "\(spec.currentIndex ?? -1)|\(spec.isComplete)|\(spec.values.compactMap { $0 }.count)|\(ticketId ?? "")|\(files)"
    }

    var hasFocusedField: Bool {
        return activeField?.isFirstResponder == true
    }

    /// Puts the keyboard on the open step's text field (no-op for menus / uploads).
    func focusCurrentField() {
        guard let field = activeField, field.window != nil, !field.isFirstResponder else { return }
        host?.botFormFieldWillFocus()
        field.becomeFirstResponder()
    }

    var currentStepTakesKeyboard: Bool {
        return activeField != nil
    }

    private static func key(of message: HippoMessage) -> String {
        return (message.messageUniqueID ?? "\(message.messageId ?? -1)") + "#" + String(message.type.rawValue)
    }

    private func stepKey(_ index: Int) -> String {
        return key + "#" + String(index)
    }

    // MARK: Prefill confirmations (persisted)

    private static func confirmed(for key: String) -> Set<Int> {
        let list = UserDefaults.standard.array(forKey: "hippo_form_prefill_" + key) as? [Int] ?? []
        return Set(list)
    }

    private static func confirm(_ index: Int, for key: String) {
        var set = confirmed(for: key)
        set.insert(index)
        UserDefaults.standard.set(Array(set), forKey: "hippo_form_prefill_" + key)
    }

    // MARK: Rendering

    private func render() {
        guard let spec = spec else { return }
        activeField = nil
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        backgroundColor = colors.hippoSurface
        layer.borderColor = colors.hippoBorder.cgColor
        if spec.isComplete {
            renderedIndex = -1
            if spec.isTicket {
                renderTicketCreated(spec)
            } else {
                renderSubmitted(spec)
            }
        } else {
            renderOpen(spec)
        }
        renderedSignature = renderSignature(spec)
        if refocusAfterRender {
            refocusAfterRender = false
            DispatchQueue.main.async { [weak self] in
                self?.focusCurrentField()
            }
        }
    }

    private func renderOpen(_ spec: BotFormSpec) {
        guard let index = spec.currentIndex else { return }
        renderedIndex = index
        let field = spec.fields[index]

        // Step counter + segmented progress bar
        let step = label(String(format: HippoStrings.formStep, index + 1, spec.count), size: 12.5, weight: .semibold, color: colors.hippoTextMuted)
        let segments = UIStackView()
        segments.spacing = 4
        segments.distribution = .fillEqually
        for i in 0..<spec.count {
            let seg = UIView()
            seg.backgroundColor = i <= index ? colors.hippoAccent : colors.hippoBorder
            seg.layer.cornerRadius = 2
            seg.heightAnchor.constraint(equalToConstant: 4).isActive = true
            segments.addArrangedSubview(seg)
        }
        let head = UIStackView(arrangedSubviews: [step, segments])
        head.axis = .vertical
        head.spacing = 10
        stack.addArrangedSubview(padded(head, top: 14, left: 16, bottom: 8, right: 16))

        // Answered steps
        for i in 0..<index {
            stack.addArrangedSubview(answerRow(spec, i))
        }

        // Current step
        let question = label(field.question, size: 17, weight: .semibold, color: colors.hippoTextPrimary)
        question.numberOfLines = 0
        let titleRow = UIStackView(arrangedSubviews: [question])
        titleRow.alignment = .top
        titleRow.spacing = 12
        if field.skippable || spec.canSkipForm {
            let skip = UIButton(type: .system)
            skip.setTitle(HippoStrings.formSkip, for: .normal)
            skip.setTitleColor(colors.hippoAccent, for: .normal)
            skip.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            skip.setContentHuggingPriority(.required, for: .horizontal)
            skip.setContentCompressionResistancePriority(.required, for: .horizontal)
            if field.skippable {
                skip.addAction { [weak self] in self?.submit(index, BotFormSpec.skipped) }
            } else {
                skip.addAction { [weak self] in
                    guard let self = self, let message = self.message else { return }
                    self.endEditing(true)
                    self.host?.botFormSkip(message)
                }
            }
            titleRow.addArrangedSubview(skip)
        }

        let input: UIView
        switch field.kind {
        case .area:
            input = areaInput(index, field)
        case .attachments:
            input = attachmentsInput(index)
        case .group, .priority:
            input = dropdownInput(index, field)
        default:
            input = lineInput(index, field)
        }
        let body = UIStackView(arrangedSubviews: [titleRow, input])
        body.axis = .vertical
        body.spacing = 10
        if let error = errorText {
            body.addArrangedSubview(errorLabel(error))
        }
        stack.addArrangedSubview(padded(body, top: index > 0 ? 12 : 8, left: 16, bottom: 12, right: 16))
        addTime()
    }

    /// One answered step: label, value, green check (or grey "Skipped").
    private func answerRow(_ spec: BotFormSpec, _ i: Int) -> UIView {
        let f = spec.fields[i]
        let raw = spec.value(at: i)
        let skipped = BotFormSpec.isSkipped(raw)
        let title = label(f.label, size: 12, weight: .medium, color: colors.hippoTextMuted)
        let value = label(skipped ? HippoStrings.formSkipped : displayValue(f, raw ?? ""), size: 14.5, weight: .regular,
                          color: skipped ? colors.hippoTextMuted : colors.hippoTextPrimary)
        value.lineBreakMode = .byTruncatingTail
        let col = UIStackView(arrangedSubviews: [title, value])
        col.axis = .vertical
        col.spacing = 2
        let row = UIStackView(arrangedSubviews: [col])
        row.alignment = .center
        row.spacing = 8
        if !skipped {
            row.addArrangedSubview(successCheck(size: 22, icon: 11))
        }
        return padded(row, top: 8, left: 16, bottom: 8, right: 16)
    }

    private func displayValue(_ f: BotFormSpec.Field, _ raw: String) -> String {
        guard f.kind == .attachments else { return raw }
        let names = BotFormSpec.attachmentNames(raw)
        return names.isEmpty ? raw : names.joined(separator: ", ")
    }

    // MARK: Inputs

    /// Single-line field: email / name / subject / number, or phone with a country-code prefix.
    private func lineInput(_ index: Int, _ field: BotFormSpec.Field) -> UIView {
        let box = InputBox()
        let row = UIStackView()
        row.alignment = .center
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -5),
            row.topAnchor.constraint(equalTo: box.topAnchor, constant: 5),
            row.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -5),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])

        if field.kind == .phone {
            let code = label(countryCode(index), size: 15, weight: .medium, color: colors.hippoTextPrimary)
            code.setContentHuggingPriority(.required, for: .horizontal)
            row.addArrangedSubview(code)
            let divider = UIView()
            divider.backgroundColor = colors.hippoBorder
            divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
            divider.heightAnchor.constraint(equalToConstant: 20).isActive = true
            row.addArrangedSubview(divider)
        }

        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = colors.hippoTextPrimary
        tf.tintColor = colors.hippoAccent
        tf.attributedPlaceholder = NSAttributedString(string: field.placeholder,
                                                      attributes: [.foregroundColor: colors.hippoTextMuted.withAlphaComponent(0.7)])
        tf.returnKeyType = .done
        switch field.kind {
        case .email:
            tf.keyboardType = .emailAddress
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
            tf.textContentType = .emailAddress
        case .phone:
            tf.keyboardType = .phonePad
            tf.textContentType = .telephoneNumber
        case .number:
            tf.keyboardType = .decimalPad
        default:
            let isName = field.param.lowercased() == "name"
            tf.keyboardType = .default
            tf.autocapitalizationType = isName ? .words : .sentences
            if isName { tf.textContentType = .name }
        }
        tf.text = draftOrPrefill(index, field)
        row.addArrangedSubview(tf)

        let send = sendButton(enabled: !(tf.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
        row.addArrangedSubview(send)

        let submitTyped: () -> Void = { [weak self, weak tf] in
            guard let self = self, let tf = tf else { return }
            self.trySubmitTyped(index, field, tf.text ?? "", focused: tf.isFirstResponder)
        }
        send.addAction(submitTyped)
        tf.addAction(for: .editingDidEndOnExit, submitTyped)
        tf.addAction(for: .editingChanged) { [weak self, weak tf, weak send] in
            guard let self = self, let tf = tf, let send = send else { return }
            BotFormCardView.drafts[self.stepKey(index)] = tf.text ?? ""
            self.styleSend(send, enabled: !(tf.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
        }
        tf.addAction(for: .editingDidBegin) { [weak self, weak box] in
            box?.setActive(true, error: self?.errorText != nil)
            self?.host?.botFormFieldWillFocus()
        }
        tf.addAction(for: .editingDidEnd) { [weak self, weak box] in
            box?.setActive(false, error: self?.errorText != nil)
            self?.host?.botFormFieldDidEnd()
        }
        box.colors = colors
        box.setActive(false, error: errorText != nil)
        box.onTap = { [weak tf] in tf?.becomeFirstResponder() }
        activeField = tf
        return box
    }

    /// Description: multi-line, Return adds a line, send sits bottom-right.
    private func areaInput(_ index: Int, _ field: BotFormSpec.Field) -> UIView {
        let box = InputBox()
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = colors.hippoTextPrimary
        tv.tintColor = colors.hippoAccent
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 48)
        tv.autocapitalizationType = .sentences
        tv.text = draftOrPrefill(index, field)
        tv.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(tv)

        let placeholder = label(field.placeholder, size: 15, weight: .regular, color: colors.hippoTextMuted.withAlphaComponent(0.7))
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.isHidden = !tv.text.isEmpty
        box.addSubview(placeholder)

        let send = sendButton(enabled: !tv.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        send.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(send)
        NSLayoutConstraint.activate([
            tv.topAnchor.constraint(equalTo: box.topAnchor),
            tv.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            tv.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            tv.heightAnchor.constraint(equalToConstant: 112),
            placeholder.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            placeholder.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 15),
            placeholder.trailingAnchor.constraint(lessThanOrEqualTo: box.trailingAnchor, constant: -48),
            send.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -5),
            send.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -5)
        ])
        let delegate = AreaDelegate()
        delegate.onChange = { [weak self, weak tv, weak placeholder, weak send] in
            guard let self = self, let tv = tv else { return }
            BotFormCardView.drafts[self.stepKey(index)] = tv.text
            placeholder?.isHidden = !tv.text.isEmpty
            if let send = send {
                self.styleSend(send, enabled: !tv.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        delegate.onBegin = { [weak self, weak box] in
            box?.setActive(true, error: self?.errorText != nil)
            self?.host?.botFormFieldWillFocus()
        }
        delegate.onEnd = { [weak self, weak box] in
            box?.setActive(false, error: self?.errorText != nil)
            self?.host?.botFormFieldDidEnd()
        }
        tv.delegate = delegate
        objc_setAssociatedObject(tv, &BotFormCardView.areaDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        send.addAction { [weak self, weak tv] in
            guard let self = self, let tv = tv else { return }
            self.trySubmitTyped(index, field, tv.text, focused: tv.isFirstResponder)
        }
        box.colors = colors
        box.setActive(false, error: errorText != nil)
        box.onTap = { [weak tv] in tv?.becomeFirstResponder() }
        activeField = tv
        return box
    }

    private static var areaDelegateKey = 0

    /// Draft text for a step, or the server's prefilled value (minus anything the old form also
    /// refused). Phone values drop a leading country code that matches the prefix shown.
    private func draftOrPrefill(_ index: Int, _ field: BotFormSpec.Field) -> String {
        if let draft = BotFormCardView.drafts[stepKey(index)] { return draft }
        guard let spec = spec, spec.pendingPrefill.contains(index), var v = spec.value(at: index),
              !BotFormSpec.isSkipped(v) else { return "" }
        v = v.trimmingCharacters(in: .whitespacesAndNewlines)
        if field.param.lowercased() == "name" && v.caseInsensitiveCompare("Visitor") == .orderedSame { return "" }
        if field.kind == .email && field.validate(v) != nil { return "" }
        if field.kind == .phone {
            let code = countryCode(index)
            if v.hasPrefix(code) { v = String(v.dropFirst(code.count)) }
        }
        return v
    }

    private func trySubmitTyped(_ index: Int, _ field: BotFormSpec.Field, _ text: String, focused: Bool) {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let check = field.kind == .phone ? value.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "") : value
        if let error = field.validate(check) {
            // Keep the keyboard up on the same field and show what is wrong.
            errorText = error
            refocusAfterRender = true
            render()
            onNeedsLayout?()
            return
        }
        if field.kind == .phone { value = countryCode(index) + check }
        refocusAfterRender = focused
        submit(index, value)
    }

    // MARK: Dropdown (group / priority)

    private func dropdownInput(_ index: Int, _ field: BotFormSpec.Field) -> UIView {
        let group = field.kind == .group
        var picked = BotFormCardView.drafts[stepKey(index)]
        if picked == nil, let spec = spec, spec.pendingPrefill.contains(index), !BotFormSpec.isSkipped(spec.value(at: index)) {
            picked = spec.value(at: index)
        }
        let box = InputBox()
        let row = UIStackView()
        row.alignment = .center
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isUserInteractionEnabled = true
        box.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -5),
            row.topAnchor.constraint(equalTo: box.topAnchor, constant: 5),
            row.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -5),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
        if !group, let picked = picked {
            row.addArrangedSubview(priorityDot(picked))
        }
        let value = label(picked ?? field.placeholder, size: 15, weight: .regular,
                          color: picked != nil ? colors.hippoTextPrimary : colors.hippoTextMuted.withAlphaComponent(0.7))
        value.lineBreakMode = .byTruncatingTail
        value.isUserInteractionEnabled = false
        row.addArrangedSubview(value)
        // Up-down chevron: the list opens above the field (below when there's no room), so a
        // plain down arrow pointed the wrong way. It stays the same while open; the box shows it.
        let chevron = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)))
        chevron.tintColor = colors.hippoTextMuted
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.isUserInteractionEnabled = false
        row.addArrangedSubview(chevron)
        let send = sendButton(enabled: picked != nil)
        row.addArrangedSubview(send)
        send.addAction { [weak self] in
            guard let self = self else { return }
            if let picked = picked {
                self.submit(index, picked)
            } else {
                self.errorText = HippoStrings.formErrSelect
                self.render()
                self.onNeedsLayout?()
            }
        }
        box.colors = colors
        box.setActive(false, error: errorText != nil)
        box.onTap = { [weak self, weak box] in
            guard let self = self, let box = box else { return }
            self.showOptions(anchor: box, index: index, group: group, picked: picked)
        }
        return box
    }

    /// Options float in a list just above the field (as in the design), so the card itself never
    /// shifts. Closes on a pick or a tap outside; long lists scroll.
    private func showOptions(anchor: InputBox, index: Int, group: Bool, picked: String?) {
        guard let window = anchor.window else { return }
        window.endEditing(true)
        let popup = BotFormOptionsPopup(colors: colors)
        popup.onDismiss = { [weak anchor, weak self] in
            anchor?.setActive(false, error: self?.errorText != nil)
        }
        popup.onPick = { [weak self] option in
            guard let self = self else { return }
            BotFormCardView.drafts[self.stepKey(index)] = option
            self.errorText = nil
            self.render()
            self.onNeedsLayout?()
        }
        anchor.setActive(true, error: false)
        if let cached = BotFormCardView.options[group] {
            popup.show(in: window, above: anchor, options: cached, picked: picked, withDots: !group, dotColor: priorityColor)
        } else {
            popup.show(in: window, above: anchor, options: nil, picked: picked, withDots: !group, dotColor: priorityColor)
            host?.botFormLoadOptions(group: group) { [weak popup, weak self] options in
                BotFormCardView.options[group] = options.isEmpty ? nil : options
                guard let popup = popup, let self = self, popup.superview != nil else { return }
                popup.update(options: options, picked: picked, withDots: !group, dotColor: self.priorityColor)
            }
        }
    }

    /// Critical -> error, urgent/high -> warning, anything else -> muted.
    private func priorityColor(_ priority: String) -> UIColor {
        let p = priority.lowercased()
        if p.contains("crit") { return colors.hippoError }
        if p.contains("urgent") || p.contains("high") { return colors.hippoWarning }
        return colors.hippoTextMuted
    }

    private func priorityDot(_ priority: String) -> UIView {
        let dot = UIView()
        dot.backgroundColor = priorityColor(priority)
        dot.layer.cornerRadius = 4
        dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
        dot.isUserInteractionEnabled = false
        return dot
    }

    // MARK: Attachments

    private func attachmentsInput(_ index: Int) -> UIView {
        let files = message.map { index < $0.leadsDataArray.count ? $0.leadsDataArray[index].attachmentUrl : [] } ?? []

        let area = DashedAreaView()
        area.fill = colors.hippoAccentSubtle.withAlphaComponent(0.6)
        area.stroke = colors.hippoAccent.withAlphaComponent(0.35)
        let icon = UIImageView(image: UIImage(systemName: "arrow.up.doc", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)))
        icon.tintColor = colors.hippoAccent
        let tap = label(HippoStrings.formUploadTap, size: 14, weight: .semibold, color: colors.hippoAccent)
        // Same limit the picker enforces (max_file_size, in bytes).
        let maxSize = ByteCountFormatter.string(fromByteCount: Int64(BussinessProperty.current.maxUploadLimitForBusiness), countStyle: .binary)
        let limit = label(String(format: HippoStrings.formUploadLimit, maxSize), size: 11.5, weight: .regular, color: colors.hippoTextMuted)
        let labels = UIStackView(arrangedSubviews: [tap, limit])
        labels.axis = .vertical
        labels.spacing = 3
        let content = UIStackView(arrangedSubviews: [icon, labels])
        content.alignment = .center
        content.spacing = 10
        content.isUserInteractionEnabled = false
        content.translatesAutoresizingMaskIntoConstraints = false
        area.addSubview(content)
        NSLayoutConstraint.activate([
            content.centerXAnchor.constraint(equalTo: area.centerXAnchor),
            content.topAnchor.constraint(equalTo: area.topAnchor, constant: 10),
            content.bottomAnchor.constraint(equalTo: area.bottomAnchor, constant: -10),
            area.heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])
        area.addGestureRecognizer(BlockTap { [weak self] in self?.pick(index) })

        let wrap = UIStackView(arrangedSubviews: [area])
        wrap.axis = .vertical
        wrap.spacing = 8
        for (i, f) in files.enumerated() {
            wrap.addArrangedSubview(fileRow(index, i, f))
        }

        let anyDone = files.contains { $0.isUploaded == true }
        let anyUploading = files.contains { $0.isUploaded != true && !$0.isFailed }
        let canContinue = anyDone && !anyUploading
        let done = UIButton(type: .custom)
        done.setTitle(HippoStrings.formDone, for: .normal)
        done.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        done.setTitleColor(canContinue ? colors.hippoOnAccent : colors.hippoAccent.withAlphaComponent(0.5), for: .normal)
        done.backgroundColor = canContinue ? colors.hippoAccent : colors.hippoAccentSubtle
        done.layer.cornerRadius = 12
        done.heightAnchor.constraint(equalToConstant: 46).isActive = true
        done.addAction { [weak self] in
            guard let self = self else { return }
            guard canContinue else {
                self.errorText = HippoStrings.formErrUpload
                self.render()
                self.onNeedsLayout?()
                return
            }
            self.submit(index, BotFormCardView.attachmentsJson(files))
        }
        wrap.setCustomSpacing(10, after: wrap.arrangedSubviews.last ?? area)
        wrap.addArrangedSubview(done)
        return wrap
    }

    private func fileRow(_ index: Int, _ position: Int, _ f: TicketUrl) -> UIView {
        let failed = f.isFailed
        let uploading = f.isUploaded != true && !failed
        let row = UIView()
        row.backgroundColor = failed ? colors.hippoError.withAlphaComponent(0.08) : colors.hippoSurfaceInput
        row.layer.cornerRadius = 12

        let icon = UIImageView(image: UIImage(systemName: "doc", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)))
        icon.tintColor = failed ? colors.hippoError : colors.hippoAccent
        icon.contentMode = .center
        icon.backgroundColor = colors.hippoSurface
        icon.layer.cornerRadius = 8
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let name = label(f.name?.isEmpty == false ? f.name! : HippoStrings.formUploading, size: 13.5, weight: .medium, color: colors.hippoTextPrimary)
        name.lineBreakMode = .byTruncatingMiddle
        let col = UIStackView(arrangedSubviews: [name])
        col.axis = .vertical
        col.spacing = 4
        if uploading {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.trackTintColor = colors.hippoBorder
            bar.progressTintColor = colors.hippoAccent
            bar.progress = 0.35
            bar.layer.cornerRadius = 2
            bar.clipsToBounds = true
            bar.heightAnchor.constraint(equalToConstant: 4).isActive = true
            col.addArrangedSubview(bar)
            BotFormCardView.animateIndeterminate(bar)
        } else if failed {
            col.addArrangedSubview(label(HippoStrings.formUploadFailed, size: 12, weight: .medium, color: colors.hippoError))
        } else if let size = f.size, !size.isEmpty {
            col.addArrangedSubview(label(size, size: 12, weight: .regular, color: colors.hippoTextMuted))
        }

        let h = UIStackView(arrangedSubviews: [icon, col])
        h.alignment = .center
        h.spacing = 10
        if failed {
            let retry = iconButton("arrow.clockwise", color: colors.hippoError)
            retry.addAction { [weak self] in self?.retry(index, position) }
            h.addArrangedSubview(retry)
        }
        if !uploading {
            let remove = iconButton("xmark", color: colors.hippoTextMuted)
            remove.addAction { [weak self] in self?.removeFile(index, position) }
            h.addArrangedSubview(remove)
        }
        h.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(h)
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 8),
            h.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -8),
            h.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),
            h.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -6)
        ])
        if failed {
            row.addGestureRecognizer(BlockTap { [weak self] in self?.retry(index, position) })
        }
        return row
    }

    private static func animateIndeterminate(_ bar: UIProgressView) {
        UIView.animate(withDuration: 0.9, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            bar.setProgress(0.85, animated: true)
        })
    }

    /// A failed upload is retried by choosing the file again (the picker result is not kept).
    private func retry(_ index: Int, _ position: Int) {
        removeFile(index, position, relayout: false)
        pick(index)
    }

    private func removeFile(_ index: Int, _ position: Int, relayout: Bool = true) {
        guard let m = message, index < m.leadsDataArray.count, position < m.leadsDataArray[index].attachmentUrl.count else { return }
        m.leadsDataArray[index].attachmentUrl.remove(at: position)
        if relayout {
            render()
            onNeedsLayout?()
        }
    }

    private func pick(_ index: Int) {
        guard let m = message else { return }
        errorText = nil
        host?.botForm(pickAttachmentAt: index, of: m)
    }

    private static func attachmentsJson(_ files: [TicketUrl]) -> String {
        let list: [[String: Any]] = files.filter { $0.isUploaded == true }.map { ["fileName": $0.name ?? "", "url": $0.url ?? ""] }
        guard let data = try? JSONSerialization.data(withJSONObject: list) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    // MARK: Finished cards

    /// Lead form: "Submitted" with every answer.
    private func renderSubmitted(_ spec: BotFormSpec) {
        // A form the visitor skipped reads "Skipped" in grey, with whatever was answered before.
        let skipped = spec.skippedOut && spec.currentIndex != nil
        let title = label(skipped ? HippoStrings.formSkipped : HippoStrings.formSubmitted, size: 14, weight: .semibold,
                          color: skipped ? colors.hippoTextMuted : colors.hippoTextPrimary)
        let head = UIStackView(arrangedSubviews: skipped ? [title] : [successCheck(size: 20, icon: 10), title])
        head.alignment = .center
        head.spacing = 8
        stack.addArrangedSubview(padded(head, top: 14, left: 16, bottom: 8, right: 16))
        for i in 0..<spec.count where spec.value(at: i) != nil {
            stack.addArrangedSubview(answerRow(spec, i))
        }
        addTime()
    }

    /// Ticket form: confirmation with the key fields; skipped ones read "Not set" / "None".
    private func renderTicketCreated(_ spec: BotFormSpec) {
        let created = !(ticketId ?? "").isEmpty
        let top = UIStackView(arrangedSubviews: [successCheck(size: 48, icon: 22)])
        top.axis = .vertical
        top.alignment = .center
        let title = label(created ? HippoStrings.formTicketCreated : HippoStrings.formSubmitted, size: 17, weight: .semibold, color: colors.hippoTextPrimary)
        top.addArrangedSubview(title)
        top.setCustomSpacing(10, after: top.arrangedSubviews[0])
        var sub: String?
        if created, let email = spec.value(of: .email) {
            sub = "#" + ticketId! + " · " + String(format: HippoStrings.formTicketEmail, email)
        } else if created {
            sub = "#" + ticketId!
        }
        if let sub = sub {
            let s = label(sub, size: 13.5, weight: .regular, color: colors.hippoTextMuted)
            s.numberOfLines = 0
            s.textAlignment = .center
            top.setCustomSpacing(6, after: title)
            top.addArrangedSubview(s)
        }
        stack.addArrangedSubview(padded(top, top: 20, left: 16, bottom: 14, right: 16))

        let box = UIStackView()
        box.axis = .vertical
        for i in 0..<spec.count {
            let f = spec.fields[i]
            if f.kind == .email || f.param.lowercased() == "name" || f.kind == .area { continue }
            box.addArrangedSubview(summaryRow(f, spec.value(at: i)))
        }
        if !box.arrangedSubviews.isEmpty {
            let boxBg = padded(box, top: 4, left: 14, bottom: 4, right: 14)
            boxBg.backgroundColor = colors.hippoSurfaceInput
            boxBg.layer.cornerRadius = 12
            stack.addArrangedSubview(padded(boxBg, top: 0, left: 12, bottom: 0, right: 12))
        }
        addTime()
    }

    private func summaryRow(_ f: BotFormSpec.Field, _ raw: String?) -> UIView {
        let title = label(f.label, size: 13.5, weight: .regular, color: colors.hippoTextMuted)
        title.setContentCompressionResistancePriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [title, UIView()])
        row.alignment = .center
        row.spacing = 12
        let skipped = BotFormSpec.isSkipped(raw)
        if f.kind == .priority && !skipped {
            let c = priorityColor(raw ?? "")
            let badge = PaddedLabel()
            badge.text = raw
            badge.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            badge.textColor = c
            badge.backgroundColor = c.withAlphaComponent(0.14)
            badge.layer.cornerRadius = 10
            badge.clipsToBounds = true
            row.addArrangedSubview(badge)
            return padded(row, top: 8, left: 0, bottom: 8, right: 0)
        }
        let v: String
        if f.kind == .attachments {
            let n = skipped ? 0 : BotFormSpec.attachmentNames(raw ?? "").count
            v = n == 0 ? (skipped ? HippoStrings.formNone : (raw ?? "")) : n == 1 ? HippoStrings.formOneFile : String(format: HippoStrings.formNFiles, n)
        } else {
            v = skipped ? HippoStrings.formNotSet : (raw ?? "")
        }
        let value = label(v, size: 13.5, weight: .medium, color: skipped ? colors.hippoTextMuted : colors.hippoTextPrimary)
        value.textAlignment = .right
        value.lineBreakMode = .byTruncatingTail
        value.widthAnchor.constraint(lessThanOrEqualToConstant: 190).isActive = true
        row.addArrangedSubview(value)
        return padded(row, top: 8, left: 0, bottom: 8, right: 0)
    }

    // MARK: Actions

    private func submit(_ index: Int, _ value: String) {
        guard let message = message, let spec = spec else { return }
        errorText = nil
        BotFormCardView.drafts[stepKey(index)] = nil
        if spec.pendingPrefill.contains(index) {
            // Confirming a value the server prefilled: re-send only if the visitor changed it.
            BotFormCardView.confirm(index, for: key)
            let old = spec.value(at: index)?.trimmingCharacters(in: .whitespacesAndNewlines)
            if old != value.trimmingCharacters(in: .whitespacesAndNewlines) {
                host?.botForm(submit: value, at: index, of: message)
            }
        } else {
            host?.botForm(submit: value, at: index, of: message)
        }
        // The host updates message.leadsDataArray synchronously; re-read it.
        self.spec = BotFormSpec(message: message, confirmed: BotFormCardView.confirmed(for: key))
        render()
        onNeedsLayout?()
    }

    private func countryCode(_ index: Int) -> String {
        let k = stepKey(index)
        if let code = BotFormCardView.countryCodes[k] { return code }
        var code = "+91"
        if let region = (Locale.current as NSLocale).object(forKey: .countryCode) as? String,
           let dial = isoToDigitCountryCodeDictionary[region] as? String {
            code = "+" + dial
        }
        BotFormCardView.countryCodes[k] = code
        return code
    }

    // MARK: View helpers

    private func addTime() {
        guard let message = message else { return }
        let time = changeDateToParticularFormat(message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        let t = label(time, size: 11, weight: .regular, color: colors.hippoTextMuted)
        t.textAlignment = .right
        stack.addArrangedSubview(padded(t, top: 2, left: 16, bottom: 10, right: 16))
    }

    private func errorLabel(_ text: String) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        icon.tintColor = colors.hippoError
        icon.setContentHuggingPriority(.required, for: .horizontal)
        let l = label(text, size: 12.5, weight: .medium, color: colors.hippoError)
        l.numberOfLines = 0
        let row = UIStackView(arrangedSubviews: [icon, l])
        row.spacing = 6
        row.alignment = .center
        return row
    }

    private func sendButton(enabled: Bool) -> UIButton {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)), for: .normal)
        b.layer.cornerRadius = 10
        b.widthAnchor.constraint(equalToConstant: 38).isActive = true
        b.heightAnchor.constraint(equalToConstant: 38).isActive = true
        b.setContentHuggingPriority(.required, for: .horizontal)
        styleSend(b, enabled: enabled)
        return b
    }

    private func styleSend(_ b: UIButton, enabled: Bool) {
        b.tintColor = enabled ? colors.hippoOnAccent : colors.hippoAccent.withAlphaComponent(0.5)
        b.backgroundColor = enabled ? colors.hippoAccent : colors.hippoAccentSubtle
    }

    private func iconButton(_ systemName: String, color: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)), for: .normal)
        b.tintColor = color
        b.widthAnchor.constraint(equalToConstant: 28).isActive = true
        b.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return b
    }

    /// Green check in a soft green circle.
    private func successCheck(size: CGFloat, icon: CGFloat) -> UIView {
        let v = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: icon, weight: .bold)))
        v.contentMode = .center
        v.tintColor = colors.hippoSuccess
        v.backgroundColor = colors.hippoSuccess.withAlphaComponent(0.15)
        v.layer.cornerRadius = size / 2
        v.widthAnchor.constraint(equalToConstant: size).isActive = true
        v.heightAnchor.constraint(equalToConstant: size).isActive = true
        v.setContentHuggingPriority(.required, for: .horizontal)
        return v
    }

    private func label(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: size, weight: weight)
        l.textColor = color
        return l
    }

    private func padded(_ content: UIView, top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIView {
        let wrap = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: wrap.topAnchor, constant: top),
            content.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -bottom),
            content.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: left),
            content.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -right)
        ])
        return wrap
    }
}

// MARK: - Small views

/// Input container: grey when idle, surface with an accent ring when active, red ring on error.
private final class InputBox: UIView {
    var colors = HippoConfig.shared.colorConfig
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(_ active: Bool, error: Bool) {
        let ring: UIColor? = error ? colors.hippoError : active ? colors.hippoAccent : nil
        backgroundColor = active || error ? colors.hippoSurface : colors.hippoSurfaceInput
        layer.borderWidth = ring == nil ? 0 : 1.5
        layer.borderColor = ring?.cgColor
    }

    @objc private func tapped() {
        onTap?()
    }
}

/// Upload area with a dashed accent border.
private final class DashedAreaView: UIView {
    var fill: UIColor = .clear {
        didSet { backgroundColor = fill }
    }
    var stroke: UIColor = .gray
    private let border = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = 1.5
        border.lineDashPattern = [6, 4]
        layer.addSublayer(border)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        border.strokeColor = stroke.cgColor
        border.frame = bounds
        border.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.75, dy: 0.75), cornerRadius: 12).cgPath
    }
}

private final class PaddedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + 16, height: s.height + 6)
    }
}

private final class AreaDelegate: NSObject, UITextViewDelegate {
    var onChange: (() -> Void)?
    var onBegin: (() -> Void)?
    var onEnd: (() -> Void)?

    func textViewDidChange(_ textView: UITextView) { onChange?() }
    func textViewDidBeginEditing(_ textView: UITextView) { onBegin?() }
    func textViewDidEndEditing(_ textView: UITextView) { onEnd?() }
}

private final class BlockTap: UITapGestureRecognizer {
    private let block: () -> Void

    init(_ block: @escaping () -> Void) {
        self.block = block
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire))
    }

    @objc private func fire() {
        block()
    }
}

private extension UIControl {
    /// Closure target (iOS 14+ UIAction).
    func addAction(for event: UIControl.Event = .touchUpInside, _ block: @escaping () -> Void) {
        addAction(UIAction { _ in block() }, for: event)
    }
}

// MARK: - Options popup

/// Group / priority list shown just above its field. A clear backdrop closes it on outside taps.
final class BotFormOptionsPopup: UIView {

    var onPick: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    private let colors: HippoColorConfig
    private let card = UIView()
    private let scroll = UIScrollView()
    private let list = UIStackView()
    private var cardHeight: NSLayoutConstraint!
    private weak var anchor: UIView?
    private static let rowHeight: CGFloat = 44

    init(colors: HippoColorConfig) {
        self.colors = colors
        super.init(frame: .zero)
        backgroundColor = .clear
        let backdrop = UITapGestureRecognizer(target: self, action: #selector(backdropTapped(_:)))
        backdrop.cancelsTouchesInView = false
        addGestureRecognizer(backdrop)

        card.backgroundColor = colors.hippoSurface
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 1
        card.layer.borderColor = colors.hippoBorder.cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowRadius = 14
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        addSubview(card)

        scroll.layer.cornerRadius = 14
        scroll.clipsToBounds = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(scroll)
        list.axis = .vertical
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: card.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 6),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -6),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(in window: UIWindow, above anchor: UIView, options: [String]?, picked: String?, withDots: Bool, dotColor: @escaping (String) -> UIColor) {
        self.anchor = anchor
        frame = window.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(self)
        update(options: options, picked: picked, withDots: withDots, dotColor: dotColor)
        alpha = 0
        UIView.animate(withDuration: 0.15) { self.alpha = 1 }
    }

    func update(options: [String]?, picked: String?, withDots: Bool, dotColor: @escaping (String) -> UIColor) {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let options = options, !options.isEmpty {
            for option in options {
                list.addArrangedSubview(row(option, on: option == picked, dot: withDots ? dotColor(option) : nil, tappable: true))
            }
        } else {
            list.addArrangedSubview(row(options == nil ? HippoStrings.formLoadingOptions : HippoStrings.formNoOptions, on: false, dot: nil, tappable: false))
        }
        position(count: max(1, options?.count ?? 1))
    }

    /// Above the field: its width, about 5.5 rows tall at most, then it scrolls. Falls below the
    /// field when there's no room above.
    private func position(count: Int) {
        guard let anchor = anchor, let window = window else { return }
        let a = anchor.convert(anchor.bounds, to: window)
        let height = min(CGFloat(count) * BotFormOptionsPopup.rowHeight + 12, BotFormOptionsPopup.rowHeight * 5.5 + 12)
        let top = window.safeAreaInsets.top + 8
        let bottom = window.bounds.height - window.safeAreaInsets.bottom - 8
        var y = a.minY - 6 - height
        if y < top { y = a.maxY + 6 }
        y = max(top, min(y, bottom - height))
        card.frame = CGRect(x: a.minX, y: y, width: a.width, height: height)
        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 14).cgPath
    }

    /// One option; the selected one is highlighted, never ticked.
    private func row(_ title: String, on: Bool, dot: UIColor?, tappable: Bool) -> UIView {
        let b = UIButton(type: .custom)
        b.backgroundColor = on ? colors.hippoAccentSubtle : .clear
        b.heightAnchor.constraint(equalToConstant: BotFormOptionsPopup.rowHeight).isActive = true
        let l = UILabel()
        l.text = title
        l.font = UIFont.systemFont(ofSize: 14.5, weight: on ? .medium : .regular)
        l.textColor = !tappable ? colors.hippoTextMuted : on ? colors.hippoAccent : colors.hippoTextPrimary
        l.lineBreakMode = .byTruncatingTail
        let h = UIStackView(arrangedSubviews: [l])
        h.spacing = 10
        h.alignment = .center
        h.isUserInteractionEnabled = false
        if let dot = dot {
            let d = UIView()
            d.backgroundColor = dot
            d.layer.cornerRadius = 4
            d.widthAnchor.constraint(equalToConstant: 8).isActive = true
            d.heightAnchor.constraint(equalToConstant: 8).isActive = true
            h.insertArrangedSubview(d, at: 0)
        }
        h.translatesAutoresizingMaskIntoConstraints = false
        b.addSubview(h)
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: b.leadingAnchor, constant: 14),
            h.trailingAnchor.constraint(lessThanOrEqualTo: b.trailingAnchor, constant: -14),
            h.centerYAnchor.constraint(equalTo: b.centerYAnchor)
        ])
        if tappable {
            b.addAction(UIAction { [weak self] _ in
                self?.close()
                self?.onPick?(title)
            }, for: .touchUpInside)
        } else {
            b.isUserInteractionEnabled = false
        }
        return b
    }

    @objc private func backdropTapped(_ g: UITapGestureRecognizer) {
        if !card.frame.contains(g.location(in: self)) {
            close()
        }
    }

    func close() {
        guard superview != nil else { return }
        onDismiss?()
        onDismiss = nil
        UIView.animate(withDuration: 0.12, animations: { self.alpha = 0 }, completion: { _ in self.removeFromSuperview() })
    }
}
