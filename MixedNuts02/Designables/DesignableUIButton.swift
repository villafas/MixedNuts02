//
//  DesignableUIButton.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit

@IBDesignable
class DesignableUIButton: UIButton {
    //MARK: - Button customization
    
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
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
            
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.lightGray {
        didSet {
            
        }
    }

    func updateView() {
        
    }
    
    func setDisabled(){
        self.isUserInteractionEnabled = false
        configuration?.baseBackgroundColor = UIColor.lightGray
        configuration?.baseForegroundColor = .darkGray
    }
    
    func setEnabled(){
        self.isUserInteractionEnabled = true
        configuration?.baseBackgroundColor = self.bkgColor
        configuration?.baseForegroundColor = self.textColor
    }

}
