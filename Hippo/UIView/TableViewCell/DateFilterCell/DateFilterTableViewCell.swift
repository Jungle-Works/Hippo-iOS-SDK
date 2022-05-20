//
//  DateFilterTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 16/08/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class DateFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var radioBtnImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DateFilterTableViewCell {
    func resetPropertiesOfDateCell() {
        selectionStyle = .none
    }

    func configureDateCell(resetProperties: Bool, dateCell: DateCellField, selectedDateCell: DateCellField?) -> DateFilterTableViewCell {
        if resetProperties {
            resetPropertiesOfDateCell()
        }
        
        titleLabel.text = dateCell.name ?? ""
        descriptionLabel.text = dateCell.description ?? ""
        
        if let selectedField = selectedDateCell, selectedField.isEqualTo(lhs: dateCell, rhs: selectedField) {
            radioBtnImageView.image = UIImage(named: "radio_button_active-1", in: FuguFlowManager.bundle, compatibleWith: nil)
            
            titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
//            titleLabel.textColor = .darkColor
//            descriptionLabel.textColor = .darkColor
        } else {
            radioBtnImageView.image = UIImage(named: "radio_button_deactive-1", in: FuguFlowManager.bundle, compatibleWith: nil)
            
            titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
//            titleLabel.textColor = .dirtyPurple
//            descriptionLabel.textColor = .dirtyPurple
        }
        
        return self
    }
    func configureDateCell(resetProperties: Bool, dateInfo: DateFilterInfo) -> DateFilterTableViewCell {
        if resetProperties {
            resetPropertiesOfDateCell()
        }
        
        titleLabel.text = dateInfo.name
        descriptionLabel.text = dateInfo.description
        
        if dateInfo.isSelected {
            radioBtnImageView.tintColor = HippoTheme.defaultTheme().themeColor
            radioBtnImageView.image = UIImage(named: "radio_button_active-1", in: FuguFlowManager.bundle, compatibleWith: nil)
            descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//            titleLabel.textColor = .darkColor
//            descriptionLabel.textColor = .darkColor
        } else {
            radioBtnImageView.image = UIImage(named: "radio_button_deactive-1", in: FuguFlowManager.bundle, compatibleWith: nil)
            descriptionLabel.font = UIFont.regular(ofSize: 15)
            titleLabel.font = UIFont.regular(ofSize: 15)
//            titleLabel.textColor = .dirtyPurple
//            descriptionLabel.textColor = .dirtyPurple
        }
        
        return self
    }
    
    func configureCustomCell(resetProperties: Bool, dateCell: String, selectedDateCell: String?) -> DateFilterTableViewCell {
        if resetProperties {
            resetPropertiesOfDateCell()
        }
        
        titleLabel.text = dateCell
        
        if let selectedField = selectedDateCell, dateCell == selectedField {
            radioBtnImageView.image = UIImage(named: "radio_button_active-1", in: FuguFlowManager.bundle, compatibleWith: nil)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
//            titleLabel.textColor = .darkColor
//            descriptionLabel.textColor = .darkColor
        } else {
            radioBtnImageView.image = UIImage(named: "radio_button_deactive-1", in: FuguFlowManager.bundle, compatibleWith: nil)
            titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
//            titleLabel.textColor = .dirtyPurple
//            descriptionLabel.textColor = .dirtyPurple
        }
        
        return self
    }
}

struct DateCellField {
    var name: String?
    var description: String?
    var start_date: String?
    var end_date: String?
    
    init(name: String, description: String, start_date: String, end_date: String) {
        self.name = name
        self.description = description
        self.start_date = start_date
        self.end_date = end_date
    }
    
    func isEqualTo(lhs: DateCellField, rhs: DateCellField) -> Bool {
        let areEqual = lhs.name == rhs.name &&
            lhs.description == rhs.description &&
            lhs.start_date == rhs.start_date &&
            lhs.end_date == rhs.end_date
        
        return areEqual
    }
}

