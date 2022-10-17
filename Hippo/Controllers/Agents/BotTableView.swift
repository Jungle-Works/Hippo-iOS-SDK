//
//  BotTableView.swift
//  Fugu
//
//  Created by Vishal on 04/05/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol BotTableDelegate: class {
    
    func sendButtonClicked(with object: BotAction?, customObj: CustomBot?)
}

class BotTableView: UIView {
    
    //MARK: Variables
    var selectedBotAction: Any?
    var listArray = [BotAction]()
    var customBots = [CustomBot]()
    var filterListArray = [BotAction]()
    var filterCustomBots = [CustomBot]()
    weak var delegate: BotTableDelegate?
    
    @IBOutlet weak var pickerSelectorView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var lblNoBot: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendButton.setTitle(HippoStrings.sendTitle, for: .normal)
        cancelButton.setTitle(HippoStrings.cancel.capitalized, for: .normal)
        addGesture()
        setTheme()
        setupTblview()
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        guard let selectedBotAction = selectedBotAction else {return}
        
        if let defaultAct = selectedBotAction as? BotAction {
            delegate?.sendButtonClicked(with: defaultAct, customObj: nil)
        }
        
        if let customAct = selectedBotAction as? CustomBot {
            delegate?.sendButtonClicked(with: nil, customObj: customAct)
        }
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
        //        pickerView.backgroundColor = UIColor.veryLightBlue
        //        pickerView.tintColor = UIColor.gray
        tblView.backgroundColor = UIColor.veryLightBlue
    }
    
    func setupCell(_ array: [BotAction], customBot: [CustomBot]?) {
        listArray = array
        filterListArray = array
        
        if let customBot = customBot {
            customBots = customBot
            filterCustomBots = customBot
        }
        
        //        listArray.append(BotAction.dummyYeloConsent())
        //        listArray.append(BotAction.dummyTookanConsent())
        
        //        setupPickerview()
        //        sendButton.isHidden = true
        lblNoBot.isHidden = true
        addKeyboardObserver()
        tblView.reloadData()
    }
    
    @objc func dismiss() {
        delegate = nil
        selectedBotAction = nil
        searchBar.text = ""
        bottomConst.constant = 0
        NotificationCenter.default.removeObserver(self)
        pickerView.selectRow(listArray.count - 1, inComponent: 0, animated: false)
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

        if endFrameY >= UIScreen.main.bounds.size.height {
            self.bottomConst?.constant = 0.0
        } else {
            self.bottomConst?.constant = -((endFrame?.size.height ?? 0.0) - 32)
        }

        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.layoutIfNeeded() },
            completion: nil)
    }
    
}

//extension BotTableView: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return listArray.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let attributedText = NSMutableAttributedString(string: listArray[row].botName )
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .center
//
//        let defaultAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.regular(ofSize: 13.0),
//            .foregroundColor: UIColor.black.withAlphaComponent(0.8),
//            .paragraphStyle: paragraphStyle
//        ]
//        let Selected: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor.black,
//            .font: UIFont.regular(ofSize: 13.0),
//            .paragraphStyle: paragraphStyle
//        ]
//        if row == pickerView.selectedRow(inComponent: component) {
//            attributedText.addAttributes(Selected, range: NSMakeRange(0, attributedText.length))
//        } else {
//            attributedText.addAttributes(defaultAttributes, range: NSMakeRange(0, attributedText.length))
//        }
//
////        if selectedRow < 0, listArray[row].id == BotAction.defaultId {
////            attributedText.addAttributes(Selected, range: NSMakeRange(0, attributedText.length))
////        }
//        return attributedText
//    }
//
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 35
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedRow = row
//        pickerView.reloadAllComponents()
//        sendButton.isHidden = false
//
////        if listArray[row].id == BotAction.defaultId {
////            sendButton.isHidden = true
////        } else {
////            sendButton.isHidden = false
////        }
//
//    }
//
//    func setupPickerview() {
//        pickerView.showsSelectionIndicator = false
//        pickerView.delegate = self
//        pickerView.dataSource = self
//    }
//
//}



extension BotTableView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? filterListArray.count : filterCustomBots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BotTVC") as! BotTVC
        cell.lblTxt.text = indexPath.section == 0 ? filterListArray[indexPath.row].botName : filterCustomBots[indexPath.row].group_name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBotAction = indexPath.section == 0 ? filterListArray[indexPath.row] : filterCustomBots[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 36))
        headerView.backgroundColor = UIColor.veryLightBlue
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Custom Bots"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filterListArray.isEmpty && filterCustomBots.isEmpty{
            return CGFloat.leastNonzeroMagnitude
        }
        if filterCustomBots.isEmpty{
            return CGFloat.leastNonzeroMagnitude
        }
        return section == 0 ? CGFloat.leastNonzeroMagnitude : 36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func setupTblview() {
        let xib = UINib(nibName: "BotTVC", bundle: FuguFlowManager.bundle)
        tblView.register(xib, forCellReuseIdentifier: "BotTVC")
        tblView.delegate = self
        tblView.dataSource = self
        searchBar.delegate = self
        tblView.tableFooterView = UIView()
        
        if #available(iOS 15.0, *){
            self.tblView.sectionHeaderTopPadding = 0.0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBot(with: searchText)
    }
    
    func searchBot(with searchText: String){
        self.searchBar.showsCancelButton = true
        
        filterListArray.removeAll()
        filterCustomBots.removeAll()
        
        filterListArray = searchText.isEmpty ? listArray : listArray.filter { $0.botName.lowercased().contains(searchText.lowercased()) }
        filterCustomBots = searchText.isEmpty ? customBots : customBots.filter { $0.group_name.lowercased().contains(searchText.lowercased()) }

        self.tblView.reloadData()
    
        lblNoBot.isHidden = !(filterListArray.isEmpty && filterCustomBots.isEmpty)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
        searchBar.text = ""
        self.searchBar.showsCancelButton = false
        filterListArray = listArray
        filterCustomBots = customBots
        lblNoBot.isHidden = true
        tblView.reloadData()
    }
}
