//
//  HitTestView.swift
//  NavigationBarItem
//
//  Created by Артём Зайцев on 21.10.2019.
//  Copyright © 2019 Артём Зайцев. All rights reserved.
//

import UIKit


// Getting touches outside it's view's frame
// (https://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest)

class HitTestView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if clipsToBounds {
            return nil
        }

        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }

        return nil
    }
}
