//
//  UILabel+Extension.swift
//  swipe
//
//  Created by Prathap Reddy on 18/08/23.
//

import Foundation
import UIKit

// MARK: Extension on UILabel for adding insets - for adding padding in top, bottom, right, left.

extension UILabel {
private struct AssociatedKeys {
    static var padding = UIEdgeInsets()
}

var padding: UIEdgeInsets? {
    get {
    return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
    }
    set {
    if let newValue = newValue {
        objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    }
}

override open func draw(_ rect: CGRect) {
    if let insets = padding {
        self.drawText(in: rect.inset(by: insets))
    } else {
    self.drawText(in: rect)
    }
}

override open var intrinsicContentSize: CGSize {
    get {
    var contentSize = super.intrinsicContentSize
    if let insets = padding {
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
    }
    return contentSize
    }
}
}
