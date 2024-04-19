//
//  DesignableViewBox.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit

class DesignableViewBox: UIView {
    //MARK: - View customization (Rounded corners)
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
                updateView()    
            }
        }

    func updateView(){
        
    }
    
}
