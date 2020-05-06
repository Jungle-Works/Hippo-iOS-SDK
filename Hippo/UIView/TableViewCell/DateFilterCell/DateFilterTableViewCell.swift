//
//  DateFilterTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 16/08/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class DateFilterTableViewCell: CoreTabelViewCell {

    @IBOutlet weak var radioBtnImageView: So_UIImageView!
    @IBOutlet weak var titleLabel: So_CustomLabel!
    @IBOutlet weak var descriptionLabel: So_CustomLabel!
    
    
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
            radioBtnImageView.image = #imageLiteral(resourceName: "radio_button_active")
            
            titleLabel.font = UIFont.boldProximaNova(withSize: 19)
//            titleLabel.textColor = .darkColor
//            descriptionLabel.textColor = .darkColor
        } else {
            radioBtnImageView.image = #imageLiteral(resourceName: "radio_button_deactive")
            
            titleLabel.font = UIFont.semiBoldProximaNova(withSize: 19)
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
            radioBtnImageView.tintColor = HippoTheme.current.themeColor
            radioBtnImageView.image = HippoImage.current.radioButtonOn
            descriptionLabel.font = UIFont.semiBoldProximaNova(withSize: 15)
            titleLabel.font = UIFont.semiBoldProximaNova(withSize: 17)
//            titleLabel.textColor = .darkColor
//            descriptionLabel.textColor = .darkColor
        } else {
            radioBtnImageView.image = HippoImage.current.radioButtonOff?.withRenderingMode(.alwaysOriginal)
            descriptionLabel.font = UIFont.regularProximaNova(withSize: 15)
            titleLabel.font = UIFont.regularProximaNova(withSize: 17)
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
            radioBtnImageView.image = #imageLiteral(resourceName: "radio_button_active")
            titleLabel.font = UIFont.boldProximaNova(withSize: 19)
//            titleLabel.textColor = .darkColor
//            descriptionLabel.textColor = .darkColor
        } else {
            radioBtnImageView.image = #imageLiteral(resourceName: "radio_button_deactive")
            titleLabel.font = UIFont.semiBoldProximaNova(withSize: 19)
//            titleLabel.textColor = .dirtyPurple
//            descriptionLabel.textColor = .dirtyPurple
        }
        
        return self
    }
}
