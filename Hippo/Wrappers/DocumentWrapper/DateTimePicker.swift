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
    
    //MARK:- IBOutlets
    @IBOutlet private var picker : UIDatePicker!
    @IBOutlet private var textField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        textField.text = picker.date.toString(with: outputDateFormat)
    }
    
    
    @objc func handleDateSelection() {
        guard let picker = picker else { return }
        textField.text = picker.date.toString(with: outputDateFormat)
        print("Selected date/time:", picker.date)
    }
    
    @IBAction func dismissView(){
        self.delegate?.dateSelected(selectedDate: textField.text ?? "")
        self.dismiss(animated: true, completion: nil)
    }
}
