//
//  TagListView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit



@objc protocol TagListViewDelegate {
    @objc optional func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    @objc optional func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
}

@IBDesignable
class TagListView: UIView {
    
    var maxWidthPerecentage: CGFloat = 0.7
    var buttonBorderWidth: CGFloat = 0
    
    @IBInspectable  dynamic var textColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagViews {
                tagView.textColor = textColor
            }
        }
    }
    
    @IBInspectable  dynamic var selectedTextColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagViews {
                tagView.selectedTextColor = selectedTextColor
            }
        }
    }
    
    @IBInspectable  dynamic var tagLineBreakMode: NSLineBreakMode = .byTruncatingTail {
        didSet {
            for tagView in tagViews {
                tagView.titleLineBreakMode = tagLineBreakMode
            }
        }
    }
    
    @IBInspectable  dynamic var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            for tagView in tagViews {
                tagView.tagBackgroundColor = tagBackgroundColor
            }
        }
    }
    
    @IBInspectable  dynamic var tagHighlightedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
            }
        }
    }
    
    @IBInspectable  dynamic var tagSelectedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBackgroundColor = tagSelectedBackgroundColor
            }
        }
    }
    
    @IBInspectable  dynamic var cornerRadiu: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.cornerRadiu = cornerRadiu
            }
        }
    }
    @IBInspectable  dynamic var borderWidt: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.hippoBorderWidth = buttonBorderWidth
            }
        }
    }
    
    @IBInspectable  dynamic var borderColo: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.hippoBorderColor = hippoBorderColor
            }
        }
    }
    
    @IBInspectable  dynamic var selectedBorderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBorderColor = selectedBorderColor
            }
        }
    }
    
    @IBInspectable  dynamic var paddingY: CGFloat = 2 {
        didSet {
            for tagView in tagViews {
                tagView.paddingY = paddingY
            }
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var paddingX: CGFloat = 5 {
        didSet {
            for tagView in tagViews {
                tagView.paddingX = paddingX
            }
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var marginY: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var marginX: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    
    @objc public enum Alignment: Int {
        case left
        case center
        case right
    }
    @IBInspectable  var alignment: Alignment = .left {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var shadowColor: UIColor = UIColor.white {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var shadowOffset: CGSize = CGSize.zero {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var shadowOpacity: Float = 0 {
        didSet {
            rearrangeViews()
        }
    }
    
    @IBInspectable  dynamic var enableRemoveButton: Bool = false {
        didSet {
            for tagView in tagViews {
                tagView.enableRemoveButton = enableRemoveButton
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable  dynamic var removeButtonIconSize: CGFloat = 12 {
        didSet {
            for tagView in tagViews {
                tagView.removeButtonIconSize = removeButtonIconSize
            }
            rearrangeViews()
        }
    }
    @IBInspectable  dynamic var removeIconLineWidth: CGFloat = 1 {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineWidth = removeIconLineWidth
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable  dynamic var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineColor = removeIconLineColor
            }
            rearrangeViews()
        }
    }
    
    @objc  dynamic var textFont: UIFont = UIFont.regular(ofSize: 12) {
        didSet {
            for tagView in tagViews {
                tagView.textFont = textFont
            }
            rearrangeViews()
        }
    }
    
    @IBOutlet  weak var delegate: TagListViewDelegate?
    
    private(set) var tagViews: [TagView] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Interface Builder
    
    override public func prepareForInterfaceBuilder() {
        //        addTag("Welcome")
        //        addTag("to")
        //        addTag("TagListView").isSelected = true
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        rearrangeViews()
    }
    
    private func rearrangeViews() {
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)
        
        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, tagView) in tagViews.enumerated() {
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            
            if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)
                
                tagView.frame.size.width = min(tagView.frame.size.width, frame.width)
            }
            
            let tagBackgroundView = tagBackgroundViews[index]
            tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowColor = shadowColor.cgColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: tagView.cornerRadiu).cgPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)
            
            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            switch alignment {
            case .left:
                currentRowView.frame.origin.x = 0
            case .center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .right:
                currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
            }
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Manage tags
    
    override public var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }
    private func createNewTagView(_ object: TagViewCreation) -> TagView {
        
        let tagView = TagView(title: object.name)
        tagView.maxWidthPerecentage = maxWidthPerecentage
        tagView.textColor = object.tagViewTextColor
        tagView.detail = object
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = object.color
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.titleLineBreakMode = tagLineBreakMode
        tagView.cornerRadiu = 10//cornerRadius
        tagView.hippoBorderWidth = buttonBorderWidth//hippoBorderWidth
        tagView.hippoBorderColor = borderColo
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor
        
        
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)
        tagView.frame = CGRect(x: tagView.frame.origin.x, y: tagView.frame.origin.y, width: tagView.frame.width + 50, height: tagView.frame.height)
        
        if object.circlularCorner {
            tagView.cornerRadiu = tagView.intrinsicContentSize.height / 2
        }
        // On long press, deselect all tags except this one
        tagView.onLongPress = { [unowned self] this in
            for tag in self.tagViews {
                tag.isSelected = (tag == this)
            }
        }
        
        return tagView
    }
    
    
    private func createNewTagView(_ object: TagDetail) -> TagView {
        
        let tagView = TagView(title: object.tagName ?? "")
        
        tagView.textColor = UIColor.white
        
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = UIColor.hexStringToUIColor(hex: object.colorCode ?? "")
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.titleLineBreakMode = tagLineBreakMode
        tagView.cornerRadiu = 6//cornerRadius
        tagView.hippoBorderWidth = buttonBorderWidth//hippoBorderWidth
        tagView.hippoBorderColor = hippoBorderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor
        
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)
        tagView.frame = CGRect(x: tagView.frame.origin.x, y: tagView.frame.origin.y, width: tagView.frame.width + 50, height: tagView.frame.height)
        // On long press, deselect all tags except this one
        tagView.onLongPress = { [unowned self] this in
            for tag in self.tagViews {
                tag.isSelected = (tag == this)
            }
        }
        
        return tagView
    }
    
    func addTag(_ object: TagDetail) -> TagView {
        return addTagView(createNewTagView(object))
    }
    
    func addTags(_ objects: [TagDetail]) -> [TagView] {
        var tagViews: [TagView] = []
        for object in objects {
            tagViews.append(createNewTagView(object))
        }
        return addTagViews(tagViews)
    }
    func addTag(_ object: TagViewCreation) -> TagView {
        return addTagView(createNewTagView(object))
    }
    
    @discardableResult
    func addTags(_ objects: [TagViewCreation]) -> [TagView] {
        var tagViews: [TagView] = []
        for object in objects {
            tagViews.append(createNewTagView(object))
        }
        return addTagViews(tagViews)
    }
    
    
    func addTagViews(_ tagViews: [TagView]) -> [TagView] {
        for tagView in tagViews {
            self.tagViews.append(tagView)
            tagBackgroundViews.append(UIView(frame: tagView.bounds))
        }
        rearrangeViews()
        return tagViews
    }
    
    
    func insertTag(_ object: TagDetail, at index: Int) -> TagView {
        return insertTagView(createNewTagView(object), at: index)
    }
    
    func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        
        return tagView
    }
    
    @discardableResult
    func insertTagView(_ tagView: TagView, at index: Int) -> TagView {
        tagViews.insert(tagView, at: index)
        tagBackgroundViews.insert(UIView(frame: tagView.bounds), at: index)
        rearrangeViews()
        
        return tagView
    }
    
    func setTitle(_ title: String, at index: Int) {
        tagViews[index].titleLabel?.text = title
    }
    
    func removeTag(_ title: String) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.currentTitle == title {
                removeTagView(tagView)
            }
        }
    }
    
    func removeTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.firstIndex(of: tagView) {
            tagViews.remove(at: index)
            tagBackgroundViews.remove(at: index)
        }
        
        rearrangeViews()
    }
    
    func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }
    
    func selectedTags() -> [TagView] {
        return tagViews.filter() { $0.isSelected == true }
    }
    
    // MARK: - Events
    
    @objc func tagPressed(_ sender: TagView!) {
        sender.onTap?(sender)
        delegate?.tagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }
    
    @objc func removeButtonPressed(_ closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            delegate?.tagRemoveButtonPressed?(tagView.currentTitle ?? "", tagView: tagView, sender: self)
        }
    }
}
