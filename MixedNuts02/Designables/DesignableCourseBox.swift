//
//  DesignableCourseBox.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-07.
//

import UIKit

class DesignableCourseBox: UIView {
    
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseSubtitle: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
            updateView()
        }
    }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
        }
    }
    
    @IBInspectable var doneColor: UIColor = UIColor.lightGray {
        didSet{
        }
    }
    
    func updateView() {
        
    }
    
    func upcomingCourseNotSet(){
        backgroundColor = doneColor
    }
    
    func upcomingCourseSet(){
        backgroundColor = bkgColor
    }
    
}
