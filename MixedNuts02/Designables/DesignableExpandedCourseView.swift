//
//  DesignableExpandedCourseView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-22.
//

import UIKit

class DesignableExpandedCourseView: DesignableCourseView {

    //MARK: - Expanded task view customization
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var professorField: DesignableUITextField!
    @IBOutlet weak var urlField: DesignableUITextField!
    @IBOutlet weak var editButton: DesignableUIButton!
    
    //MARK: - Expanded task view instantiation
    override class func instanceFromNib(setCourse: Course, setWeekday: DayOfWeek) -> DesignableExpandedCourseView{
        let course = UINib(nibName: "ExpandedCourseView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableExpandedCourseView
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
            course.linkButton.isEnabled = false
            course.linkButton.tintColor = .lightGray
        } else {
            course.linkButton.isEnabled = true
        }
        
        course.detailsLabel.text = "\(course.courseObj?.code ?? "No Code") • \(course.courseObj?.term ?? "No Term")"
        course.professorField.text = course.courseObj?.prof
        course.urlField.text = course.courseObj?.courseURL
        
        return course
    }
}
