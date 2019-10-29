import UIKit

extension UIImage {

    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

class VinciMenuSearchBar: UIView {
    
    var searchBar = UISearchBar()
    var searchTextField: UITextField?
    var glassIconView: UIImageView?
    var glassIconImage: UIImage?
    var searchTextFieldHeightConstraint: NSLayoutConstraint!
    // FIXME: Vinci font
    var font: UIFont = .systemFont(ofSize: 13.0)
    var textColor: UIColor = .black
    
    var cancelButton: UIButton!
    var cancelButtonRightConstraint: NSLayoutConstraint!
    
    var searchDelegate: UISearchBarDelegate?
    
    let heightForBlindUdate:CGFloat = 0.0
    
    let searchBarSearchFieldHeight:CGFloat = 36.0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        if searchBar.constraints.isEmpty {
            
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            addSubview(searchBar)
            searchBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
            searchBar.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0).isActive = true
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            searchBar.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0).isActive = true
            
            searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            searchBar.showsCancelButton = false
            
            searchBar.delegate = self
        } else if searchTextFieldHeightConstraint != nil {
            return
        }
        
        if let textFieldInsideSearchBar = searchBar.value(forKey:"searchField") as? UITextField {
            textFieldInsideSearchBar.layer.backgroundColor = UIColor(hex: "#F4F4F4")?.cgColor
            textFieldInsideSearchBar.layer.cornerRadius = 8
            
            if let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
                //Magnifying glass
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor(hex: "#B1B1B1")
                
                glassIconImage = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                
                self.glassIconView = glassIconView
            }
            
            textFieldInsideSearchBar.font = font
            textFieldInsideSearchBar.font = font
            textFieldInsideSearchBar.textColor = textColor
            textFieldInsideSearchBar.backgroundColor = UIColor.clear
            
            textFieldInsideSearchBar.translatesAutoresizingMaskIntoConstraints = false
            searchTextField = textFieldInsideSearchBar
            
            // looking for height constraint of searchTextField
            if let _ = (textFieldInsideSearchBar.constraints.filter{$0.firstAttribute == .height}.first) {
                searchTextFieldHeightConstraint = NSLayoutConstraint.init(item: textFieldInsideSearchBar, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: searchBarSearchFieldHeight)
                
                searchTextField?.addConstraint(searchTextFieldHeightConstraint)
                searchTextFieldHeightConstraint.isActive = true
            }
            
            textFieldInsideSearchBar.leftAnchor.constraint(equalTo: searchBar.leftAnchor, constant: 0.0).isActive = true

            let centerYConstraint = textFieldInsideSearchBar.centerYAnchor.constraint(equalTo: centerYAnchor)
            centerYConstraint.isActive = true
        }
        
        if cancelButton == nil {
            cancelButton = UIButton(type: .system)
            cancelButton.setTitle("Cancel", for: .normal)
            searchBar.addSubview(cancelButton)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.addTarget(self, action: #selector(searchBarCancelButtonPressed), for: .touchUpInside)
            
            cancelButton.sizeToFit()
            cancelButton.widthAnchor.constraint(equalToConstant: cancelButton.bounds.width).isActive = true
            
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
            cancelButtonRightConstraint = cancelButton.rightAnchor.constraint(equalTo: searchBar.rightAnchor, constant: cancelButton.frame.width)
            cancelButtonRightConstraint.isActive = true
            
            searchTextField?.rightAnchor.constraint(equalTo: cancelButton.leftAnchor, constant: -15.0).isActive = true
        }
        
        if searchTextFieldHeightConstraint != nil {
            update(newHeight: heightForBlindUdate)
        }
    }
    
    public func update(newHeight: CGFloat) {
        // difine searchTextField frame
        if let _ = searchTextField?.frame {
            
            let searchFieldVerticalBorders:CGFloat = 4.0
            let newSearchFieldFrameHeight = searchBar.frame.height - searchFieldVerticalBorders * 2

            if newSearchFieldFrameHeight <= searchBarSearchFieldHeight && newSearchFieldFrameHeight > 0 {
                searchTextFieldHeightConstraint?.constant = newSearchFieldFrameHeight
            } else if newSearchFieldFrameHeight < 0 {
                searchTextFieldHeightConstraint?.constant = 0.0
            } else if newSearchFieldFrameHeight > searchBarSearchFieldHeight {
                searchTextFieldHeightConstraint?.constant = searchBarSearchFieldHeight
            }
            
            let newAlpha = (newSearchFieldFrameHeight - (searchBarSearchFieldHeight - 6.0)) / 6.0
            
            if newSearchFieldFrameHeight <= searchBarSearchFieldHeight && newSearchFieldFrameHeight >= (searchBarSearchFieldHeight - 6.0) {
                updateAlpha(view: glassIconView, alpha: newAlpha)
            } else if newSearchFieldFrameHeight < (searchBarSearchFieldHeight - 6.0) {
                updateAlpha(view: glassIconView, alpha: 0.0)
            } else if newSearchFieldFrameHeight > searchBarSearchFieldHeight {
                updateAlpha(view: glassIconView, alpha: 1.0)
            }

            for subview in searchTextField!.subviews {
                
                for subsubView in subview.subviews {
                    if newSearchFieldFrameHeight <= searchBarSearchFieldHeight && newSearchFieldFrameHeight >= (searchBarSearchFieldHeight - 6.0) {
                        updateAlpha(view: subsubView, alpha: newAlpha)
                    } else if newSearchFieldFrameHeight < (searchBarSearchFieldHeight - 6.0) {
                        updateAlpha(view: subsubView, alpha: 0.0)
                    } else if newSearchFieldFrameHeight > searchBarSearchFieldHeight {
                        updateAlpha(view: subsubView, alpha: 1.0)
                    }
                }

                if newSearchFieldFrameHeight <= searchBarSearchFieldHeight && newSearchFieldFrameHeight >= (searchBarSearchFieldHeight - 6.0) {
                    updateAlpha(view: subview, alpha: newAlpha)
                } else if newSearchFieldFrameHeight < (searchBarSearchFieldHeight - 6.0) {
                    updateAlpha(view: subview, alpha: 0.0)
                } else if newSearchFieldFrameHeight > searchBarSearchFieldHeight {
                    updateAlpha(view: subview, alpha: 1.0)
                }
            }
            
            searchBar.layoutIfNeeded()
        }
    }
    
    private func updateAlpha(view: UIView?, alpha: CGFloat) {
        view?.tintColor = view?.tintColor.withAlphaComponent(alpha)
        view?.alpha = alpha
        
        if let label = view as? UILabel {
            label.textColor = label.textColor.withAlphaComponent(alpha)
        }
    }
    
    @objc func searchBarCancelButtonPressed() {
        self.searchBarCancelButtonClicked(searchBar)
    }
    
    public func searchBarIsReady() {
        cancelButtonRightConstraint.constant = -15.0
        UIView.animate(withDuration: 0.1) {
            self.cancelButton.alpha = 1.0
            self.layoutIfNeeded()
        }
    }
}

extension VinciMenuSearchBar : UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchDelegate?.searchBarTextDidEndEditing?(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchDelegate?.searchBarCancelButtonClicked?(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchDelegate?.searchBarSearchButtonClicked?(searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchDelegate?.searchBarTextDidBeginEditing?(searchBar)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        self.searchDelegate?.searchBarBookmarkButtonClicked?(searchBar)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        self.searchDelegate?.searchBarResultsListButtonClicked?(searchBar)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        cancelButton.sizeToFit()
        cancelButtonRightConstraint.constant = cancelButton.frame.width
        UIView.animate(withDuration: 0.1) {
            self.cancelButton.alpha = 0.0
            self.layoutIfNeeded()
        }
        return self.searchDelegate?.searchBarShouldEndEditing?(searchBar) ?? true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return self.searchDelegate?.searchBarShouldBeginEditing?(searchBar) ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchDelegate?.searchBar?(searchBar, textDidChange: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.searchDelegate?.searchBar?(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return self.searchDelegate?.searchBar?(searchBar, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
}
