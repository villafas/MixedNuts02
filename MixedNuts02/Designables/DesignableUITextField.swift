//
//  DesignableUITextField.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit

@IBDesignable
class DesignableUITextField: UITextField, UITextFieldDelegate {
    //MARK: - Text Field customization
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
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
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
        // placeholder position
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: insetX + leftPadding, dy: insetY)
        }

        // text position
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: insetX + leftPadding, dy: insetY)
        }
    
    func updateView() {
        self.delegate = self
        layer.borderWidth = 1.0
        layer.borderColor = color.cgColor
        layer.cornerRadius = 20.0
        // placeholder position
        
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        //attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true;
    }

}
