//
//  SearchBarHeaderView.swift
//  Fugu
//
//  Created by Vishal on 31/05/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
protocol SearchBarDelegate: class {
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
        let theme = HippoTheme.defaultTheme()
        self.backgroundColor = theme.backgroundColor
        searchBar.backgroundColor = theme.searchBarBackgroundColor
        searchBar.tintColor = theme.searchBarBackgroundColor
        searchBar.barTintColor = theme.searchBarBackgroundColor
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = theme.headerTextColor
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
