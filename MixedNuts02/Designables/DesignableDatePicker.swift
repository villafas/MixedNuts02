//
//  DesignableDatePicker.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit

@IBDesignable
class DesignableDatePicker: UIDatePicker {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var align: CGFloat = 0{
        didSet {
            updateView()
        }
    }
    
    func updateView(){
        self.contentHorizontalAlignment = .center
    }

}
