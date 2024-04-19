//
//  DesignableUITextField.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit

@IBDesignable
class DesignableUITextView: UITextView {
    //MARK: - TextView customization
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var bkgColor: UIColor = UIColor.white{
        didSet {
            backgroundColor = bkgColor
            updateView()
        }
    }
    
    @IBInspectable var inset: CGFloat = 0{
        didSet{
            textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            updateView()
        }
    }
    
    func updateView() {
        layer.borderWidth = 1.0
        layer.borderColor = color.cgColor
        layer.cornerRadius = 20.0
        // placeholder position
        
        // Placeholder text color
        //attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }

}
