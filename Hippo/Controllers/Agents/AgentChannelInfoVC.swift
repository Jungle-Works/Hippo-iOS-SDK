//
//  ChannelInfoViewController.swift
//  Hippo Agent
//
//  Created by Vishal on 17/05/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

protocol ChatInfoDelegate: class {
    func backButtonAction(tagsArray: [TagDetail])
}


class ChannelInfoViewController: UIViewController {
    enum InfoType {
        case detail
        case chatHistory
    }
    
    //MARK: Outlets
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var chatHistoryButton: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var slidingView: UIView!
    @IBOutlet weak var slidingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var view_NavigationBar: NavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var tags: [TagDetail] = []
    var detail: ChatDetail!
    var chatInfoController: AgentChatInfoViewController?
    var chatHistoryController: AgentChatHistoryVC?
    weak var delegate: ChatInfoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatHistoryButton.isHidden = detail.chatType == .o2o
        handleButtonView()
        setUpView()
        
        //Intailizing ChatInfoViewController
        intilizeChatInfoController()
        addChatInfoView()
    }
    
}

extension ChannelInfoViewController{
    @IBAction func chatHistoryButtonClicked(_ sender: Any) {
        guard chatHistoryController != nil else {
            intilizeChatHistoryControllerAndAddView()
            return
        }
        addChatHistoryView()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let tags = chatInfoController?.tagsArray{
            delegate?.backButtonAction(tagsArray: tags)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func detailButtonClicked(_ sender: Any) {
        addChatInfoView()
    }
    
    func intilizeChatInfoController() {
        guard let vc = AgentChatInfoViewController.get(tags: tags, chatDetail: detail, userImage: detail.otherUserImage) else {
            return
        }
        vc.navigationCon = self.navigationController
        self.chatInfoController = vc
    }
    
    func intilizeChatHistoryControllerAndAddView() {
        guard let vc = AgentChatHistoryVC.getController() else {
            return
        }
        vc.navController = self.navigationController
        vc.visitorId = detail.customerID
        self.chatHistoryController = vc
        self.addChatHistoryView()
    }
    
    func addChatInfoView() {
        guard let view = chatInfoController?.view else {
            return
        }
        self.chatInfoController?.view.removeFromSuperview()
//        self.chatHistoryController?.view.removeFromSuperview()
        tableView.isHidden = true
        view.bounds = tableView.bounds
        view.frame = tableView.frame
        self.bottomContainerView.addSubview(view)
        animateBottomLineView(infoType: .detail)
    }
    
    func addChatHistoryView() {
        guard let view = chatHistoryController?.view else {
            return
        }
        self.chatHistoryController?.view.removeFromSuperview()
        self.chatInfoController?.view.removeFromSuperview()
        tableView.isHidden = true
        view.bounds = tableView.bounds
        view.frame = tableView.frame
        self.bottomContainerView.addSubview(view)
        animateBottomLineView(infoType: .chatHistory)
    }
    
    func setUpView() {
        view_NavigationBar.title = HippoStrings.info
        view_NavigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        view_NavigationBar.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        view_NavigationBar.view.layer.shadowRadius = 2.0
        view_NavigationBar.view.layer.shadowOpacity = 0.5
        view_NavigationBar.view.layer.masksToBounds = false
        view_NavigationBar.view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                                        y: view_NavigationBar.bounds.maxY - view_NavigationBar.layer.shadowRadius,
                                                                        width: view_NavigationBar.bounds.width,
                                                                        height: view_NavigationBar.layer.shadowRadius)).cgPath
    }
    
    func animateBottomLineView(infoType: InfoType, withAnimation: Bool = true) {
        let isInfoDetailSelected = infoType == .detail
        let leading = isInfoDetailSelected ? 0 : detailButton.bounds.width
        slidingViewLeadingConstraint.constant = leading
        slidingView.backgroundColor = UIColor.themeColor
        
        let selectedColor = UIColor.themeColor
        let unSelectColor = UIColor.purpleGrey
        
        chatHistoryButton.setTitleColor(isInfoDetailSelected ? unSelectColor : selectedColor, for: .normal)
        detailButton.setTitleColor(isInfoDetailSelected ? selectedColor : unSelectColor, for: .normal)
        
        if withAnimation {
            UIView.animate(withDuration: 0.4) {
                self.buttonContainer.layoutIfNeeded()
            }
        } else {
            self.buttonContainer.layoutIfNeeded()
        }
    }
    
    func  setupButtonUI() {
//        detailButton.MontRegular = 15
//        chatHistoryButton.MontRegular = 15
//        bottomContainerView.showShadow(shadowSideAngles: ShadowSideView.allSide())
    }
    
    func handleButtonView() {
        if shouldShowUserAction() {
            buttonContainer.isHidden = false
            buttonContainerHeightConstraint.constant = 45
            setupButtonUI()
        } else {
            buttonContainer.isHidden = true
            buttonContainerHeightConstraint.constant = 0
        }
        animateBottomLineView(infoType: .detail, withAnimation: false)
    }
    
    func shouldShowUserAction() -> Bool {
        guard detail != nil, let showHistory = BussinessProperty.current.showCustomerChatHistory else {
            return false
        }
        return detail.isFirstLevel && showHistory
    }
    
    class func get(info: ChatDetail) -> ChannelInfoViewController? {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelInfoViewController") as? ChannelInfoViewController
        vc?.tags = info.channelTags
        vc?.detail = info
        return vc
    }
}
