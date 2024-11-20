//
//  DesignableQuestionView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-30.
//

import Foundation
import UIKit

class DesignableQuestionView: UIView {

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var questionSubtitle: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
            updateView()
        }
    }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
            backgroundColor = bkgColor
        }
    }
    
    @IBInspectable var inactiveColor: UIColor = UIColor.lightGray {
        didSet{
        }
    }
    
    func updateView() {
        
    }
    
    func setDisabled(){
        tapGesture.isEnabled = false
        backgroundColor = inactiveColor
        arrowButton.isHidden = true
    }
    
    func setEnabled(){
        tapGesture.isEnabled = true
        backgroundColor = bkgColor
        arrowButton.isHidden = false
    }
    
}
