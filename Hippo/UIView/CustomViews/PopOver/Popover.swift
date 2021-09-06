//
//  Popover.swift
//  Hippo
//
//  Created by Arohi Magotra on 09/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit

final
class LCPopover: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    // Public properties
    var sender = UIView()
    var dataList = [String]()
    var size: CGSize = CGSize(width: 250, height: 219)
    var arrowDirection: UIPopoverArrowDirection = .any
    var backgroundColor: UIColor = .white
    var borderColor: UIColor = .clear
    var borderWidth: CGFloat = 2
    var barHeight: CGFloat = 44
    var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 19)
    var titleColor: UIColor = .orange
    var textFont: UIFont = UIFont.systemFont(ofSize: 17)
    var textColor: UIColor = .black
    var selectedData: String?
    
    // Public closures
    var didSelectDataHandler: ((_ selectedData: String?) -> ())?
    
    // Private constants
    fileprivate let cellIdentifier = "Cell"
    
    // Private properties
    fileprivate var navigationBar: UINavigationBar!
    fileprivate var titleLabel: UILabel!
    fileprivate var tableView: UITableView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(for sender: UIView, title: String = "", didSelectDataHandler: ((_ selectedData: String?) -> ())? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .popover
        setSourceView(sender)
        self.sender = sender
        self.title = title
        self.didSelectDataHandler = didSelectDataHandler
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationBar()
        addTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setProperties()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Set position for the popover coordinating with the sender
    func setSourceView(_ sender: UIView) {
        guard let popoverPC = popoverPresentationController else { return }
        popoverPC.sourceView = sender
        popoverPC.sourceRect = sender.bounds
        popoverPC.delegate = self
        
    }
    
    func reloadData() {
        if tableView != nil {
            setTableView()
            tableView.reloadData()
        }
    }
    
    func hideTableView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Private Methods
    
    // Set properties based on options passed to the initializer
    fileprivate func setProperties() {
        guard let popoverPC = popoverPresentationController else { return }
        popoverPC.permittedArrowDirections = arrowDirection
        popoverPC.backgroundColor = backgroundColor
        
        preferredContentSize = size
        view.frame.size = size
        view.superview?.layer.cornerRadius = 0
        view.superview?.layer.borderWidth = borderWidth
        view.superview?.layer.borderColor = borderColor.cgColor
        
        setNavigationBar()
        setTableView()
    }
    
    // Add navigation bar and table view
    fileprivate func addNavigationBar() {
        if barHeight == 0 { return }
        
        navigationBar = UINavigationBar()
        titleLabel = UILabel()
        navigationBar.addSubview(titleLabel)
        view.addSubview(navigationBar)
    }
    
    fileprivate func addTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
    }
    
    // Set navigation bar properties
    fileprivate func setNavigationBar() {
        if barHeight == 0 { return }
        
        // Set navigation bar
        navigationBar.frame = CGRect(x: 0, y: 0, width: size.width, height: barHeight)
        
        // Set title
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.text = self.title ?? ""
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .center
        titleLabel.frame.origin = CGPoint(x: (size.width - titleLabel.frame.width)/2, y: (barHeight - titleLabel.frame.height)/2)
    }
    
    // Set table view properties
    fileprivate func setTableView() {
        tableView.frame = CGRect(x: 0, y: barHeight, width: size.width, height: size.height - barHeight)
        tableView.separatorInset.left = 0
        tableView.separatorColor = .black
        tableView.isScrollEnabled = true
    }
   
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataList.count == 0{
            removeLabel()
            addLabel()
            tableView.isHidden = true
        }else{
            removeLabel()
            tableView.isHidden = false
        }
        return dataList.count
    }
    
    private func addLabel(){
        let label = UILabel()
        label.text = HippoStrings.noDataFound
        label.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y/2, width: self.view.frame.size.width, height: self.view.frame.size.height)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.tag = -99
        self.view.addSubview(label)
    }
    
    private func removeLabel(){
        let labelArr = self.view.subviews.filter{$0.tag == -99}
        for label in labelArr{
            label.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else{
            return UITableViewCell()
        }
        
        cell.textLabel?.text = dataList[indexPath.row]
        cell.textLabel?.font = textFont
        cell.textLabel?.textColor = textColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        didSelectDataHandler?(dataList[indexPath.row])
    }
    
    // MARK: - PopoverPC Delegate Methods
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

