//
//  DesignableUIView.swift
//  Milestone2
//
//  Created by Default User on 3/15/24.
//

import UIKit

@IBDesignable
class DesignableTaskView: UIView {

    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDate: UILabel!
    @IBOutlet weak var taskButton: UIButton!
    var viewHeight = 81.0
    var viewWidth = 353.0
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
            backgroundColor = bkgColor
        }
    }
    

    func updateView() {
        
    }
    
    class func instanceFromNib() -> DesignableTaskView{
        return UINib(nibName: "TaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableTaskView
    }

    
    
    
}
