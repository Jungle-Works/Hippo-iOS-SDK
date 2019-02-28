//
//  MessageRetryCancelView.swift
//  MZFayeClient
//
//  Created by clickpass on 22/11/17.
//

import UIKit

class MessageRetryCancelView: UIView {

    @IBOutlet var cancelButtonOutlet: UIButton!
    @IBOutlet var retryButtonOutlet: UIButton!
    @IBOutlet var warningMessageLabel: UILabel!
    @IBOutlet var warningImageView: So_UIImageView!
    
    class func loadView(_ frame: CGRect, cancelButtonCliked: (() -> Void), retryButtonClicked: (()-> Void)) -> MessageRetryCancelView {
        let array = Bundle.main.loadNibNamed("MessageRetryCancelView", owner: self, options: nil)
        let view: MessageRetryCancelView? = array?.first as? MessageRetryCancelView
        view?.frame = frame
        guard let customView = view else {
            return MessageRetryCancelView()
        }
        return customView
    }

    @IBAction func retryButtonAction(sender: AnyObject) {
    }
    
    @IBAction func cancelButtonAction(sender: UIButton) {
    }
    
}
