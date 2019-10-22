//
//  NavigationBar.swift
//  NavigationBarItem
//
//  Created by Артём Зайцев on 20.10.2019.
//  Copyright © 2019 Артём Зайцев. All rights reserved.
//

import UIKit

class VinciNavigationBar: HitTestView {
    enum DisplayType {
        case smallTitleOnly
        case largeTitleOnly
        case searchBarOnly
        case largeTitleWithSearchBar
    }
    
    // Public properties
    public var displayMode: DisplayType = .largeTitleWithSearchBar
    public weak var scrollView: UIScrollView? {
        didSet {
            self.scrollView?.contentInset = UIEdgeInsets(top: self.expandedHeight + 8.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    public var currentTabIndex: Int = 0 {
        didSet {
            self.updateTitleButtonsColor()
        }
    }
    public var inactiveButtonColor: UIColor = UIColor(hex: "#DADADA")!
    public var activeButtonColor: UIColor = .black
    
    public var tabsExpandedHeight: CGFloat = 55.0
    
    public var tabsShrinkedFontSize: CGFloat = 24.0
    public var tabsExpandedFontSize: CGFloat = 32.0
    public var tabsLeftMargin: CGFloat = 16.0
    public var searchViewTopMargin: CGFloat = 4.0
    
    public var searchBarExpandedHeight: CGFloat = 44.0
    public var searchBarDelegate: UISearchBarDelegate?
    public var placeholder: String = "search"
    
    public var expandedHeight: CGFloat {
        switch displayMode {
        case .smallTitleOnly:
            return 0.0
        case .largeTitleOnly:
            return tabsExpandedHeight
        case .searchBarOnly:
            return searchBarExpandedHeight
        case .largeTitleWithSearchBar:
            return tabsExpandedHeight + searchBarExpandedHeight + searchViewTopMargin
        }
    }
    
    public var offset: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var leftItems: [UIButton] = [] {
        didSet {
            for sv in leftStackView.arrangedSubviews {
                sv.removeFromSuperview()
            }
            for sv in self.leftItems {
                leftStackView.addArrangedSubview(sv)
            }
        }
    }
    public var rightItems: [UIButton] = [] {
        didSet {
            for sv in rightStackView.arrangedSubviews {
                sv.removeFromSuperview()
            }
            for sv in self.rightItems {
                rightStackView.addArrangedSubview(sv)
            }
        }
    }
    public var tabButtons: [UIButton] = [] {
        didSet {
            for v in titleStackView.arrangedSubviews {
                v.removeFromSuperview()
            }
            
            var captionsWidth: CGFloat = 0.0
            captionsWidth += CGFloat(self.tabButtons.count - 1) * titleStackView.spacing
            for (ind, c) in self.tabButtons.enumerated() {
                c.sizeToFit()
                c.addTarget(self, action: #selector(updateCurrentTabIndex(sender:)), for: .touchUpInside)
                c.setTitleColor(ind == currentTabIndex ? activeButtonColor : inactiveButtonColor, for: .normal)
                captionsWidth += c.bounds.width
                titleStackView.addArrangedSubview(c)
            }
            
            titleScrollView.contentSize = CGSize(width: captionsWidth,
                                                 height: bounds.height)
        }
    }
    
    // Private
    var ldx: CGFloat {
        let w: CGFloat = leftStackView.bounds.width + 12.0 + 8.0
        return w
    }
    var rdx: CGFloat {
        let w: CGFloat = rightStackView.bounds.width + 12.0 + 8.0
        return w
    }
    func kTabs(offset: CGFloat?) -> CGFloat {
        let _offset: CGFloat = offset == nil ? self.offset : offset!
        
        var tabsK: CGFloat
        switch displayMode {
        case .smallTitleOnly:
            tabsK = 0.0
        case .largeTitleOnly,
             .largeTitleWithSearchBar:
            if -_offset > tabsExpandedHeight {
                tabsK = 1.0
            } else {
                tabsK = max(0, -_offset / tabsExpandedHeight)
            }
        case .searchBarOnly:
            tabsK = 0.0
        }
        
        print("tabsK: \(tabsK)")
        return tabsK
    }
    func kSearch(offset: CGFloat?) -> CGFloat {
        let _offset: CGFloat = offset == nil ? self.offset : offset!
        
        var searchK: CGFloat
        switch displayMode {
        case .smallTitleOnly,
             .largeTitleOnly:
            searchK = 0.0
        case .searchBarOnly:
            if -_offset > searchBarExpandedHeight {
                searchK = 1.0
            } else {
                searchK = max(0, -_offset / (searchBarExpandedHeight + searchViewTopMargin))
            }
        case .largeTitleWithSearchBar:
            if -_offset > tabsExpandedHeight + searchBarExpandedHeight {
                searchK = 1.0
            } else {
                let searchOffset: CGFloat = -_offset - tabsExpandedHeight
                searchK = max(0, searchOffset / (searchBarExpandedHeight + searchViewTopMargin))
            }
        }
        print("searchK: \(searchK)")
        return searchK
    }
    
    @objc func updateCurrentTabIndex(sender: UIButton) {
        for (ind, b) in self.tabButtons.enumerated() {
            if b == sender {
                currentTabIndex = ind
            }
        }
    }
    
    func updateTitleButtonsColor() {
        for (ind, b) in self.tabButtons.enumerated() {
            b.setTitleColor(ind == currentTabIndex ? activeButtonColor : inactiveButtonColor, for: .normal)
        }
    }
    
    // Subviews
    private var leftStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 8.0
        sv.distribution = .equalSpacing
        sv.axis = .horizontal
        return sv
    }()
    private var rightStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 8.0
        sv.distribution = .equalSpacing
        sv.axis = .horizontal
        return sv
    }()
    private var titleView: HitTestView = {
        let v = HitTestView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var titleScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private var titleStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 12.0
        sv.distribution = .equalSpacing
        sv.axis = .horizontal
        return sv
    }()
    private var searchView: VinciMenuSearchBar = {
        let sv = VinciMenuSearchBar()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Constraints
    private var titleStackViewCenterXConstraint: NSLayoutConstraint!
    private var titleViewLeadingConstraint: NSLayoutConstraint!
    private var titleViewTopConstraint: NSLayoutConstraint!
    private var titleViewHeightConstraint: NSLayoutConstraint!
    private var titleViewTrailingConstraint: NSLayoutConstraint!
    private var searchViewHeightAnchorConstraint: NSLayoutConstraint!
    private var searchViewTrailingConstraint: NSLayoutConstraint!
    private var searchViewLeadingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        
        self.addSubview(leftStackView)
        leftStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0).isActive = true
        leftStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.addSubview(rightStackView)
        rightStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0).isActive = true
        rightStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.addSubview(titleView)
        titleViewLeadingConstraint = titleView.leadingAnchor.constraint(equalTo: leftStackView.trailingAnchor, constant: 8.0)
        titleViewLeadingConstraint.isActive = true
        titleViewTrailingConstraint = titleView.trailingAnchor.constraint(equalTo: rightStackView.leadingAnchor, constant: -8.0)
        titleViewTrailingConstraint.isActive = true
        titleViewTopConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0)
        titleViewTopConstraint.isActive = true
        titleViewHeightConstraint = titleView.heightAnchor.constraint(equalToConstant: bounds.height)
        titleViewHeightConstraint.isActive = true
        
        titleScrollView.addSubview(titleStackView)
        titleStackView.centerYAnchor.constraint(equalTo: titleScrollView.centerYAnchor).isActive = true
        titleStackViewCenterXConstraint = titleStackView.centerXAnchor.constraint(equalTo: titleScrollView.centerXAnchor)
        
        titleView.addSubview(titleScrollView)
        titleScrollView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        titleScrollView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        titleScrollView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        titleScrollView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        
        titleView.addSubview(searchView)
        searchView.searchBar.placeholder = placeholder
        searchView.searchDelegate = searchBarDelegate
        searchView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: searchViewTopMargin).isActive = true
        searchViewLeadingConstraint = searchView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor)
        searchViewLeadingConstraint.isActive = true
        searchViewHeightAnchorConstraint = searchView.heightAnchor.constraint(equalToConstant: 0.0)
        searchViewHeightAnchorConstraint.isActive = true
        searchViewTrailingConstraint = searchView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
        searchViewTrailingConstraint.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recalculateConstraints()
    }
    
    private func recalculateConstraints() {
        let _tabsK = kTabs(offset: nil)
        let _searchK = kSearch(offset: nil)
        let _rdx = rdx
        let _ldx = ldx
        
        // centering tab buttons, if they fit inside scroll view
        if titleScrollView.contentSize.width < titleView.bounds.width {
            titleStackViewCenterXConstraint.isActive = true
            titleStackViewCenterXConstraint.constant = -(titleScrollView.bounds.width / 2.0 - titleStackView.bounds.width / 2.0) * _tabsK
        } else {
            titleStackViewCenterXConstraint.isActive = false
        }
        
        // tabs view
        titleViewLeadingConstraint.constant = (-_ldx) * _tabsK + 8.0 + tabsLeftMargin * _tabsK
        titleViewTrailingConstraint.constant = -8.0 + _tabsK * tabsLeftMargin
        titleViewTopConstraint.constant = bounds.height * _tabsK
        titleViewHeightConstraint.constant = bounds.height + (tabsExpandedHeight - bounds.height) * _tabsK

        for v in titleStackView.arrangedSubviews {
            if let b = v as? UIButton {
                if tabsExpandedFontSize > tabsShrinkedFontSize {
                    let diff: CGFloat = tabsExpandedFontSize - tabsShrinkedFontSize
                    let newFont = b.titleLabel?.font.withSize(tabsShrinkedFontSize + diff * _tabsK)
                    b.titleLabel?.font = newFont
                }
            }
        }
        
        // search view
        searchViewHeightAnchorConstraint.constant = searchBarExpandedHeight * _searchK
        searchViewTrailingConstraint.constant = _rdx - tabsLeftMargin
        if displayMode == .searchBarOnly {
            searchViewLeadingConstraint.constant = -_ldx + tabsLeftMargin
        }
        searchView.update(newHeight: searchBarExpandedHeight * _searchK)
    }
    
    func animateTabsShrink() {
        let offset: CGFloat = 0.0
        animateOffsetChange(offset: offset)
    }
    
    func animateTabsExpand() {
        let offset = -tabsExpandedHeight
        animateOffsetChange(offset: offset)
    }
    
    func animateSearchShrink() {
        let offset = displayMode == .searchBarOnly ? 0.0 : -tabsExpandedHeight
        animateOffsetChange(offset: offset)
    }
    
    func animateSearchExpand() {
        if let inset = scrollView?.contentInset.top {
            animateOffsetChange(offset: -inset)
        } else {
            let offset = -(tabsExpandedHeight + searchBarExpandedHeight)
            animateOffsetChange(offset: offset)
        }
    }
    
    private func animateOffsetChange(offset: CGFloat) {
        UIView.animate(withDuration: 0.15,
                       animations: {
                        self.recalculateConstraints()
                        self.scrollView?.contentOffset = CGPoint(x: 0.0, y: offset)
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
        }) { (_) in
            self.offset = offset
        }
    }
    
    func didEndDragging(offset: CGFloat, velocity: CGFloat) {
        if offset < -expandedHeight {
            return
        }
        
        let slow = abs(velocity) < 250.0
        if !slow {
            return
        }
        
        let inLargeTitle: Bool
        let inSearchBar: Bool
        switch displayMode {
        case .smallTitleOnly:
            inLargeTitle = false
            inSearchBar = false
        case .largeTitleOnly:
            inLargeTitle = offset >= -expandedHeight && offset <= 0
            inSearchBar = false
        case .searchBarOnly:
            inLargeTitle = false
            inSearchBar = offset >= -expandedHeight && offset <= 0
        case .largeTitleWithSearchBar:
            inLargeTitle = offset >= -tabsExpandedHeight && offset <= 0
            inSearchBar = offset >= -expandedHeight && offset < -tabsExpandedHeight
        }
        
        if inLargeTitle {
            let _kTabs = kTabs(offset: offset)
            if _kTabs < 0.5 {
                animateTabsShrink()
            } else if _kTabs >= 0.5 {
                animateTabsExpand()
            }
        } else if inSearchBar {
            let _kSearch = kSearch(offset: offset)
            if _kSearch < 0.5 {
                animateSearchShrink()
            } else if _kSearch >= 0.5 {
                animateSearchExpand()
            }
        }
    }
}
