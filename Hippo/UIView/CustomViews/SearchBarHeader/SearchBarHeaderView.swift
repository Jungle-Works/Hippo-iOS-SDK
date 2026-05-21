//
//  SearchBarHeaderView.swift
//  Fugu
//
//  Created by Vishal on 31/05/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
protocol SearchBarDelegate: AnyObject {
    func searchBarDidChange(searchText: String)
}

class SearchBarHeaderView: UIView {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: SearchBarDelegate?
   
    override func awakeFromNib() {
        searchBar.delegate = self
    }
    class func loadView(_ frame: CGRect) -> SearchBarHeaderView {
        let array = FuguFlowManager.bundle?.loadNibNamed("SearchBarHeaderView", owner: self, options: nil)
        let view: SearchBarHeaderView? = array?.first as? SearchBarHeaderView
        view?.frame = frame
        guard let customView = view else {
            return SearchBarHeaderView()
        }
        customView.setTheme()
        return customView
    }
    
    func setTheme() {
        let theme = HippoConfig.shared.theme
        self.backgroundColor = theme.backgroundColor
        searchBar.backgroundColor = theme.backgroundColor//theme.searchBarBackgroundColor
        searchBar.tintColor = theme.searchBarBackgroundColor
        searchBar.barTintColor = theme.searchBarBackgroundColor
        
        searchBar.searchTextField.textColor = theme.headerTextColor
        searchBar.searchTextField.tintColor = theme.headerTextColor
    }
}

extension SearchBarHeaderView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBarDidChange(searchText: searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
