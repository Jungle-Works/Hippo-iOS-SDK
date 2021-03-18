//
//  FeedbackTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 23/04/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//


import UIKit


protocol FeedbackTableViewCellDelegate: class {
    func submitButtonClicked(with data: FeedbackParams)
    func updateHeightForCell(at data: FeedbackParams, textView: UITextView)
    func cellTextViewBeginEditing(textView: UITextView, data: FeedbackParams)
    func cellTextViewEndEditing(data: FeedbackParams)
}

class FeedbackTableViewCell: MessageTableViewCell {
    
    static let submitButtonHeight: CGFloat = 35
    var isAgent: Bool = false
    var objectArray = [FeedbackAttributes]()
    weak var delegate: FeedbackTableViewCellDelegate?
    var data = FeedbackParams()
    let min_height_textview: CGFloat = 80
    let max_height_textview: CGFloat = 120
    let availabelWidthOfCollectionView = FUGU_SCREEN_WIDTH - 106
    
    //MARK:- IBOutlets
    
    @IBOutlet var view_Divider : UIView!{
        didSet{
            view_Divider.backgroundColor = UIColor(red: 242/255, green: 245/255, blue: 248/255, alpha: 1.0)
            view_Divider.isHidden = true
        }
    }
    @IBOutlet weak var feedbackTrailingconstraint: NSLayoutConstraint!
    @IBOutlet var constraintSubmitHeight: NSLayoutConstraint!
    @IBOutlet var textviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var cellTextView: UITextView!{
        didSet{
            cellTextView.font = UIFont.regular(ofSize: 16.0)
            cellTextView.layer.borderWidth = 1.5
            cellTextView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0).cgColor
            cellTextView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.titleLabel?.font = UIFont.bold(ofSize: 16.0)
            submitButton.setTitle(HippoStrings.submit, for: .normal)
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.backgroundColor = HippoConfig.shared.theme.themeColor
            submitButton.layer.cornerRadius = 6
        }
    }

    @IBOutlet weak var view_Rating : FloatRatingView!{
        didSet{
            view_Rating.delegate = self
            view_Rating.emptyImage = HippoConfig.shared.theme.ratingEmptyStar
            view_Rating.fullImage = HippoConfig.shared.theme.ratingFullStar
            view_Rating.minRating = 1
        }
    }
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.font = UIFont.bold(ofSize: 20)
        }
    }
//    @IBOutlet weak var label_SenderName : UILabel!{
//        didSet{
//            label_SenderName.font = UIFont.regular(ofSize: 18)
//        }
//    }
//    @IBOutlet weak var image_SenderInsideFeedback : UIImageView!{
//        didSet{
//            image_SenderInsideFeedback.layer.cornerRadius = 6
//        }
//    }
    @IBOutlet weak var view_ReviewSubmitted : UIView!{
        didSet{
            view_ReviewSubmitted.layer.cornerRadius = 10
            view_ReviewSubmitted.clipsToBounds = true
            view_ReviewSubmitted.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
            if #available(iOS 11.0, *) {
                view_ReviewSubmitted.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    @IBOutlet weak var label_ReviewSubmitted : UILabel!{
        didSet{
            label_ReviewSubmitted.font = UIFont.regular(ofSize: 15.0)
        }
    }
    @IBOutlet weak var label_Rating : UILabel!{
        didSet{
            label_Rating.font = UIFont.bold(ofSize: 23.0)
        }
    }
    
    
    
    override func awakeFromNib() {
        objectArray = FeedbackAttributes.getArray()
        //setupCollectionView()
       
        setupAlertView()
    }

    func setDataForAgent(with params: FeedbackParams) {
        self.data = params
        label_ReviewSubmitted.text = HippoStrings.thanksForFeedback
        textviewHeightConstraint?.isActive = true
        textviewHeightConstraint?.constant = 80
        if let message = params.messageObject {
            super.intalizeCell(with: message, isIncomingView: true)
        }
        
        data.cellTextView = cellTextView
        titleLabel.text = HippoStrings.ratingReview

        
        if params.messageObject!.is_rating_given {
            //  completionView.isHidden = false
            submitButton.isHidden = true
            cellTextView.isEditable = false
            placeholderLabel.isHidden = true
            constraintSubmitHeight.constant = 0
            view_Rating.isHidden = true
            view_ReviewSubmitted.isHidden = false
            cellTextView.layer.borderWidth = 0
            textviewHeightConstraint?.isActive = false
            cellTextView.isScrollEnabled = false
            view_Divider.isHidden = false
            //verticleLineview.isHidden = true
            setDataForCompletedRating(isAgent: true)
        } else {
            // completionView.isHidden = true
            submitButton.isHidden = true
            placeholderLabel.isHidden = true
            cellTextView.isHidden = true
            constraintSubmitHeight.constant = 0
            textviewHeightConstraint.constant = 0
            view_Divider.isHidden = true
            view_ReviewSubmitted.isHidden = true
            view_Rating.isHidden = false
            view_Rating.rating = 0.0
        }
        self.layoutIfNeeded()
        //updateHeightOf(textView: cellTextView)
        //collectionView.reloadData()
        
    }
    
    func setData(params: FeedbackParams) {
        self.data = params
        label_ReviewSubmitted.text = HippoStrings.thanksForFeedback
        textviewHeightConstraint?.isActive = true
        textviewHeightConstraint?.constant = 80
        if let message = params.messageObject {
            super.intalizeCell(with: message, isIncomingView: true)
        }
        
        data.cellTextView = cellTextView
        titleLabel.text = HippoStrings.ratingReview
        placeholderLabel.text = HippoStrings.writeReview
        
        if params.messageObject!.is_rating_given {
            //completionView.isHidden = false
            submitButton.isHidden = true
            cellTextView.isEditable = false
            placeholderLabel.isHidden = true
            constraintSubmitHeight.constant = 0
            view_Rating.isHidden = true
            view_ReviewSubmitted.isHidden = false
            cellTextView.layer.borderWidth = 0
            textviewHeightConstraint?.isActive = false
            cellTextView.isScrollEnabled = false
            view_Divider.isHidden = false
            //            textviewHeightConstraint.constant = min_height_textview + 35
            setDataForCompletedRating()
        } else {
            //completionView.isHidden = true
            view_Divider.isHidden = true
            cellTextView.layer.borderWidth = 1
            cellTextView.isScrollEnabled = true
            submitButton.isHidden = false
            cellTextView.isEditable = true
            placeholderLabel.isHidden = false
            cellTextView.text = ""
            constraintSubmitHeight.constant = FeedbackTableViewCell.submitButtonHeight
            //            textviewHeightConstraint.constant = min_height_textview
            view_ReviewSubmitted.isHidden = true
            view_Rating.isHidden = false
        }
        self.layoutIfNeeded()
        updateHeightOf(textView: cellTextView)
        view_Rating.rating = Double(data.selectedIndex)
        //collectionView.reloadData()
        
       // let index = IndexPath(row: data.selectedIndex - 1, section: 0)
        //collectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
        //        collectionView.backgroundColor = UIColor.clear
    }
    func setDataForCompletedRating(isAgent: Bool = false) {
        guard data.messageObject != nil else {
            return
        }
        if isAgent {
            textviewHeightConstraint.constant = min_height_textview
            cellTextView.isHidden = false
            cellTextView.text = data.messageObject!.comment
            label_Rating.text = "\(data.messageObject?.rating_given ?? 0)" + "/" + "\(data.messageObject?.total_rating ?? 0)"
            if cellTextView.text.isEmpty {
                cellTextView.isHidden = true
                placeholderLabel.isHidden = true
                textviewHeightConstraint.constant = 0
            }
        } else {
            cellTextView.text = data.messageObject!.comment
            label_Rating.text = "\(data.messageObject?.rating_given ?? 0)" + "/" + "\(data.messageObject?.total_rating ?? 0)"
            if cellTextView.text.isEmpty {
                placeholderLabel.text = HippoStrings.noComment
                placeholderLabel.isHidden = false
            }
        }

//        ratingImage.image = FeedbackAttributes.getArray()[data.selectedIndex - 1].image
//
//        feedbackDescLabel.text = data.messageObject!.feedbackMessages.line_after_feedback_2
//        feedbackSubmittedMessage.text = data.messageObject!.feedbackMessages.line_after_feedback_1
        
    }
    @IBAction func submitButtonClicked(_ sender: Any) {
        self.constraintSubmitHeight.constant = 0
        self.submitButton.isHidden = true
        self.submitButton.isUserInteractionEnabled = false
        self.layoutIfNeeded()
        delegate?.submitButtonClicked(with: data)
    }
    
    func setupAlertView() {
        cellTextView.layer.masksToBounds = true
        cellTextView.delegate = self
        cellTextView.flashScrollIndicators()
        alertContainer.layer.borderColor = UIColor(red: 242/255, green: 245/255, blue: 248/255, alpha: 1.0).cgColor //HippoConfig.shared.theme.gradientTopColor.cgColor //
        alertContainer.layer.borderWidth = 5
        alertContainer.layer.masksToBounds = true
        alertContainer.layer.cornerRadius = 10
        //        alertContainer.backgroundColor = HippoConfig.shared.theme.gradientBackgroundColor
        //        if #available(iOS 11.0, *) {
        //            alertContainer.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        
        selectionStyle = .none
    }
    
    @objc func viewTapped() {
        self.removeFromSuperview()
    }
    
    override func hideSenderImageView() {
        super.hideSenderImageView()
        feedbackTrailingconstraint.constant = 80
        layoutIfNeeded()
    }
    
    override func showSenderImageView() {
        super.showSenderImageView()
        feedbackTrailingconstraint.constant = 80
        layoutIfNeeded()
    }
}
//extension FeedbackTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return objectArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//
//        let index = IndexPath(row: data.selectedIndex - 1, section: 0)
//        collectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
//        cell.isAgent = self.isAgent
//        cell.setData(data: objectArray[indexPath.row])
//
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        data.selectedIndex = indexPath.row + 1
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (availabelWidthOfCollectionView / CGFloat(objectArray.count)), height: collectionView.frame.height)
//    }
//
//    func setupCollectionView() {
//        let nib = UINib(nibName: "EmojiCollectionViewCell", bundle: FuguFlowManager.bundle)
//        collectionView.register(nib, forCellWithReuseIdentifier: "EmojiCollectionViewCell")
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionViewHeightConstraint.constant = availabelWidthOfCollectionView / 5
//    }
//}

extension FeedbackTableViewCell: UITextViewDelegate {
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        HippoKeyboardManager.shared.enable = true
        self.delegate?.cellTextViewBeginEditing(textView: textView, data: data)
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        HippoKeyboardManager.shared.enable = true
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        HippoKeyboardManager.shared.enable = false
        self.delegate?.cellTextViewEndEditing(data: data)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
        updateHeightOf(textView: textView)
    }
    
    func updateHeightOf(textView: UITextView) {
        return
        //        var heightOfTextView = textView.contentSize.height - (textView.frame.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom)
        //
        //        heightOfTextView = textView.contentSize.height + textView.textContainerInset.top + textView.textContainerInset.bottom
        //
        //
        //        if heightOfTextView < self.min_height_textview {
        //            heightOfTextView = self.min_height_textview
        //        } else if heightOfTextView > self.max_height_textview {
        //            heightOfTextView = self.max_height_textview
        //        }
        //        self.textviewHeightConstraint.constant = heightOfTextView
        //        self.data.textViewHeight = heightOfTextView
        //        self.delegate?.updateHeightForCell(at: self.data, textView: textView)
        //        self.layoutIfNeeded()
    }
}

extension FeedbackTableViewCell : FloatRatingViewDelegate{
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        data.selectedIndex = Int(rating)
    }
}

struct FeedbackParams {
    var selectedIndex: Int = 5
    var indexPath: IndexPath?
    var title: String = "Rate Our conversation"
    var textViewHeight: CGFloat = 53
    var showSendButton = true
    var cellTextView = UITextView()
    
    var messageObject: HippoMessage?
    
    init() {
        
    }
    init(title: String, indexPath: IndexPath, messageObj: HippoMessage) {
        self.title = title
        self.indexPath = indexPath
        self.messageObject = messageObj
        selectedIndex = messageObj.rating_given == 0 ? 5 : messageObj.rating_given
    }
}
struct FeedbackAttributes {
    var image = UIImage()
    var title = ""
    
    init() {
        
    }
    init(title: String, image: UIImage?) {
        if let _image = image {
            self.image = _image
        }
        self.title = title
    }
    
    static func getArray() -> [FeedbackAttributes] {
        var temp = [FeedbackAttributes]()
        let rate_1 = UIImage(named: "rate_1", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let rate_2 = UIImage(named: "rate_2", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let rate_3 = UIImage(named: "rate_3", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let rate_4 = UIImage(named: "rate_4", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let rate_5 = UIImage(named: "rate_5", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        
        temp.append(FeedbackAttributes(title: "Terrible", image: rate_1))
        temp.append(FeedbackAttributes(title: "Bad", image: rate_2))
        temp.append(FeedbackAttributes(title: "Okay", image: rate_3))
        temp.append(FeedbackAttributes(title: "Good", image: rate_4))
        temp.append(FeedbackAttributes(title: "Great", image: rate_5))
        
        return temp
    }
    
}

