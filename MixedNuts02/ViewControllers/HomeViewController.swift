//
//  HomeViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//
    
import UIKit
import EventKit

@IBDesignable
class HomeViewController: UIViewController {
    
    @IBOutlet var calendarViewBox: UIView!
    @IBOutlet weak var taskStackView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBInspectable var decorationColor: UIColor!
    @IBInspectable var tintColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendarView()
        taskStackView.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
    }
    
    private func configureCalendarView(){
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.tintColor = tintColor
        calendarViewBox.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarViewBox.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarViewBox.trailingAnchor),
            calendarView.centerXAnchor.constraint(equalTo: calendarViewBox.centerXAnchor)
        ])
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        calendarView.delegate = self
    }
    
    private func createTask(_ title: String, _ time: String){
        var task = DesignableTaskView.instanceFromNib()
        task.translatesAutoresizingMaskIntoConstraints = false
        task.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskStackView.addArrangedSubview(task)
        
        task.taskTitle.text = title
        task.taskDate.text = time
    }
    
}

extension HomeViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        //print(dateComponents)
        var day = dateComponents!.day
        if day == 15 {
            createTask("ICE 14 Advanced Java Frameworks", "7:00PM, 15/March")
            createTask("Assignment 2 iOS Development", "11:59PM, 15/March")
            createTask("Quiz 5 Software Management", "11:59PM, 15/March")
            subtitleLabel.text = "You have 3 tasks for the day"
            
        } else {
            taskStackView.arrangedSubviews.forEach{(element) in
                if element is DesignableTaskView{
                    taskStackView.removeArrangedSubview(element)
                    element.removeFromSuperview()   
                }
            }
            subtitleLabel.text = "You have 5 remaining tasks for this week"
        }
    }
}

extension HomeViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        //let font = UIFont(name:"Poppins-Regular", size: 14)
    guard let day = dateComponents.day else {
        return nil
    }

        if !day.isMultiple(of: 2) {
        return UICalendarView.Decoration.default(color: decorationColor, size: .small)
    }

    return nil
    }
}
