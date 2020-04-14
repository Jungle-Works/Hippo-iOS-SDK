//
//  AgentProfileViewController.swift
//  HippoChat
//
//  Created by Vishal on 26/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class AgentProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: AgentProfilePresenter?
    var datasource = AgentProfileViewDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        setUpTableView()
    }

    internal func setTheme() {
        let theme = HippoConfig.shared.theme
        view.backgroundColor = theme.profileBackgroundColor
    }
    internal func setUpTableView() {
        tableView.tableFooterView = UIView()
        datasource.profileDetail = presenter?.profile

        let bundle = FuguFlowManager.bundle
        
        tableView.register(UINib(nibName: "ProfileNameCell", bundle: bundle), forCellReuseIdentifier: "ProfileNameCell")
        tableView.register(UINib(nibName: "ProfileDetailCell", bundle: bundle), forCellReuseIdentifier: "ProfileDetailCell")
        setParallexView()
        
        tableView.backgroundColor = .clear
        tableView.delegate = datasource
        tableView.dataSource = datasource
        tableView.allowsSelection = false
    }
    
    internal func setParallexView() {
        let imageView = HippoImageView()
        imageView.image = HippoConfig.shared.theme.placeHolderImage
        imageView.contentMode = .scaleAspectFill
        if let url = presenter?.profile?.image, let parsedURl = URL(string: url) {
            let resource = HippoResource(url: parsedURl)
            imageView.setImage(resource: resource, placeholder: HippoConfig.shared.theme.placeHolderImage)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileClicked))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        tableView.parallaxHeader.view = imageView
        tableView.parallaxHeader.height = 250
        tableView.parallaxHeader.minimumHeight = 0
        tableView.parallaxHeader.mode = .centerFill
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            
        }
    }
    @objc func profileClicked() {
        guard let imageUrl = presenter?.profile?.image else {
            return
        }
        let showImageVC: ShowImageViewController = ShowImageViewController.getFor(imageUrlString: imageUrl)
        
        self.modalPresentationStyle = .overCurrentContext
        self.present(showImageVC, animated: true, completion: nil)
    }
    
    class func get(presenter: AgentProfilePresenter) -> AgentProfileViewController {
        let vc = generateView()
        vc.presenter = presenter
        presenter.setDelegate(delegate: vc)
//        presenter.delegate = vc
        return vc
    }
    
    internal class func generateView() -> AgentProfileViewController {
        let array = FuguFlowManager.bundle?.loadNibNamed("AgentProfileViewController", owner: self, options: nil)
        let view: AgentProfileViewController? = array?.first as? AgentProfileViewController
        
        guard let customView = view else {
            let vc = AgentProfileViewController()
            return vc
        }
        return customView
    }
}
extension AgentProfileViewController: AgentProfilePresenterDelegate {
    func profileUpdated() {
        setTheme()
        setUpTableView()
        tableView.reloadData()
    }
}
