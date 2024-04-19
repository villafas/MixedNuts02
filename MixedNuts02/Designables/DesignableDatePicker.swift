//
//  DesignableDatePicker.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit

@IBDesignable
class DesignableDatePicker: UIDatePicker {
    //MARK: - Date picker customization
    
    @IBInspectable var align: CGFloat = 0{
        didSet {
            updateView()
        }
    }
    
    func updateView(){
        self.contentHorizontalAlignment = .center
    }

}
