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

class FeedbackTableViewCell: UITableViewCell {
    
    static let submitButtonHeight: CGFloat = 35
    
    var objectArray = [FeedbackAttributes]()
    weak var delegate: FeedbackTableViewCellDelegate?
    var data = FeedbackParams()
    let min_height_textview: CGFloat = 50
    let max_height_textview: CGFloat = 120
    let availabelWidthOfCollectionView = FUGU_SCREEN_WIDTH - 106
    
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var constraintSubmitHeight: NSLayoutConstraint!
    @IBOutlet weak var feedbackDescLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var feedbackSubmittedMessage: UILabel!
    @IBOutlet weak var textviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var completionView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var cellTextView: UITextView!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.setTitle("SUBMIT", for: .normal)
            submitButton.setTitleColor(HippoConfig.shared.theme.headerTextColor, for: .normal)
            submitButton.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var verticleLineview: UIView!
    
    override func awakeFromNib() {
        objectArray = FeedbackAttributes.getArray()
        setupCollectionView()
        setupAlertView()
    }
    
    func setData(params: FeedbackParams) {
        self.data = params
        
        data.cellTextView = cellTextView
        titleLabel.text = data.messageObject!.feedbackMessages.line_before_feedback
        
        if params.messageObject!.is_rating_given {
            completionView.isHidden = false
            submitButton.isHidden = true
            cellTextView.isEditable = false
            placeholderLabel.isHidden = true
            constraintSubmitHeight.constant = 0
            verticleLineview.isHidden = true
//            textviewHeightConstraint.constant = min_height_textview + 35
            setDataForCompletedRating()
        } else {
            completionView.isHidden = true
            submitButton.isHidden = false
            cellTextView.isEditable = true
            placeholderLabel.isHidden = false
            cellTextView.text = ""
            constraintSubmitHeight.constant = FeedbackTableViewCell.submitButtonHeight
//            textviewHeightConstraint.constant = min_height_textview
            verticleLineview.isHidden = false
        }
        self.layoutIfNeeded()
        updateHeightOf(textView: cellTextView)
        collectionView.reloadData()
        
        let index = IndexPath(row: data.selectedIndex - 1, section: 0)
        collectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
    }
    func setDataForCompletedRating() {
        guard data.messageObject != nil else {
            return
        }
        cellTextView.text = data.messageObject!.comment
        
        if cellTextView.text.isEmpty {
            placeholderLabel.text = "No Comment..."
            placeholderLabel.isHidden = false
        }
        ratingImage.image = FeedbackAttributes.getArray()[data.selectedIndex - 1].image
        
        feedbackDescLabel.text = data.messageObject!.feedbackMessages.line_after_feedback_2
        feedbackSubmittedMessage.text = data.messageObject!.feedbackMessages.line_after_feedback_1
        
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
        
        alertContainer.layer.borderColor = UIColor.lightGray.cgColor
        alertContainer.layer.borderWidth = 0.5
        alertContainer.layer.masksToBounds = true
        alertContainer.layer.cornerRadius = 5
        
        selectionStyle = .none
    }
    
    @objc func viewTapped() {
        self.removeFromSuperview()
    }
}
extension FeedbackTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as? EmojiCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let index = IndexPath(row: data.selectedIndex - 1, section: 0)
        collectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
        cell.setData(data: objectArray[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        data.selectedIndex = indexPath.row + 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (availabelWidthOfCollectionView / CGFloat(objectArray.count)), height: collectionView.frame.height)
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "EmojiCollectionViewCell", bundle: FuguFlowManager.bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: "EmojiCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewHeightConstraint.constant = availabelWidthOfCollectionView / 5
    }
}
extension FeedbackTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.cellTextViewBeginEditing(textView: textView, data: data)
        HippoKeyboardManager.shared.enable = true
//        HippoKeyboardManager.shared.layoutIfNeededOnUpdate = false
//        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
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

struct FeedbackParams {
    var selectedIndex: Int = 3
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
        
        selectedIndex = messageObj.rating_given == 0 ? 3 : messageObj.rating_given
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

