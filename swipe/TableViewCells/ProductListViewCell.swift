//
//  ProductListViewCell.swift
//  swipe
//
//  Created by Prathap Reddy on 17/08/23.
//

import UIKit
import SkeletonView

class ProductListViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var taxesLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
        
        productImageView.showAnimatedSkeleton()
        [productNameLabel, productTypeLabel, priceLabel, taxesLabel].forEach
        { $0?.showAnimatedSkeleton() }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func hideAnimation() {
        productImageView.hideSkeleton()
        [productNameLabel, productTypeLabel, priceLabel, taxesLabel].forEach
        { $0?.hideSkeleton() }
    }
}
