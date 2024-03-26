//
//  DesignablePopUp.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit

@IBDesignable
class DesignablePopUpCard: UIView {
    
    //@IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
            backgroundColor = bkgColor
            updateView()
        }
    }
    

    func updateView() {
        
    }

}
