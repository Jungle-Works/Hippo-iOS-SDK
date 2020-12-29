//
//  BotTableView.swift
//  Fugu
//
//  Created by Vishal on 04/05/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol BotTableDelegate: class {

    func sendButtonClicked(with object: BotAction)
}

class BotTableView: UIView {
    
    //MARK: Variables
    var selectedRow = -1
    var listArray = [BotAction]()
    weak var delegate: BotTableDelegate?
    
    @IBOutlet weak var pickerSelectorView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var dismissView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendButton.setTitle(HippoStrings.sendTitle, for: .normal)
        cancelButton.setTitle(HippoStrings.cancel, for: .normal)
        addGesture()
        setLayer()
        setTheme()
    }
    @IBAction func sendButtonClicked(_ sender: Any) {
        let selectedCellIndex = pickerView.selectedRow(inComponent: 0)
        
//        guard listArray[selectedCellIndex].id != BotAction.defaultId else {
//            dismiss()
//            return
//        }
        delegate?.sendButtonClicked(with: listArray[selectedCellIndex])
        dismiss()
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss()
    }
    
    
    class func loadView(_ frame: CGRect) -> BotTableView {
        let array = FuguFlowManager.bundle?.loadNibNamed("BotTableView", owner: self, options: nil)
        let view: BotTableView? = array?.first as? BotTableView
        view?.frame = frame
        guard let customView = view else {
            return BotTableView()
        }
        return customView
    }
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.dismissView.addGestureRecognizer(tapGesture)
    }
    
    func setTheme() {
//        let theme = HippoTheme.defaultTheme()
        pickerView.backgroundColor = UIColor.veryLightBlue
        pickerView.tintColor = UIColor.gray
        
    }
    func setLayer() {
        pickerSelectorView.backgroundColor = UIColor.lightGray
    }
    
    func setupCell(_ array: [BotAction]) {
        listArray = array
//        listArray.append(BotAction.dummyYeloConsent())
//        listArray.append(BotAction.dummyTookanConsent())
        
        if listArray.isEmpty {
//            listArray.append(BotAction.objectForEmptyList())
        } else {
//            listArray.append(BotAction.noneObject())
        }
        
        setupPickerview()
//        sendButton.isHidden = true
        pickerView.reloadAllComponents()
        selectedRow = -1
        pickerView.selectRow(pickerView.numberOfRows(inComponent: 0) - 1, inComponent: 0, animated: false)
        pickerView.reloadAllComponents()
    }
    
    @objc func dismiss() {
        delegate = nil
        selectedRow = -1
        pickerView.selectRow(listArray.count - 1, inComponent: 0, animated: false)
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }

    }
}

extension BotTableView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listArray.count
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedText = NSMutableAttributedString(string: listArray[row].botName )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.regular(ofSize: 13.0),
            .foregroundColor: UIColor.black.withAlphaComponent(0.8),
            .paragraphStyle: paragraphStyle
        ]
        let Selected: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.regular(ofSize: 13.0),
            .paragraphStyle: paragraphStyle
        ]
        if row == pickerView.selectedRow(inComponent: component) {
            attributedText.addAttributes(Selected, range: NSMakeRange(0, attributedText.length))
        } else {
            attributedText.addAttributes(defaultAttributes, range: NSMakeRange(0, attributedText.length))
        }
        
//        if selectedRow < 0, listArray[row].id == BotAction.defaultId {
//            attributedText.addAttributes(Selected, range: NSMakeRange(0, attributedText.length))
//        }
        return attributedText
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        pickerView.reloadAllComponents()
        sendButton.isHidden = false
        
//        if listArray[row].id == BotAction.defaultId {
//            sendButton.isHidden = true
//        } else {
//            sendButton.isHidden = false
//        }
        
    }
    
    func setupPickerview() {
        pickerView.showsSelectionIndicator = false
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
}

