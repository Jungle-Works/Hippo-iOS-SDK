//
//  BotPaymentCardCell.swift
//  Hippo
//
//  Bot payment card (message_type 22) for the customer, design "Payment":
//
//  - Open: "Select a plan", one row per plan (name, description, price; the picked one tinted
//    with a navy ring), "100% secure payment" and a full-width "Proceed to Pay · price" button,
//    light until a plan is picked. A single plan is picked already.
//  - Paying: the card under a white veil with a spinner and "Processing payment…", from the
//    moment the payment starts until the payment screen closes.
//  - Paid: once the server sets custom_action.selected_id - green check, "Payment successful"
//    and Amount / Plan / Transaction ID.
//
//  The pay flow itself is unchanged (gateway choice, then the gateway's page): the card hands the
//  picked plan to PaymentMessageCellDelegate.cellButtonPressed, as the old card's button did.
//

import UIKit

final class BotPaymentCardCell: UITableViewCell {

    static let identifier = "BotPaymentCardCell"

    weak var delegate: PaymentMessageCellDelegate?

    // MARK: Shared state

    /// Picked plan id per card, so a reload keeps the pick.
    private static var picked: [String: String] = [:]
    /// Card whose Pay was tapped; becomes "processing" once the payment page opens.
    private static var pendingKey: String?
    private static var processing: Set<String> = []

    /// The payment page is opening: the tapped card shows "Processing payment…".
    static func paymentStarted() {
        if let key = pendingKey { processing.insert(key) }
    }

    /// The payment page closed, or the payment could not start.
    static func paymentEnded() {
        processing.removeAll()
        pendingKey = nil
    }

    static var isAnyProcessing: Bool {
        return !processing.isEmpty
    }

    static func isProcessing(_ message: HippoMessage) -> Bool {
        return processing.contains(key(message))
    }

    /// Paid: the server set custom_action.selected_id (as on Android, any value counts).
    static func isPaid(_ message: HippoMessage) -> Bool {
        return !(message.selectedCardId ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    static func plans(_ message: HippoMessage) -> [CustomerPayment] {
        return (message.cards ?? []).compactMap { $0 as? CustomerPayment }
    }

    private static func key(_ message: HippoMessage) -> String {
        return (message.messageUniqueID ?? "\(message.messageId ?? -1)") + "#pay"
    }

    // MARK: Views

    private let card = UIView()
    private let stack = UIStackView()
    private let veil = UIView()
    private let colors = HippoConfig.shared.colorConfig
    private var message: HippoMessage?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        veil.translatesAutoresizingMaskIntoConstraints = false
        veil.isHidden = true
        contentView.addSubview(card)
        card.addSubview(stack)
        card.addSubview(veil)
        let preferred = card.widthAnchor.constraint(equalToConstant: 324)
        preferred.priority = .defaultHigh
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10), // same left edge as chat bubbles
            card.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),
            preferred,
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            veil.topAnchor.constraint(equalTo: card.topAnchor),
            veil.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            veil.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            veil.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(message: HippoMessage) {
        self.message = message
        card.backgroundColor = colors.hippoSurface
        card.layer.borderColor = colors.hippoBorder.cgColor
        render()
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        veil.subviews.forEach { $0.removeFromSuperview() }
        veil.isHidden = true
        guard let message = message else { return }
        if BotPaymentCardCell.isPaid(message) {
            renderPaid(message)
        } else {
            renderOpen(message)
        }
    }

    private func pickedPlan(_ message: HippoMessage, _ plans: [CustomerPayment]) -> CustomerPayment? {
        if plans.count == 1 { return plans.first }
        guard let id = BotPaymentCardCell.picked[BotPaymentCardCell.key(message)] else { return nil }
        return plans.first { $0.id == id }
    }

    // MARK: Open

    private func renderOpen(_ message: HippoMessage) {
        let key = BotPaymentCardCell.key(message)
        let plans = BotPaymentCardCell.plans(message)
        let picked = pickedPlan(message, plans)
        let busy = BotPaymentCardCell.processing.contains(key)

        let title = label(HippoStrings.paySelectPlan, size: 16, weight: .semibold, color: colors.hippoTextPrimary)
        stack.addArrangedSubview(padded(title, top: 16, left: 16, bottom: 12, right: 16))

        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 8
        for plan in plans {
            list.addArrangedSubview(planRow(plan, on: plan === picked, busy: busy, key: key))
        }
        stack.addArrangedSubview(padded(list, top: 0, left: 12, bottom: 0, right: 12))

        // "100% secure payment"
        let shield = UIImageView(image: UIImage(systemName: "checkmark.shield", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)))
        shield.tintColor = colors.hippoSuccess
        let secureText = label(HippoStrings.hippoSecurePayment, size: 12.5, weight: .medium, color: colors.hippoTextMuted)
        let secure = UIStackView(arrangedSubviews: [shield, secureText])
        secure.spacing = 6
        secure.alignment = .center
        let secureRow = UIView()
        secure.translatesAutoresizingMaskIntoConstraints = false
        secureRow.addSubview(secure)
        NSLayoutConstraint.activate([
            secure.centerXAnchor.constraint(equalTo: secureRow.centerXAnchor),
            secure.topAnchor.constraint(equalTo: secureRow.topAnchor),
            secure.bottomAnchor.constraint(equalTo: secureRow.bottomAnchor)
        ])
        stack.addArrangedSubview(padded(secureRow, top: 14, left: 12, bottom: 0, right: 12))

        // Proceed to Pay
        let canPay = picked != nil && !busy
        let pay = UIButton(type: .system)
        var title2 = HippoStrings.payProceed
        if let p = picked { title2 += " · " + BotPaymentCardCell.price(p) }
        pay.setTitle(title2, for: .normal)
        pay.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        pay.titleLabel?.lineBreakMode = .byTruncatingTail
        pay.setTitleColor(canPay ? colors.hippoOnAccent : colors.hippoAccent.withAlphaComponent(0.5), for: .normal)
        pay.backgroundColor = canPay ? colors.hippoAccent : colors.hippoAccentSubtle
        pay.layer.cornerRadius = 12
        if canPay {
            pay.layer.shadowColor = colors.hippoAccent.cgColor
            pay.layer.shadowOpacity = 0.28
            pay.layer.shadowRadius = 6
            pay.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        pay.heightAnchor.constraint(equalToConstant: 46).isActive = true
        pay.isEnabled = canPay
        pay.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        stack.addArrangedSubview(padded(pay, top: 12, left: 12, bottom: 0, right: 12))
        addTime(message)

        if busy { showVeil() }
    }

    /// One plan: name + description on the left, price on the right; picked = tint + navy ring.
    private func planRow(_ plan: CustomerPayment, on: Bool, busy: Bool, key: String) -> UIView {
        let name = label(plan.title, size: 15, weight: .semibold, color: colors.hippoTextPrimary)
        let col = UIStackView(arrangedSubviews: [name])
        col.axis = .vertical
        col.spacing = 3
        if !plan.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let desc = label(plan.description, size: 12.5, weight: .regular, color: colors.hippoTextMuted)
            desc.lineBreakMode = .byTruncatingTail
            col.addArrangedSubview(desc)
        }
        let price = label(BotPaymentCardCell.price(plan), size: 15, weight: .semibold, color: colors.hippoTextPrimary)
        price.setContentHuggingPriority(.required, for: .horizontal)
        price.setContentCompressionResistancePriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [col, price])
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false

        let box = UIControl()
        box.backgroundColor = on ? colors.hippoAccentSubtle : colors.hippoSurface
        box.layer.cornerRadius = 14
        box.layer.borderWidth = on ? 1.5 : 1
        box.layer.borderColor = (on ? colors.hippoAccent : colors.hippoBorder).cgColor
        box.alpha = busy && !on ? 0.45 : 1
        row.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12),
            row.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14)
        ])
        box.addAction(UIAction { [weak self] _ in
            guard !BotPaymentCardCell.processing.contains(key) else { return }
            BotPaymentCardCell.picked[key] = plan.id
            self?.render()
        }, for: .touchUpInside)
        return box
    }

    @objc private func payTapped() {
        guard let message = message else { return }
        let key = BotPaymentCardCell.key(message)
        guard !BotPaymentCardCell.processing.contains(key),
              let plan = pickedPlan(message, BotPaymentCardCell.plans(message)) else { return }
        // Same hand-off as the old card's "Proceed to Pay" button.
        let button = PayementButton.createPaymentOption()
        button.selectedCardDetail = plan
        BotPaymentCardCell.pendingKey = key
        delegate?.cellButtonPressed(message: message, card: button)
    }

    /// White veil over the card while the payment runs.
    private func showVeil() {
        veil.backgroundColor = colors.hippoSurface.withAlphaComponent(0.94)
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = colors.hippoAccent
        spinner.startAnimating()
        let title = label(HippoStrings.payProcessing, size: 15, weight: .semibold, color: colors.hippoTextPrimary)
        let sub = label(HippoStrings.payDontClose, size: 13, weight: .regular, color: colors.hippoTextMuted)
        let col = UIStackView(arrangedSubviews: [spinner, title, sub])
        col.axis = .vertical
        col.alignment = .center
        col.spacing = 8
        col.setCustomSpacing(12, after: spinner)
        col.translatesAutoresizingMaskIntoConstraints = false
        veil.addSubview(col)
        NSLayoutConstraint.activate([
            col.centerXAnchor.constraint(equalTo: veil.centerXAnchor),
            col.centerYAnchor.constraint(equalTo: veil.centerYAnchor)
        ])
        veil.isHidden = false
    }

    // MARK: Paid

    private func renderPaid(_ message: HippoMessage) {
        // The paid plan: the one selected_id names, else the only plan there is.
        let plans = BotPaymentCardCell.plans(message)
        let plan = (message.selectedCard as? CustomerPayment) ?? (plans.count == 1 ? plans.first : nil)

        let circle = UIView()
        circle.backgroundColor = colors.hippoSuccess.withAlphaComponent(0.15)
        circle.layer.cornerRadius = 26
        let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)))
        check.tintColor = colors.hippoSuccess
        check.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(check)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 52),
            circle.heightAnchor.constraint(equalToConstant: 52),
            check.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        let title = label(HippoStrings.paySuccess, size: 17, weight: .semibold, color: colors.hippoTextPrimary)
        let top = UIStackView(arrangedSubviews: [circle, title])
        top.axis = .vertical
        top.alignment = .center
        top.spacing = 8
        if let plan = plan, !plan.title.isEmpty {
            let sub = label(String(format: HippoStrings.paySuccessText, plan.title), size: 13.5, weight: .regular, color: colors.hippoTextMuted)
            sub.textAlignment = .center
            top.addArrangedSubview(sub)
        }
        stack.addArrangedSubview(padded(top, top: 22, left: 16, bottom: 14, right: 16))

        if let plan = plan {
            let box = UIStackView()
            box.axis = .vertical
            box.addArrangedSubview(keyValue(HippoStrings.payAmount, BotPaymentCardCell.price(plan)))
            box.addArrangedSubview(keyValue(HippoStrings.payPlan, plan.title))
            if let txn = plan.transactionId, !txn.isEmpty {
                box.addArrangedSubview(keyValue(HippoStrings.payTransaction, txn))
            }
            let bg = padded(box, top: 4, left: 14, bottom: 4, right: 14)
            bg.backgroundColor = colors.hippoSurfaceInput
            bg.layer.cornerRadius = 12
            stack.addArrangedSubview(padded(bg, top: 0, left: 12, bottom: 0, right: 12))
        }
        addTime(message)
    }

    private func keyValue(_ key: String, _ value: String) -> UIView {
        let k = label(key, size: 13.5, weight: .regular, color: colors.hippoTextMuted)
        k.setContentHuggingPriority(.required, for: .horizontal)
        k.setContentCompressionResistancePriority(.required, for: .horizontal)
        let v = label(value, size: 13.5, weight: .medium, color: colors.hippoTextPrimary)
        v.textAlignment = .right
        v.lineBreakMode = .byTruncatingTail
        let row = UIStackView(arrangedSubviews: [k, v])
        row.spacing = 12
        return padded(row, top: 8, left: 0, bottom: 8, right: 0)
    }

    // MARK: Helpers

    /// "US$ 50.00" / "₹49,999": a multi-character symbol gets a space, as in the design.
    static func price(_ plan: CustomerPayment) -> String {
        let symbol = (plan.currenySymbol ?? "").trimmingCharacters(in: .whitespaces)
        var amount = (plan.amountText ?? "").trimmingCharacters(in: .whitespaces)
        if amount.isEmpty, let a = plan.amount {
            amount = a.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", a) : String(format: "%.2f", a)
        }
        if symbol.isEmpty { return amount }
        return symbol + (symbol.count > 1 ? " " : "") + amount
    }

    private func addTime(_ message: HippoMessage) {
        let time = changeDateToParticularFormat(message.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        let t = label(time, size: 11, weight: .regular, color: colors.hippoTextMuted)
        t.textAlignment = .right
        stack.addArrangedSubview(padded(t, top: 10, left: 16, bottom: 10, right: 16))
    }

    private func label(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: size, weight: weight)
        l.textColor = color
        l.numberOfLines = 1
        return l
    }

    private func padded(_ view: UIView, top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIView {
        let wrap = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: wrap.topAnchor, constant: top),
            view.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -bottom),
            view.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: left),
            view.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -right)
        ])
        return wrap
    }
}
