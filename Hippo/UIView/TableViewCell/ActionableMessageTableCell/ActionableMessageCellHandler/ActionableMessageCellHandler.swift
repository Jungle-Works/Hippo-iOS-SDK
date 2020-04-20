//
//  ActionableMessageCellHandler.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

enum ActionableMessageSection: Int {
    case SenderName = 0
    case Image = 1
    case Header = 2
    case ItemDescription = 3
    case ButtonsCollection = 4
    case count
 
}

import UIKit

typealias ActionableMessageCellCallback = ((_ response: Any?) -> Void)

class ActionableMessageCellHandler: NSObject {
    
    var tableViewHeight: CGFloat = 300.0
    var rootViewController: UIViewController?
    var chatMessageObj: HippoMessage?
    var actionableMessage: FuguActionableMessage?
    var buttonCellCollectionViewHandler = ButtonCellCollectionViewHandler()
    
    func getHeightOfTableView()->CGFloat {
        return tableViewHeight
    }
  
    
    func getHeighOfButtonCollectionView() -> CGFloat {
        
        if actionableMessage?.actionButtonsArray != nil, (actionableMessage?.actionButtonsArray.count)! > 0 {
            var numberOfRows = 0
            if (actionableMessage?.actionButtonsArray.count)! < 4 {
                numberOfRows = 1
            } else {
                 numberOfRows = (actionableMessage?.actionButtonsArray.count)!/2
                let extraRow = (actionableMessage?.actionButtonsArray.count)!%2
                numberOfRows += extraRow
                
            }
            
            return CGFloat((40 * numberOfRows)) 
            
        }
        return 0
    }
    
}

extension ActionableMessageCellHandler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if indexPath.section == ActionableMessageSection.ButtonsCollection.rawValue {
//            return getHeighOfButtonCollectionView()
//        }
        
        return UIView.tableAutoDimensionHeight
    }
    
}

extension ActionableMessageCellHandler: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ActionableMessageSection.count.rawValue
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ActionableMessageSection.SenderName.rawValue:
            if chatMessageObj?.senderFullName.isEmpty == false {
                return 1
            }
            return 0
        case ActionableMessageSection.Image.rawValue:
            if actionableMessage?.messageImageURL.isEmpty == false {
                return 1
            }
            return 0
        case ActionableMessageSection.Header.rawValue:
            if actionableMessage?.messageTitle.isEmpty == false || actionableMessage?.titleDescription.isEmpty == false {
                return 1
            }
            return 0
        case ActionableMessageSection.ItemDescription.rawValue:
            if actionableMessage?.descriptionArray != nil, (actionableMessage?.descriptionArray.count)! > 0 {
                return (actionableMessage?.descriptionArray.count)!
            }
            return 0
            
        case ActionableMessageSection.ButtonsCollection.rawValue:
            if actionableMessage?.actionButtonsArray != nil, (actionableMessage?.actionButtonsArray.count)! > 0 {
                return 1
            }
            return 0
        default:
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case ActionableMessageSection.SenderName.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SenderNameTableCell") as? SenderNameTableCell {
                cell.senderNameLabel.text = chatMessageObj?.senderFullName
                tableViewHeight = tableView.contentSize.height
                return cell
            }
             break
        case ActionableMessageSection.Image.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell {
                
                if let thumbnailUrl = actionableMessage?.messageImageURL, thumbnailUrl.count > 0, let url = URL(string: thumbnailUrl) {
                    //            self.retryButton.isHidden = true
                    cell.setupIndicatorView(true)
                    let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
                    
                    cell.messageImageView.kf.setImage(with: url, placeholder: placeHolderImage, completionHandler: { (image, error, _, _) in
                        cell.setupIndicatorView(false)
                        if error != nil {
                            cell.setupIndicatorView(true)
                        }
                    })
                    
                }
                
                
                
                tableViewHeight = tableView.contentSize.height
                return cell
            }
            break
        case ActionableMessageSection.Header.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as? HeaderTableViewCell {
                cell.messageTitleLabel.text = actionableMessage?.messageTitle
                cell.itemDescriptionLabel.text = actionableMessage?.titleDescription
                if (actionableMessage?.titleDescription.isEmpty)! {
                    //cell.bottomConstraint.constant = 5.0
                }
                tableViewHeight = tableView.contentSize.height
                
                return cell
            }
            break
        case ActionableMessageSection.ItemDescription.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as? ItemTableViewCell {
                
                
                if  actionableMessage?.descriptionArray != nil, (actionableMessage?.descriptionArray.count)! > indexPath.row {
                    let descriptionArray = actionableMessage?.descriptionArray
                    if let descriptionObj = descriptionArray![indexPath.row] as? [String: Any]{
                        if let description = descriptionObj["header"] as? String {
                            cell.itemDescriptionLabel.text = description
                        }
                        if let description = descriptionObj["content"] as? String {
                            cell.itemPriceLabel.text = description
                        }
                    }
 
                }
                tableViewHeight = tableView.contentSize.height
                return cell
            }
            break
        case ActionableMessageSection.ButtonsCollection.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell") as? ButtonTableViewCell {
                cell.buttonCollectionViewHeightConstraint.constant = self.getHeighOfButtonCollectionView()
                cell.registerCell()
                cell.buttonCollectionView.delegate = buttonCellCollectionViewHandler
                cell.buttonCollectionView.dataSource = buttonCellCollectionViewHandler
                buttonCellCollectionViewHandler.rootViewController = self.rootViewController
                buttonCellCollectionViewHandler.chatMessageObj = self.chatMessageObj
                cell.reloadButtonActionCollection()
                tableViewHeight = tableView.contentSize.height
                
                return cell
            }
            break
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
}


