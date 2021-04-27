//
//  DateTimePicker.swift
//  Hippo
//
//  Created by Arohi Magotra on 22/04/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation

protocol DateTimePickerDelegate : class {
    func dateSelected(selectedDate : String)
}


final
class DateTimePicker : UIViewController{
    
    //MARK:- Variables
    private var outputDateFormat = ""
    var message : HippoMessage?
    weak var delegate : DateTimePickerDelegate?
    var dateFormatHash = [String : String]()
    
    
    //MARK:- IBOutlets
    @IBOutlet private var picker : UIDatePicker!
    @IBOutlet private var textField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatHash["YYYY-MM-DD HH:mm:ss"] = "yyyy-MM-dd HH:mm:ss"
        dateFormatHash["YYYY-MM-DD"] = "yyyy-MM-dd"
        
        picker?.locale = .current
        if #available(iOS 14.0, *) {
            picker?.preferredDatePickerStyle = .inline
        }
        picker?.addTarget(self, action: #selector(handleDateSelection), for: .valueChanged)
        setDateMode()
    }
   
    
    private func setDateMode() {
        switch message?.actionableMessage?.botResponseType {
            case .date:
                picker?.datePickerMode = .date
            case .dateTime:
                picker?.datePickerMode = .dateAndTime
            case .time:
                picker?.datePickerMode = .time
            case .none:
                break
        }
        switch message?.actionableMessage?.allowedDateTime {
            case .all:
                break
            case .future:
                picker?.minimumDate = Date()
                picker?.maximumDate = nil
            case .past:
                picker?.maximumDate = Date()
                picker?.minimumDate = nil
            case .none:
                break
        }
        
        outputDateFormat = message?.actionableMessage?.dateTimeFormat ?? ""
        if let format = dateFormatHash[outputDateFormat] {
            textField.text = picker.date.toString(with: format)
        }else {
            if outputDateFormat == "milliseconds" {
                textField.text = String(picker.date.toMillis())
            }else {
                textField.text = picker.date.toString(with: outputDateFormat)
            }
        }
    }
    
    
    @objc func handleDateSelection() {
        guard let picker = picker else { return }
        if let format = dateFormatHash[outputDateFormat] {
            textField.text = picker.date.toString(with: format)
        }else {
            if outputDateFormat == "milliseconds" {
                textField.text = String(picker.date.toMillis())
            }else {
                textField.text = picker.date.toString(with: outputDateFormat)
            }
        }
        print("Selected date/time:", picker.date)
    }
    
    @IBAction func dismissView(){
        self.delegate?.dateSelected(selectedDate: textField.text ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
