//
//  DesignableUIButton.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit

@IBDesignable
class DesignableUIButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            layer.borderWidth = 1.0
            layer.borderColor = color.cgColor
        }
    }
    

    func updateView() {
        
    }

}
