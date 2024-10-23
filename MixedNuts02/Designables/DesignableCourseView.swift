//
//  DesignableCourseView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-22.
//

import UIKit

class DesignableCourseView: UIView {
    
    //MARK: - Course View customization
    
    weak var delegate: ChildViewDelegate?
    
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseSubtitle: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    var viewHeight = 81.0
    
    var courseObj: Course?
    
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
    
    
    
    //MARK: - View instantiation
    class func instanceFromNib(setCourse: Course, setWeekday: DayOfWeek) -> DesignableCourseView{
        let course = UINib(nibName: "CourseView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableCourseView
        course.courseObj = setCourse
        course.courseTitle.text = "\(setCourse.title)"
        let courseSchedule = course.courseObj?.schedule.first(where: { $0.day == setWeekday })
        var subtitleText = "No Time"
        if let startTime = courseSchedule!.startTime?.toTodaysDate(),
           let endTime = courseSchedule!.endTime?.toTodaysDate() {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a" // dd/MMM
            subtitleText = "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
        }
        course.courseSubtitle.text = "\(courseSchedule?.classroom ?? "No Classroom") • \(subtitleText)"
        if (course.courseObj?.courseURL ?? "").isEmpty {
            course.linkButton.isHidden = true
        } else {
            course.linkButton.isHidden = false
        }
        
        return course
    }
    
    //MARK: - URL Navigation
    @IBAction func goToUrl(_ sender: Any) {
        if let url = URL(string: (courseObj?.courseURL ?? "")) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    self.delegate?.showAlert(title: "Invalid URL", message: "This link could not be opened. Please edit the URL and ensure it is correct.")
                }
            }
        }
    }
}
