//
//  ButtonCellCollectionViewHandler.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class ButtonCellCollectionViewHandler: NSObject {
      var rootViewController: UIViewController?
    var chatMessageObj: HippoMessage?
    
    func getNumberOfItemInOneSection() -> CGFloat {
        let actionableMessage = chatMessageObj?.actionableMessage
        if actionableMessage?.actionButtonsArray != nil, (actionableMessage?.actionButtonsArray.count)! > 0 {
            var numberOfRows = 0
            
            if (actionableMessage?.actionButtonsArray.count)! == 1 {
                numberOfRows = 1
            } else if (actionableMessage?.actionButtonsArray.count)! == 2 {
                numberOfRows = 2
            } else if (actionableMessage?.actionButtonsArray.count)! == 3 {
                numberOfRows = 3
            } else  {
                numberOfRows = 2
            }
 
//            if (actionableMessage?.actionButtonsArray.count)! < 4 {
//
//            } else {
//                numberOfRows = (actionableMessage?.actionButtonsArray.count)!/2
//                let extraRow = (actionableMessage?.actionButtonsArray.count)!%2
//                numberOfRows += extraRow
//
//            }
            
            return CGFloat(numberOfRows)
            
        }
        return 0
    }
    
    func enableButton() -> Bool {
        
        let isSentByMe = currentUserId() == (chatMessageObj?.senderId ?? -3)
        let isAgent = HippoConfig.shared.appUserType == .agent
        return !isSentByMe && !isAgent
    }
    @objc func messageButtonClicked(sender: UIButton) {
        
        if let buttonActionArray = chatMessageObj?.actionableMessage?.actionButtonsArray {
            
            if  buttonActionArray.count > sender.tag, let buttonInfo =  buttonActionArray[sender.tag] as? [String: Any], let controller = self.rootViewController {
                HippoConfig.shared.broadCastMessage(dict: buttonInfo, contoller: controller)
                
                }
            }
            
        }
        
    
    }
    


extension ButtonCellCollectionViewHandler: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
       // cell.highlight(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
       // cell.highlight(false)
    }
}

extension ButtonCellCollectionViewHandler: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (chatMessageObj?.actionableMessage?.actionButtonsArray.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCollectionCell", for: indexPath) as? ButtonCollectionCell {
            cell.backgroundColor = UIColor.clear
            
            let numberOfRowsInOneScetion = self.getNumberOfItemInOneSection()
            if numberOfRowsInOneScetion == 1 {
                cell.leadingView.isHidden = true
                cell.trailingView.isHidden = true
            } else if indexPath.item % Int(numberOfRowsInOneScetion) == 0 {
                cell.leadingView.isHidden = true
                cell.trailingView.isHidden = false
            } else if (indexPath.item + 1) % Int(numberOfRowsInOneScetion) == 0 {
                 cell.trailingView.isHidden = true
                cell.leadingView.isHidden = false
            }
            
//            if (indexPath.item % 2) == 0 {
//                cell.xCenterConstraintOfButton.constant = 20.0
//            } else {
//                cell.xCenterConstraintOfButton.constant =  -20.0
//            }
            if let buttonActionArray = chatMessageObj?.actionableMessage?.actionButtonsArray {
                
                if let buttonInfo =  buttonActionArray[indexPath.item] as? [String: Any] {
                    if let buttonTitle = buttonInfo["button_text"] as? String {
                        cell.messageButton.setTitle(buttonTitle.uppercased(), for: .normal)
                    }
                }
                
            }
            cell.messageButton.tag = indexPath.item
            cell.messageButton.addTarget(self, action: #selector(self.messageButtonClicked(sender:)), for: .touchUpInside)
            cell.messageButton.backgroundColor = HippoConfig.shared.theme.themeColor
            cell.messageButton.setTitleColor(HippoConfig.shared.theme.themeTextcolor, for: .normal)
            cell.messageButton.isEnabled = enableButton()
            
            if enableButton() {
                cell.messageButton.alpha = 1.0
            } else {
                cell.messageButton.alpha = 0.8
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension ButtonCellCollectionViewHandler: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfButtons = self.getNumberOfItemInOneSection()
        return CGSize(width: (collectionView.bounds.width)/numberOfButtons , height: 40.0)
        
    }
}




