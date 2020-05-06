//
//  StartEndDateCell.swift
//  HippoAgent
//
//  Created by Vishal on 30/08/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField


protocol StartEndDateCellDelegate: class {
    func startDateValueChanged(_ sender: UIDatePicker)
    func endDateValueChanged(_ sender: UIDatePicker)
}

class StartEndDateCell: CoreTabelViewCell {

    @IBOutlet weak var textFieldTwo: JVFloatLabeledTextField!
    @IBOutlet weak var textFieldOne: JVFloatLabeledTextField!
    @IBOutlet weak var containerView: UIView!
    
    let startDatePicker: UIDatePicker = UIDatePicker()
    let endDatePicker: UIDatePicker = UIDatePicker()
    var dateInfo: DateFilterInfo?
    
    weak var delegate: StartEndDateCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDateTimePicker()
        setupFields()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    internal func setDateTimePicker() {
        startDatePicker.maximumDate = Date()
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)

        endDatePicker.maximumDate = Date()
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
    }
    internal func setupFields() {
        textFieldTwo.delegate = self
        textFieldTwo.inputView = endDatePicker
        textFieldTwo.placeholder = "Select End Date"
        
        textFieldOne.delegate = self
        textFieldOne.inputView = startDatePicker
        textFieldOne.placeholder = "Select Start Date"
    }
    
    func setupCell(dateInfo: DateFilterInfo) {
        self.dateInfo = dateInfo
        
        if let endDate = dateInfo.endDate {
//            startDatePicker.maximumDate = endDate
            endDatePicker.setDate(endDate, animated: false)
        }
        if let startDate = dateInfo.startDate {
            startDatePicker.setDate(startDate, animated: false)
        }
        
        setupFields()
    
        setDateInTextfield()
    }
    
    @objc func startDateChanged(_ sender: UIDatePicker) {
        dateInfo?.startDate = sender.date
//        endDatePicker.minimumDate = sender.date
        
        setDateInTextfield()
        
        delegate?.startDateValueChanged(sender)
    }
    
    @objc func endDateChanged(_ sender: UIDatePicker) {
//        startDatePicker.maximumDate = sender.date
        dateInfo?.endDate = sender.date
        setDateInTextfield()
        delegate?.endDateValueChanged(sender)
    }
    
    internal func setDateInTextfield() {
        
        textFieldOne.text = dateInfo?.startDate?.toString(with: .broadcastDate) ?? ""
        textFieldTwo.text = dateInfo?.endDate?.toString(with: .broadcastDate) ?? ""
    }
}

extension StartEndDateCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        Helper.enableIQKeyboard()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       Helper.disableIQKeyboard()
    }
}
