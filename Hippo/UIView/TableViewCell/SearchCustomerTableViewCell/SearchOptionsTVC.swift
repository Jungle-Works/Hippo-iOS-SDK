//
//  SearchOptionsTVC.swift
//  HippoAgent
//
//  Created by soc-admin on 18/05/22.
//  Copyright © 2022 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

enum SearchOptionType{
    case searchBy
    case comparisonFilter
}

protocol SearchOptionProtocol: AnyObject {
    func didSelecteOption(_ index: Int, _ type: SearchOptionType)
    func didTapAdvanceSearch()
}

class SearchOptionsTVC: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var viewAdvancedSearch: UIView!
    @IBOutlet weak var viewSearchOption: UIView!
    @IBOutlet weak var btnAdvanceSearch: UIButton!
    
    // MARK: - Properties
    var dropDown: DropDown?
    weak var delegate: SearchOptionProtocol?
    var optionType: SearchOptionType = .searchBy
    var selectedIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.textColor = HippoTheme.defaultTheme().headerTextColor
        bgView.backgroundColor = HippoTheme.defaultTheme().backgroundColor
        btnDropDown.setTitleColor(.themeColor, for: .normal)
        btnAdvanceSearch.setTitleColor(HippoTheme.defaultTheme().headerTextColor, for: .normal)
        btnAdvanceSearch.tintColor = HippoTheme.defaultTheme().headerTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func btnDDTapped(_ sender: Any) {
        if let _ = DropDown.VisibleDropDown{
            dropDown?.hide()
        }else{
            dropDown?.show()
        }
    }
    @IBAction func btnAdvanceSearchTapped(_ sender: Any) {
        delegate?.didTapAdvanceSearch()
    }
}

// MARK: -  ConfigureCell
extension SearchOptionsTVC {
    
    func configure(with ddData: [String], title: String, optionType: SearchOptionType, selectedVal: String, isAdvancedSearchEnabled: Bool){
        lblTitle.text = title
        btnDropDown.setTitle(selectedVal, for: .normal)
        self.optionType = optionType
        selectedIndex = ddData.firstIndex(of: selectedVal) ?? 0
        
        viewSearchOption.isHidden = !isAdvancedSearchEnabled
        viewAdvancedSearch.isHidden = optionType == .comparisonFilter
        
        setUpDropDown(with: ddData)
    }
    
    func setUpDropDown(with dataSource: [String]){
        dropDown = DropDown(anchorView: btnDropDown, dataSource: dataSource)
        dropDown?.selectionBackgroundColor = .veryLightBlue
        dropDown?.selectRow(at: selectedIndex)
        dropDown?.backgroundColor = HippoTheme.defaultTheme().backgroundColor
        dropDown?.textColor = HippoTheme.defaultTheme().headerTextColor
        dropDown?.selectedTextColor = .themeColor
        dropDown?.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            btnDropDown.setTitle(item, for: .normal)
            delegate?.didSelecteOption(index, optionType)
        }
        
        fuguDelay(0.0) {
            self.dropDown?.bottomOffset = CGPoint(x: 0, y: (self.dropDown?.anchorView?.plainView.bounds.height)!)
        }
    }
    
}

