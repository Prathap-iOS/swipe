//
//  ProductListModel.swift
//  swipe
//
//  Created by Prathap Reddy on 17/08/23.
//

import Foundation

struct ProductList: Decodable {
    let image : String
    let product_name : String
    let product_type : String
    let price : Float
    let tax : Float
}
