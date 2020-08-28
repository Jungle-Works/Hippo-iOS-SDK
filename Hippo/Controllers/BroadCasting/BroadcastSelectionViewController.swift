//
//  BroadcastSelectionViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol BroadcastListViewDelegate: class {
    func broadcasterUpdated(broadcaster: HippoBroadcaster)
}

class BroadcastSelectionViewController: UIViewController {
    
    //MARK: Constants
    let heightFoHeader: CGFloat = 24
    
    //MARK: Variables
    var broadcaster: HippoBroadcaster?
    var screenType: BroadCastScreenRow?
    var agents = [UserDetail]()
    var teams = [TagDetail]()
    var selectedAgents = [UserDetail]()
    weak var delegate: BroadcastListViewDelegate?
    
    //MARK: Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyButtonBottomConstraint: NSLayoutConstraint!
    //Loading view
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loaderImage: UIImageView!
    @IBOutlet weak var loaderView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopLoading()
        setData()
        setUpView()
        setupTableView()
    }
    
    @IBAction func applyButtonClicked(_ sender: Any) {
        guard let type = screenType else {
            return
        }
        switch type {
        case .selectTeam:
            //Check for going back or opening select agent screen
            if broadcaster?.selectedTeam?.tagId == -100 {
                updateAndDismiss()
            } else if broadcaster?.selectedTeam != nil, broadcaster != nil  {
                animateScreenLoading()
            } else {
               updateAndDismiss()
            }
        default:
            updateAndDismiss()
        }
        
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    class func get(manager: HippoBroadcaster, type: BroadCastScreenRow) -> BroadcastSelectionViewController? {
        let storyboard = UIStoryboard(name: "HippoBroadCast", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "BroadcastSelectionViewController") as? BroadcastSelectionViewController
        vc?.broadcaster = manager
        vc?.screenType = type
        return vc
    }
}

extension BroadcastSelectionViewController {
    func updateAndDismiss() {
        if broadcaster != nil {
            delegate?.broadcasterUpdated(broadcaster: broadcaster!.copy())
        }
        backButtonAction(UIButton())
    }
    internal func setData() {
        guard let type = screenType else {
            return
        }
        
        switch type {
        case .selectTeam:
            teams = broadcaster?.teams ?? []
            tableView.allowsMultipleSelection = true
            tableView.allowsSelection = true
        case .selectAgent:
            agents = broadcaster?.getSelectedTeamAgent() ?? []
            tableView.allowsMultipleSelection = true
            tableView.allowsSelection = true
        case .showAgent:
            selectedAgents = broadcaster?.getAllSelectedAgent() ?? []
            tableView.allowsSelection = false
        default:
            return
        }
        
    }
    internal func setUpView() {
        self.navigationController?.setTheme()
        
       
        
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
            if HippoConfig.shared.theme.leftBarButtonFont != nil {
                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            }
            backButton.setTitleColor(HippoConfig.shared.theme.leftBarButtonTextColor, for: .normal)
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
                backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
        guard let type = screenType else {
            return
        }
        switch  type {
        case .selectTeam:
            applyButton.isHidden = true
            self.navigationItem.title = HippoConfig.shared.strings.selectTeamsString
        case .selectAgent:
            
            applyButton.isHidden = false
            self.navigationItem.title = HippoStrings.selectString.trimWhiteSpacesAndNewLine() + " " + HippoConfig.shared.strings.displayNameForCustomers.trimWhiteSpacesAndNewLine()
        case .showAgent:
            applyButton.isHidden = true
            self.navigationItem.title = HippoConfig.shared.strings.selectedString.trimWhiteSpacesAndNewLine() + " " + HippoConfig.shared.strings.displayNameForCustomers.trimWhiteSpacesAndNewLine()
        default:
            self.navigationItem.title = HippoConfig.shared.theme.broadcastHeader
        }
        handleApplyButtonView()
    }
    
    func handleApplyButtonView() {
        applyButton.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        applyButton.setTitleColor(HippoConfig.shared.theme.headerTextColor, for: .normal)
        
        guard let type = screenType else {
            return
        }
        switch  type {
        case .selectAgent:
            applyButton.isHidden = false
            applyButtonBottomConstraint.constant = 0
        case .selectTeam:
            applyButton.isHidden = false
            applyButtonBottomConstraint.constant = 0
        default:
            applyButton.isHidden = true
            applyButtonBottomConstraint.constant = -applyButton.frame.height
        }
    }
    func startLoading() {
        loadingLabel.text = "Loading \(HippoConfig.shared.strings.displayNameForCustomers) for \(broadcaster?.selectedTeam?.tagName ?? "")"
        UIView.animate(withDuration: 0.2, animations: {
            self.loaderView.alpha = 1
        }) { (_) in
            self.loaderView.isHidden = false
            self.loaderImage.startRotationAnimation()
        }
    }
    
    func stopLoading() {
        loadingLabel.text = ""
        UIView.animate(withDuration: 0.2, animations: {
            self.loaderView.alpha = 0
        }) { (_) in
            self.loaderView.isHidden = true
            self.loaderImage.stopRotationAnimation()
        }
    }
    func animateScreenLoading() {
        startLoading()
        if broadcaster != nil {
            delegate?.broadcasterUpdated(broadcaster: broadcaster!.copy())
            broadcaster = broadcaster!.copy()
        }
        fuguDelay(1) {
            self.stopLoading()
            self.updateScreenForAgentSelection()
        }
    }
    
    func updateScreenForAgentSelection() {
        screenType = BroadCastScreenRow.selectAgent
        setData()
        setUpView()
        setupTableView()
        self.tableView.reloadData()
    }
    func setupTableView() {
        guard broadcaster != nil else {
            return
        }
        
        let bundle = FuguFlowManager.bundle
        tableView.register(UINib(nibName: "BroadcastAgentCell", bundle: bundle), forCellReuseIdentifier: "BroadcastAgentCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension BroadcastSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let type = screenType else {
            return 0
        }
        switch type {
        case .selectAgent:
            return heightFoHeader + 10
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = screenType else {
            return
        }
        switch type {
        case .selectTeam:
            let lastSelectedId = broadcaster?.selectedTeam?.tagId ?? -2
            //logic for selction and deselection for single Team or all Team
            if lastSelectedId == teams[indexPath.row].tagId ?? -1 && teams[indexPath.row].tagId == -100 {
                broadcaster?.selectedTeam = nil
            } else {
                broadcaster?.selectedTeam = teams[indexPath.row]
            }
            
             // Logic to select and unSelect all Teams
            if teams[indexPath.row].tagId == -100 && broadcaster?.selectedTeam != nil {
                broadcaster?.selectAllAgentsForAllTeam()
            } else if lastSelectedId == -100 {
                broadcaster?.unselectAllAgentsForAllTeam()
            }
        case .selectAgent:
            //logic for selction and deselection for single agent or all agent
            if agents[indexPath.row].tagId == -100 && agents[indexPath.row].isSelected {
                broadcaster?.unselectAllAgentsForSelectedTeam()
                break
            } else if agents[indexPath.row].tagId == -100 && !agents[indexPath.row].isSelected {
                broadcaster?.selectAllAgentsForSelectedTeam()
                break
            }
            agents[indexPath.row].isSelected = !agents[indexPath.row].isSelected
            //Updating to broadcaster object
            broadcaster?.updateAgentsListForSelectedTeam(with: agents)
            
            // Logic to select and unSelect all Option
            if !agents[indexPath.row].isSelected {
                agents[0].isSelected = false
            } else if let isAllAgentsSelected = broadcaster?.isAllAgentSelectedForSelectedTeam() {
                agents[0].isSelected = isAllAgentsSelected
            }
            //Final updating for local agent list to broadcaster objet
            broadcaster?.updateAgentsListForSelectedTeam(with: agents)
        default:
            return
        }
        tableView.reloadData()
    }
    
}

extension BroadcastSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let type = screenType else {
            return nil
        }
        switch type {
        case .selectAgent:
            let labelBgView = UIView()
            
            labelBgView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: heightFoHeader + 10)
            labelBgView.backgroundColor = HippoConfig.shared.theme.backgroundColor
            
            let label = UILabel()
            label.text = "Team: " + (broadcaster?.selectedTeam?.tagName ?? "")
            label.textColor = HippoConfig.shared.theme.headerBackgroundColor
            label.font = UIFont.regular(ofSize: 14)
//            label.backgroundColor = UIColor.white
            label.textAlignment = .left
            label.layer.masksToBounds = true
//            label.layer.borderWidth = 0.5
//            label.layer.borderColor = UIColor.borderStrokeColor.cgColor
//            label.layer.cornerRadius = 10.0
            var widthIs: CGFloat = 0.0
            
            #if swift(>=4.0)
             widthIs = CGFloat(label.text!.boundingRect(with: label.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font], context: nil).size.width)
            #else
                widthIs = CGFloat(label.text!.boundingRect(with: label.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil).size.width)
            #endif
            
            label.frame = CGRect(x: 10, y: 5.0, width: widthIs + 20, height: heightFoHeader)
            
            labelBgView.addSubview(label)
            return labelBgView
        default:
            return nil
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = screenType else {
            return 0
        }
        switch type {
        case .selectTeam:
            return teams.count
        case .selectAgent:
            return agents.count
        case .showAgent:
            return selectedAgents.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = screenType else {
            return defaultCell()
        }
        switch type {
        case .selectTeam:
            return getTeamCell(indexPath: indexPath, obj: teams[indexPath.row])
        case .selectAgent:
            return getAgentCell(indexPath: indexPath, obj: agents[indexPath.row], type: type )
        case .showAgent:
            return getAgentCell(indexPath: indexPath, obj: selectedAgents[indexPath.row], type: type)
        default:
            return defaultCell()
        }
    }
    
    func defaultCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func getAgentCell(indexPath: IndexPath, obj: UserDetail, type: BroadCastScreenRow) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastAgentCell", for: indexPath) as? BroadcastAgentCell else {
            return defaultCell()
        }
        cell.setData(agentInfo: obj)
        
        switch type {
        case .selectAgent:
            cell.imageWidthConstraint.constant = 20
            cell.labelLeadingConstraint.constant = 8
        default:
            cell.imageWidthConstraint.constant = 0
            cell.labelLeadingConstraint.constant = 0
        }
        
        if obj.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        return cell
    }
    func getTeamCell(indexPath: IndexPath, obj: TagDetail) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastAgentCell", for: indexPath) as? BroadcastAgentCell else {
            return defaultCell()
        }
        let selectedTeamId = broadcaster?.selectedTeam?.tagId
        let isSelected = selectedTeamId == obj.tagId || selectedTeamId == -100
        
        cell.setData(teamInfo: obj, isSelected: isSelected)
        
        if isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
}
