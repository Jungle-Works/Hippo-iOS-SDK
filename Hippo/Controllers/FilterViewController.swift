//
//  FilterViewController.swift
//  Fugu
//
//  Created by Vishal on 31/05/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import Foundation

//protocol FilterDelegate: class {
//    func newChatClicked(selectedPersonData: SearchCustomerData)
//}

protocol FilterScreenButtonsDelegate: AnyObject {
    func cancelButtonPressed()
    func resetButtonPressed()
    func applyButtonPressed()
}


class FilterViewController: UIViewController {
    
    weak var filterScreenButtonsDelegate: FilterScreenButtonsDelegate?
    
    //MARK: Screen constants
    let optionTableBackground = UIColor.veryLightBlue
    let applyButtonHeight: CGFloat = 45
    var currentSelectedOption = FilterOptionSection.status//FilterOptionSection.people
    let noDataFoundText = "No result found."
    let searchLabelText = "Search with Email, Number or Name (Enter at least three characters to search)."
    
    //MARK: Variables
//    var searchView = SearchBarHeaderView.loadView(CGRect.zero)
    
    var selectedStatus = FilterManager.shared.selectedChatStatus
//    var selectedChatType = FilterManager.shared.selectedChatType
//    var selectedAgentIds = FilterManager.shared.selectedAgentId
//    var selectedLabels = FilterManager.shared.selectedLabelId
//    var selectedDefaultChannels = FilterManager.shared.selectedChannelId
    
//    var chatTypeList = [labelWithId]()
    var statusList = [labelWithId]()
//    var labelList = [TagDetail]()
//    var channelList = [ChannelDetail]()
//    var fChannelList = [ChannelDetail]()
//    var fLabelList = [TagDetail]()
//
//    var fAgentList: [Agent] = [Agent]()
//
//    var allAgentList: [Agent]  {
//        return Business.shared.agents
//    }
    
//    var combinedChannelList = [ChannelDetail]()
//    var peopleList = [SearchCustomerData]()
//    var dateList = [DateFilterInfo]()
//    var selectedDate: DateFilterInfo?
    var isPaginationRequired = false
    var isHandleScroll = true
    
    var timer: Timer?
    
    //MARK: Outlets
    @IBOutlet weak var applyButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultTableview: UITableView!
    @IBOutlet weak var optionsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FilterManager.shared.chatStatusArray.count > 0{
            var tempStatusArr = [labelWithId]()
            tempStatusArr.append(labelWithId(label: HippoStrings.openChat, id: 1, isSelected: FilterManager.shared.chatStatusArray.filter{$0.id == 1}.first?.isSelected ?? false))
            tempStatusArr.append(labelWithId(label: HippoStrings.closedChat, id: 2, isSelected: FilterManager.shared.chatStatusArray.filter{$0.id == 2}.first?.isSelected ?? false))
            FilterManager.shared.chatStatusArray = tempStatusArr
        }
        
        
        setupController()
        setData()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        selectOptionCell()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        FilterManager.shared.resetData()
        self.filterScreenButtonsDelegate?.resetButtonPressed()
        dismissView {
            self.reloadConversationData()
        }
    }
    @IBAction func dismissButtonClicked(_ sender: UIButton) {
        self.filterScreenButtonsDelegate?.cancelButtonPressed()
        dismissView()
    }
    @IBAction func applyButtonClicked(_ sender: UIButton) {
//        guard isValidateCustomDatePicker() else {
//            return
//        }
        BussinessProperty.current.isFilterApplied = true
        updateManager()
        self.filterScreenButtonsDelegate?.applyButtonPressed()
        dismissView()
    }
    
//    class func getFilterStoryboardRoot() -> UINavigationController {
//        let filterStoryBoard = UIStoryboard(name: StoryBoardName.Filter.rawValue, bundle: nil)
//
//        guard let filterRootVC = filterStoryBoard.instantiateInitialViewController() as? UINavigationController else {
//            let vc = FilterViewController.getNewInstance()
//            let navVC = UINavigationController(rootViewController: vc)
//            return navVC
//        }
//        return filterRootVC
//    }
//    class func getNewInstance() -> FilterViewController {
//        let filterStoryBoard = UIStoryboard(name: StoryBoardName.Filter.rawValue, bundle: nil)
//        let vc = filterStoryBoard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
//        return vc
//    }
    class func getNewInstance() -> FilterViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController else {
            return nil
        }
        return vc
    }
//    private func createNewConvo(selectedCustomerData: SearchCustomerData) {
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let navigationController = appDelegate.window?.rootViewController as? UINavigationController, let homeViewController = navigationController.isControllerExist(controller: HomeViewController.self) as? HomeViewController
//            else {
//                return
//
//        }
//        homeViewController.newChatClicked(selectedPersonData: selectedCustomerData)
//    }
    
    fileprivate func selectOptionCell() {
        let indexPath = IndexPath(row: 0, section: currentSelectedOption.rawValue)
        optionsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//        if currentSelectedOption == .people {
//            updateApplyButton(hide: true)
//        }
    }
    
    private func setData() {
//        chatTypeList = FilterManager.shared.chatTypeArray
//        dateList = DateFilterInfo.cloneArray(list: FilterManager.shared.dateList)
//        selectedDate = FilterManager.shared.selectedDate?.clone()
        statusList = FilterManager.shared.chatStatusArray
//        labelList = FilterManager.shared.labelArray.clone()
//        channelList = FilterManager.shared.channelArray.clone()
//
//        fChannelList = FilterManager.shared.channelArray
//        fLabelList = FilterManager.shared.labelArray
//
//        combinedChannelList = FilterManager.shared.channelArray
//        ConversationManager.sharedInstance.selectedChannelId = -1
    }
    private func setupController() {
        self.navigationController?.setTheme()
//        setupCustomThemeOnNavigationBar(hideNavigationBar: false)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = HippoStrings.filter
        setupTableView()
        let theme = HippoConfig.shared.theme
        optionsTableView.backgroundColor = theme.backgroundColor
        resultTableview.backgroundColor = theme.backgroundColor
//        applyButtonHeightConstraint.constant = 0
                
        //Configuring FilterButton
        crossButton.setTitle("", for: .normal)
        crossButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.crossBarButtonText.count > 0 {
            crossButton.setTitle((" " + HippoConfig.shared.theme.crossBarButtonText), for: .normal)
            if HippoConfig.shared.theme.crossBarButtonFont != nil {
                crossButton.titleLabel?.font = HippoConfig.shared.theme.crossBarButtonFont
            }
            crossButton.setTitleColor(HippoConfig.shared.theme.crossBarButtonTextColor, for: .normal)
        } else {
            if HippoConfig.shared.theme.crossBarButtonImage != nil {
                crossButton.setImage(HippoConfig.shared.theme.crossBarButtonImage, for: .normal)
                crossButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
                
        resetButton.setTitleColor(HippoConfig.shared.theme.titleColorOfFilterResetButton, for: .normal)
        resetButton.backgroundColor = HippoConfig.shared.theme.backgroundColorOfFilterResetButton
//        resetButton.font = UIFont.regular(ofSize: 15.0)
        resetButton.titleLabel?.font = UIFont.regular(ofSize: 15.0)
        resetButton.setTitle(HippoStrings.reset, for: .normal)
//        applyButton.clipsToBounds = true
        
//        let group = theme.primaryButtonGroup
        let group = theme.actionableMessageButtonColor
        
//        applyButton.setTheme(type: [.fill(group: group), .text(group: group)])
//        applyButton.backgroundColor = theme.themeColor
        
//        applyButton.backgroundColor = theme.themeColor
//        applyButton.setTitleColor(theme.themeTextcolor, for: .normal)
        applyButton.backgroundColor = theme.backgroundColorOfFilterApplyButton
        applyButton.setTitleColor(theme.titleColorOfFilterApplyButton, for: .normal)
//        applyButton.font = UIFont.regular(ofSize: 15.0)
        applyButton.titleLabel?.font = UIFont.regular(ofSize: 15.0)
        applyButton.setTitle(HippoStrings.apply, for: .normal)
        
        setTheme()
//        applyButton.backgroundColor = HippoTheme.current.themeColor
//        applyButton.setTitleColor(HippoTheme.current.headerTextColor, for: .normal)
    }
    
    func setTheme() {
        let theme = HippoConfig.shared.theme
        
        view.backgroundColor = theme.backgroundColor
    }
//    private func isValidateCustomDatePicker() -> Bool {
//        guard let date = selectedDate, date.isCustomDate else {
//            return true
//        }
//        guard let startDate = date.startDate else {
//            showAlert(title: "", message: "Please select Start Date", actionComplete: nil)
//            return false
//        }
//        guard let endDate = date.endDate else {
//            showAlert(title: "", message: "Please select end Date", actionComplete: nil)
//            return false
//        }
//        let timeInterVal = endDate.timeIntervalSince(startDate)
//
//        guard timeInterVal > 0 else {
//            showAlert(title: "", message: "Start date must be before the end date", actionComplete: nil)
//            return false
//        }
//        return true
//    }
    private func updateManager() {
//        googleAnalytics(category: Category_Home_Screen, action: Action_Filter_Clicked, label: Label_Filter_Closed)
//        let isCustomDateUpdated = (selectedDate?.isCustomDate ?? false) && (FilterManager.shared.selectedDate?.startDate != selectedDate?.startDate || FilterManager.shared.selectedDate?.endDate != selectedDate?.endDate)
        
//        if selectedStatus != FilterManager.shared.selectedChatStatus || selectedChatType != FilterManager.shared.selectedChatType || selectedLabels != FilterManager.shared.selectedLabelId || selectedDefaultChannels != FilterManager.shared.selectedChannelId || FilterManager.shared.selectedDate?.id != selectedDate?.id || isCustomDateUpdated || selectedAgentIds != FilterManager.shared.selectedAgentId {
        if selectedStatus != FilterManager.shared.selectedChatStatus{
            
            FilterManager.shared.selectedChatStatus = selectedStatus
//            FilterManager.shared.selectedChatType = selectedChatType
//            FilterManager.shared.selectedLabelId = selectedLabels
//            FilterManager.shared.selectedChannelId = selectedDefaultChannels
//
            FilterManager.shared.chatStatusArray = statusList
//            FilterManager.shared.channelArray = channelList
//            FilterManager.shared.labelArray = labelList
//            FilterManager.shared.chatTypeArray = chatTypeList
//            FilterManager.shared.selectedAgentId = selectedAgentIds
//
//            FilterManager.shared.dateList = dateList
//            FilterManager.shared.selectedDate = selectedDate
//
            reloadConversationData()
        }
    }
    private func reloadConversationData(showLoader: Bool = true) {
        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let navigationController = appDelegate.window?.rootViewController as? UINavigationController, let homeViewController = navigationController.isControllerExist(controller: HomeViewController.self) as? HomeViewController
//            else { return }
//        homeViewController.getConversation(loadFromStart: true, withLoader: showLoader, isFirstTimeLoading: false, enableEndPage: false)
        
    }
    private func updateDataOnDidSelect() {
//        switch currentSelectedOption {
//        case .people:
//            peopleList.removeAll()
//            updateApplyButton(hide: true)
//        case .channels:
//            combinedChannelList = channelList
//            updateApplyButton(hide: false)
//        case .labels:
//            updateApplyButton(hide: false)
//            fLabelList = labelList
//        case .agents:
//            updateApplyButton(hide: false)
//            fAgentList = allAgentList
//        default:
//            updateApplyButton(hide: false)
//            break
//        }
//        updateApplyButton(hide: false)
        
        isPaginationRequired = false
//        searchView.searchBar.resignFirstResponder()
//        searchView.searchBar.text = nil
        reloadResultTable()
    }
//    private func updateApplyButton(hide: Bool) {
//        applyButtonHeightConstraint.constant = hide ? 0 : applyButtonHeight
//        UIView.animate(withDuration: 0.2, animations: {
//            self.view.layoutIfNeeded()
//        }) { (success) in
//
//        }
//    }
    private func dismissView(completion: (() -> Void)? = nil) {
//        searchView.searchBar.resignFirstResponder()
        self.dismiss(animated: true) {
            completion?()
        }
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == optionsTableView {
            currentSelectedOption = FilterOptionSection(rawValue: indexPath.section) ?? currentSelectedOption
            updateDataOnDidSelect()
            return
        }
        switch currentSelectedOption {
//        case .people:
//            if peopleList.isEmpty {
//                return
//            }
//            if isPaginationRequired && peopleList.count == indexPath.row {
//                return
//            }
//            ConversationManager.sharedInstance.selectedCustomerObject = peopleList[indexPath.row]
//            dismissView {
//                self.reloadConversationData()
//            }
        case .status:
            statusList[indexPath.row].isSelected = !statusList[indexPath.row].isSelected
            let id =  statusList[indexPath.row].id
            if statusList[indexPath.row].isSelected, !selectedStatus.contains(id) {
                selectedStatus.append(id)
            } else if !statusList[indexPath.row].isSelected, selectedStatus.contains(id)  {
                selectedStatus = selectedStatus.filter() { $0 != id }
            }
            reloadResultTable()
//        case .chatType:
//            chatTypeList[indexPath.row].isSelected = !chatTypeList[indexPath.row].isSelected
//            let id =  chatTypeList[indexPath.row].id
//            if chatTypeList[indexPath.row].isSelected, !selectedChatType.contains(id) {
//                selectedChatType.append(id)
//            } else if !chatTypeList[indexPath.row].isSelected, selectedChatType.contains(id)  {
//                selectedChatType = selectedChatType.filter() { $0 != id }
//            }
//            reloadResultTable()
//        case .channels:
//            handleSelectionOfchannel(indexPath: indexPath)
//        case .labels:
//            fLabelList[indexPath.row].isSelected = !fLabelList[indexPath.row].isSelected
//            let id  = fLabelList[indexPath.row].tagId ?? -1
//            if fLabelList[indexPath.row].isSelected, !selectedLabels.contains(id) {
//                selectedLabels.append(id)
//            } else if !fLabelList[indexPath.row].isSelected, selectedLabels.contains(id)  {
//                selectedLabels = selectedLabels.filter() { $0 != id }
//            }
//            reloadResultTable()
//        case .agents:
////            fLabelList[indexPath.row].isSelected = !fLabelList[indexPath.row].isSelected
//            let id  = fAgentList[indexPath.row].userId ?? fAgentList[indexPath.row].inviteId ?? -1
//            if !selectedAgentIds.contains(id) {
//                selectedAgentIds.append(id)
//            } else if selectedAgentIds.contains(id) {
//                selectedAgentIds = selectedAgentIds.filter() { $0 != id }
//            }
//            reloadResultTable()
//        case .date:
//            switch indexPath.section {
//            case 0:
//                dateList[indexPath.row].isSelected = !dateList[indexPath.row].isSelected
//                let id =  dateList[indexPath.row].id
//
//                if selectedDate?.id == id {
//                    selectedDate = nil
//                } else {
//                    selectedDate?.isSelected = false
//                    selectedDate = dateList[indexPath.row]
//                }
//                reloadResultTable()
//            default:
//                break
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == optionsTableView {
            return 0.001
        } else {
//            switch currentSelectedOption {
//            case .channels, .people, .labels, .agents:
//                return 55
//            case .status, .chatType, .date:
//                return 10
//            }
            return 10
        }
    }
//    func handleSelectionOfchannel(indexPath: IndexPath) {
//        if combinedChannelList[indexPath.row].isDefaultChannel {
//            let id =  combinedChannelList[indexPath.row].id
//            combinedChannelList[indexPath.row].isSelected = !combinedChannelList[indexPath.row].isSelected
//            if combinedChannelList[indexPath.row].isSelected, !selectedDefaultChannels.contains(id) {
//                selectedDefaultChannels.append(id)
//            } else if !combinedChannelList[indexPath.row].isSelected, selectedDefaultChannels.contains(id)  {
//                selectedDefaultChannels = selectedDefaultChannels.filter() { $0 != id }
//            }
//        } else {
//            ConversationManager.sharedInstance.selectedChannelId = combinedChannelList[indexPath.row].id
//        }
//        reloadResultTable()
//        if !searchView.searchBar.text!.isEmpty {
//            FilterManager.shared.selectedChannelId.removeAll()
//            dismissView {
//                self.reloadConversationData()
//            }
//        }
//    }
}

extension FilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == optionsTableView {
            return FilterOptionSection.count
        } else {
//            switch currentSelectedOption {
//            case .channels, .people, .labels, .status, .chatType, .agents:
//                return 1
//            case .date:
//                return 2
//            }
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == optionsTableView {
            guard let option = FilterOptionSection(rawValue: section) else {
                return 0
            }
//            return FilterManager.shouldDisplayOptionFor(option: option) ? 1 : 0
            return 1
        } else {
//            return getResultListCount(numberOfRowsInSection: section)
            return 2
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == optionsTableView {
            return nil
        } else {
//            switch currentSelectedOption {
//            case .channels, .people, .labels, .agents:
//                let frame = CGRect(x: 0, y: 0, width: windowScreenWidth, height: 60)
//                searchView.frame = frame
//                searchView.delegate = self
//                return searchView
//            case .status, .chatType, .date:
//                return UIView()
//            }
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == optionsTableView {
            return getOptionCell(for: indexPath) ?? UITableViewCell()
        } else {
            return getResultCell(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == optionsTableView {
            return 44
        } else {
//            switch currentSelectedOption {
//            case .people:
//                if peopleList.count == 0, indexPath.row == 0 {
//                    let searchString = searchView.searchBar.text!
//                    let showSelectedUser = searchString.isEmpty && ConversationManager.sharedInstance.selectedCustomerObject != nil
//                     return showSelectedUser ?  UITableView.automaticDimension : 0.001
//                }
//                fallthrough
//            default:
//                return UITableView.automaticDimension
//            }
            
//            return UITableView.automaticDimension
            return 44
        }
    }
    fileprivate func setupTableView() {
        optionsTableView.tableFooterView = UIView()
        resultTableview.tableFooterView = UIView()
        
        let bundle = FuguFlowManager.bundle
        
        optionsTableView.register(UINib(nibName: "FilterOptionTableViewCell", bundle: bundle), forCellReuseIdentifier: "FilterOptionTableViewCell")
        
//        resultTableview.register(UINib(nibName: "StartEndDateCell", bundle: bundle), forCellReuseIdentifier: "StartEndDateCell")
//        resultTableview.register(UINib(nibName: "DateFilterTableViewCell", bundle: bundle), forCellReuseIdentifier: "DateFilterTableViewCell")
//        resultTableview.register(UINib(nibName: "NoCustomersFoundTableViewCell", bundle: bundle), forCellReuseIdentifier: "NoCustomersFoundTableViewCell")
        resultTableview.register(UINib(nibName: "FilterTableViewCell", bundle: bundle), forCellReuseIdentifier: "FilterTableViewCell")
//        resultTableview.register(UINib(nibName: "ChatInfoShowMoreTableViewCell", bundle: bundle), forCellReuseIdentifier: "ChatInfoShowMoreTableViewCell")
//        resultTableview.register(UINib(nibName: "SearchCustomerTableViewCell", bundle: bundle), forCellReuseIdentifier: "SearchCustomerTableViewCell")
//        resultTableview.register(UINib(nibName: "NoCustomersFoundTableViewCell", bundle: bundle), forCellReuseIdentifier: "NoCustomersFoundTableViewCell")
//        resultTableview.register(UINib(nibName: "RecentSearchedCustomerTableViewCell", bundle: bundle), forCellReuseIdentifier: "RecentSearchedCustomerTableViewCell")
//        resultTableview.register(UINib(nibName: "FilterChannelCell", bundle: bundle), forCellReuseIdentifier: "FilterChannelCell")
    }
    
    
    fileprivate func getOptionCell(for indexPath: IndexPath) -> FilterOptionTableViewCell? {
        guard let cell = optionsTableView.dequeueReusableCell(withIdentifier: "FilterOptionTableViewCell", for: indexPath) as? FilterOptionTableViewCell, let index = FilterOptionSection(rawValue: indexPath.section) else {
            return nil
        }
        switch index {
//        case .people:
//            cell.setupCell(titleLabel: "People")
        case .status:
            cell.setupCell(titleLabel: HippoStrings.status)
//        case .chatType:
//            cell.setupCell(titleLabel: "Type")
//        case .channels:
//            cell.setupCell(titleLabel: "Channels")
//        case .labels:
//            cell.setupCell(titleLabel: "Labels")
//        case .date:
//            cell.setupCell(titleLabel: "Date")
//        case .agents:
//            cell.setupCell(titleLabel: "Agents")
        }
        return cell
    }
    
    fileprivate func getResultCell(for indexPath: IndexPath) -> UITableViewCell {
        
        switch currentSelectedOption {
//        case .people:
//            //Display cell if
//            if peopleList.count == 0 {
//                switch indexPath.row {
//                case 0:
//                    let searchString = searchView.searchBar.text!
//                    let showSelectedUser = searchString.isEmpty && ConversationManager.sharedInstance.selectedCustomerObject != nil
//                    return showSelectedUser ?  getLastSelectedUser(indexPath: indexPath) : UITableViewCell()
//                case 1:
//                    return getNoCustomerCell(indexPath: indexPath)
//                default:
//                    return UITableViewCell()
//                }
//
//            }
//            if isPaginationRequired && peopleList.count == indexPath.row {
//                return getShowMoreCell(indexPath: indexPath)
//            }
//            return  getPeopleCell(indexPath: indexPath)
        case .status:
            let field = FilterField(data: statusList[indexPath.row])
            return getFilterCellWith(field: field, indexPath: indexPath)
//        case .chatType:
//            let field = FilterField(data: chatTypeList[indexPath.row])
//            return getFilterCellWith(field: field, indexPath: indexPath)
//        case .channels:
//            if isPaginationRequired && combinedChannelList.count == indexPath.row {
//                return getShowMoreCell(indexPath: indexPath)
//            }
//            let field = FilterField(data: combinedChannelList[indexPath.row])
//
//            if searchView.searchBar.text!.isEmpty {
//                return getFilterCellWith(field: field, indexPath: indexPath)
//            } else {
//                return getChannelCell(field: field, indexPath: indexPath)
//            }
//        case .labels:
//            let field = FilterField(data: fLabelList[indexPath.row])
//            return getFilterCellWith(field: field, indexPath: indexPath)
//        case .agents:
//            let field = FilterField(data: fAgentList[indexPath.row], selectedAgentID: selectedAgentIds)
//            return getFilterCellWith(field: field, indexPath: indexPath)
//        case .date:
//            switch indexPath.section {
//            case 0:
//                let dateInfo = dateList[indexPath.row]
//                return getDateCellWith(dateInfo: dateInfo, indexPath: indexPath)
//            case 1:
//                let dateInfo = dateList.last!
//                return getCustomDateCellWith(dateInfo: dateInfo, indexPath: indexPath)
//            default:
//                return UITableViewCell()
//            }
        }
    }
//    private func getNoCustomerCell(indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "NoCustomersFoundTableViewCell", for: indexPath) as? NoCustomersFoundTableViewCell else {
//            return UITableViewCell()
//        }
//        let searchString = searchView.searchBar.text!
//        cell.noCustomersLabel.text = searchString.isEmpty ? searchLabelText : noDataFoundText
//        cell.bottomLineView.isHidden = true
//        return cell
//    }
//
//    private func getLastSelectedUser(indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "RecentSearchedCustomerTableViewCell", for: indexPath) as? RecentSearchedCustomerTableViewCell, let searchedObject = ConversationManager.sharedInstance.selectedCustomerObject else {
//            return UITableViewCell()
//        }
//        cell.delegate = self
//
//        cell.setCellData(resetProperties: true, data: searchedObject)
//
//        return cell
//    }
//
//    private func getPeopleCell(indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "SearchCustomerTableViewCell", for: indexPath) as? SearchCustomerTableViewCell, peopleList.count > indexPath.row else {
//            return UITableViewCell()
//        }
//        let newChatEnabled: Bool = Business.shared.properties.isAgentToCustomerChatEnable
//        cell.delegate = self
//
//        return cell.configureSearchDataCell(resetProperties: true, searchedCustomerData: peopleList[indexPath.row], section: indexPath.row, newChatEnabled: newChatEnabled)
//    }
    private func getFilterCellWith(field: FilterField, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as? FilterTableViewCell else {
            return UITableViewCell()
        }
        return cell.configureFilterCell(resetProperties: true, cellInfo: field)
    }
    
//    private func getDateCellWith(dateInfo: DateFilterInfo, indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "DateFilterTableViewCell", for: indexPath) as? DateFilterTableViewCell else {
//            return UITableViewCell()
//        }
//        dateInfo.isSelected = selectedDate?.id == dateInfo.id
//        return cell.configureDateCell(resetProperties: true, dateInfo: dateInfo)
//    }
//    private func getCustomDateCellWith(dateInfo: DateFilterInfo, indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "StartEndDateCell", for: indexPath) as? StartEndDateCell else {
//            return UITableViewCell()
//        }
//        cell.delegate = self
//        cell.setupCell(dateInfo: dateInfo)
//        cell.textFieldOne.becomeFirstResponder()
//        return cell
//    }
//
//    private func getChannelCell(field: FilterField, indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "FilterChannelCell", for: indexPath) as? FilterChannelCell else {
//            return UITableViewCell()
//        }
//        cell.setData(field: field)
//        return cell
//    }
//    private func getShowMoreCell(indexPath: IndexPath) ->  ChatInfoShowMoreTableViewCell {
//        guard let cell = resultTableview.dequeueReusableCell(withIdentifier: "ChatInfoShowMoreTableViewCell", for: indexPath) as? ChatInfoShowMoreTableViewCell else {
//            return ChatInfoShowMoreTableViewCell()
//        }
//        cell.selectionStyle = .none
//        cell.showMoreButton.setTitle("View More", for: .normal)
//        cell.delegate = self
//        return cell
//    }
    
    //MARK: number of rows for result table
    private func getResultListCount(numberOfRowsInSection section: Int) -> Int {
        switch currentSelectedOption {
//        case .people:
//            var count = peopleList.count
//            if isPaginationRequired && count > 0 {
//                count += 1
//            }
//
//            if peopleList.count == 0 {
//                return 2 //For placeHolder and serach response
//            }
//            return count
        case .status:
            return statusList.count
//        case .chatType:
//            return chatTypeList.count
//        case .channels:
//            var count = combinedChannelList.count
//            if isPaginationRequired && count > 0  {
//                count += 1
//            }
//            return count
//        case .labels:
//            return fLabelList.count
//        case .agents:
//            return fAgentList.count
//        case .date:
//            switch section {
//            case 0: //section for default list
//                return dateList.count
//            case 1: //Section for custom date selection
//                let isCustomDateSelected: Bool = selectedDate?.isCustomDate ?? false
//                return isCustomDateSelected ? 1 : 0
//            default:
//                return 0
//            }
        }
    }
    private func reloadResultTable() {
        DispatchQueue.main.async {
            self.isHandleScroll = false
            self.resultTableview.reloadData()
            self.isHandleScroll = true
        }
    }
}
//extension FilterViewController: ChatInfoShowMoreDelegate {
//    func buttonClicked() {
//        if currentSelectedOption == .people {
//            getPeopleData(isLoadMore: true)
//        } else if currentSelectedOption == .channels {
//            getChannelData(isLoadMore: true)
//        }
//    }
//}
//
//extension FilterViewController:  UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if isHandleScroll {
//            searchView.searchBar.resignFirstResponder()
//        }
//    }
//}
//
//
//extension FilterViewController: FilterDelegate {
//    func newChatClicked(selectedPersonData: SearchCustomerData) {
//        dismissView {
//            self.createNewConvo(selectedCustomerData: selectedPersonData)
//        }
//    }
//}
//
////MARK: Recent
//extension FilterViewController: RecentSearchedProtocol {
//    func cancelTapped() {
//        ConversationManager.sharedInstance.selectedCustomerObject = nil
//        updateManager()
//        reloadConversationData(showLoader: false)
//        self.resultTableview.reloadData()
//    }
//}
//
////MARK: Serach delegate Methods
////
//extension FilterViewController: SearchBarDelegate {
//    func searchBarDidChange(searchText: String) {
//        switch currentSelectedOption {
//        case .channels:
//            updateApplyButton(hide: true)
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(searchChannel), userInfo: nil, repeats: false)
//        case .labels:
//            filterLabels(with: searchText)
//        case .agents:
//            filterAgents(with: searchText)
//        case .people:
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(searchPeople), userInfo: nil, repeats: false)
//        case .status, .chatType, .date:
//            return
//        }
//    }
//
//    @objc private func searchPeople() {
//        getPeopleData(isLoadMore: false)
//    }
//    private func filterLabels(with searchString: String) {
//        let tempString = searchString.lowercased()
//        if tempString.isEmpty {
//            fLabelList = labelList
//            reloadResultTable()
//            return
//        }
//
//        let tempList = labelList.filter { (label) -> Bool in
//            label.searchableString.contains(tempString)
//        }
//        fLabelList = tempList
//        reloadResultTable()
//    }
//    private func filterAgents(with searchString: String) {
//        let tempString = searchString.lowercased()
//        if tempString.isEmpty {
//            fAgentList = allAgentList
//            reloadResultTable()
//            return
//        }
//
//        let tempList = allAgentList.filter { (agent) -> Bool in
//            agent.searchableString.contains(tempString)
//        }
//        fAgentList = tempList
//        reloadResultTable()
//    }
//
//    @objc private func searchChannel() {
//        getChannelData(isLoadMore: false)
//    }
//    private func getChannelData(isLoadMore: Bool) {
//        let searchString = searchView.searchBar.text!
//        FilterManager.searchChannel(with: searchString, isLoadMore: isLoadMore) {[weak self] (isSuccess, isPaginationRequired) in
//            guard isSuccess, self != nil else {
//                return
//            }
//            self?.isPaginationRequired = isPaginationRequired
//            self?.combinedChannelList = FilterManager.shared.customChannelArray
//            self?.combinedChannelList.append(contentsOf: self!.filterDefaultChannels())
//            self?.reloadResultTable()
//        }
//    }
//    private func getPeopleData(isLoadMore: Bool) {
//        let searchString = searchView.searchBar.text!
//
//        if searchString.isEmpty {
//            peopleList.removeAll()
//            resultTableview.reloadData()
//            return
//        }
//
//        FilterManager.searchPeople(with: searchString, isLoadMore: isLoadMore) {[weak self] (isSuccess, isPaginationRequired) in
//            guard isSuccess else {
//                return
//            }
//            self?.isPaginationRequired = isPaginationRequired
//            self?.peopleList = FilterManager.shared.peopleArray
//            self?.reloadResultTable()
//        }
//    }
//    private func filterDefaultChannels() -> [ChannelDetail] {
//        let searchString = searchView.searchBar.text!.lowercased()
//        if searchString.isEmpty {
//            return channelList
//        }
//        let temp = self.channelList.filter { (channel) -> Bool in
//            return channel.searchableString.contains(searchString)
//        }
//        return temp
//    }
//}
//extension FilterViewController: StartEndDateCellDelegate {
//    func startDateValueChanged(_ sender: UIDatePicker) {
//        selectedDate?.startDate = sender.date
//    }
//
//    func endDateValueChanged(_ sender: UIDatePicker) {
//        selectedDate?.endDate = sender.date
//    }
//}
