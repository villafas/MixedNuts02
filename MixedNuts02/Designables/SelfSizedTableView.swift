//
//  SelfSizedTableView.swift
//  MixedNuts02
//
//  Created by Default User on 3/21/24.
//

import UIKit

class SelfSizedTableView: UITableView {

    override var contentSize:CGSize{
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize{
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}
