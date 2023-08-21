//
//  Data+Extensions.swift
//  swipe
//
//  Created by Prathap Reddy on 18/08/23.
//

import Foundation

public extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
