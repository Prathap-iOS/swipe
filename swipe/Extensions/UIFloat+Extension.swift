//
//  UIFloat+Extension.swift
//  swipe
//
//  Created by Prathap Reddy on 18/08/23.
//

import Foundation

extension CGFloat {
    func getMinimum(value2: CGFloat) -> CGFloat {
    if self < value2 {
        return self
    } else
    {
        return value2
        }
    }
}
