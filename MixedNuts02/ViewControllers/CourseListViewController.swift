//
//  CourseListViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-12.
//

import UIKit

class CourseListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChildViewDelegate {

    var parentView: CourseContainerViewController?
    
    @IBOutlet weak var courseTable: SelfSizedTableView!
    var selectedRow: IndexPath?
    
    @IBOutlet var popupDeleteView: UIView!
    
    private let viewModel = CourseListViewModel()
    var tempID: String?
    
    var performEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bounds for popups
        popupDeleteView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        // Bind ViewModel to ViewController
        bindViewModel()
        
        // Do any additional setup after loading the view.
        courseTable.register(UITableViewCell.self, forCellReuseIdentifier: "course")
        courseTable.delegate = self
        courseTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get Tasks
        refreshCourses()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onCoursesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.courseTable.reloadData();
                if self?.tempID != nil {
                    self?.selectTempCourse()
                }
            }
        }
        
        viewModel.onCourseDeleted = { [weak self] in
            DispatchQueue.main.async {
                self?.tempID = nil
                self?.animateScaleOut(desiredView: self!.popupDeleteView)
                self?.selectedRow = nil
                self?.refreshCourses()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                // Show error message (e.g., using an alert)
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    //MARK: - Data Reading & Writing
    func refreshCourses(){
        viewModel.fetchCourses()
    }
    
    func deleteCourse(id: String){
        viewModel.deleteCourse(courseID: id)
    }
    
    //MARK: - Course editing
    
    // Button action that triggers the segue
    @objc func editButtonTapped() {
        // Trigger the segue programmatically
        performEdit = true
        performSegue(withIdentifier: "editCourseSegue", sender: self)
    }
    
    // Prepare data for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCourseSegue" {
            if let destinationVC = segue.destination as? AddCourseViewController {
                // Get the destination view controller
                if performEdit, let selectedCourse = courseTable.cellForRow(at: selectedRow!)?.contentView.viewWithTag(100) as? DesignableExpandedCourseView {
                    // Pass data to the destination view controller
                    destinationVC.courseObj = selectedCourse.courseObj
                    destinationVC.isEditMode = true
                    performEdit = false
                }
                
                destinationVC.onDismiss = { [weak self] data in
                    self?.tempID = data
                    self?.refreshCourses()
                }
            }
        }
    }
    
    //MARK: - Temp Course selection
    
    func selectTempCourse(){
        // iterate through the tasks in each section to find the task corresponding to the notification
        for section in 0..<viewModel.courseCollection.count{
            var count = 0
            for course in viewModel.courseCollection[section].courses {
                if course.id == self.tempID {
                    let index = IndexPath(row: count, section: section)
                    self.selectedRow = index
                    courseTable.selectRow(at: index, animated: true, scrollPosition: .middle)
                    self.tempID = nil
                    return
                }
                count += 1
            }
        }
    }
    
    
    //MARK: - Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.courseCollection.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // section title
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitle")! as! SectionTitleView
        let courseWeekday = viewModel.courseCollection[section].weekday
        let dateTitle = courseWeekday.rawValue.capitalized
        
        cell.title!.text = dateTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.courseCollection[section]
        return section.courses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let numberOfSections = tableView.numberOfSections
        
        // if task is selected, expand its size
        if indexPath == self.selectedRow{
            if indexPath.section != numberOfSections - 1 && indexPath.row == numberOfRows - 1 {
                // This is the last row in the section if it's selected
                return 362.0
            } else {
                // For other selected rows
                return 377.0
            }
        }
        
        if indexPath.section != numberOfSections - 1 && indexPath.row == numberOfRows - 1 {
            // This is the last row in the section if it's not selected
            return 81.0
        }
        
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell configuration
        let cell = tableView.dequeueReusableCell(withIdentifier: "course", for: indexPath)
        cell.selectionStyle = .none
        if let viewWithTag = cell.contentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        let section = viewModel.courseCollection[indexPath.section]
        let course = section.courses[indexPath.row]
        
        // if selected, show expanded task
        if (indexPath == self.selectedRow){
            let courseView = DesignableExpandedCourseView.instanceFromNib(setCourse: course, setWeekday: section.weekday)
            courseView.translatesAutoresizingMaskIntoConstraints = false
            courseView.heightAnchor.constraint(equalToConstant: 362).isActive = true
            courseView.widthAnchor.constraint(equalToConstant: courseTable.frame.width).isActive = true
            courseView.tag = 100
            courseView.deleteButton.removeTarget(nil, action: nil, for: .allEvents)
            courseView.deleteButton.addTarget(self, action: #selector(showDeleteAction(_:)), for: .touchUpInside)
            courseView.editButton.removeTarget(nil, action: nil, for: .allEvents)
            courseView.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            courseView.delegate = self
            
            cell.contentView.addSubview(courseView)
            return cell
        }
        
        // otherwise, show regular task view
        let courseView = DesignableCourseView.instanceFromNib(setCourse: course, setWeekday: section.weekday)
        courseView.translatesAutoresizingMaskIntoConstraints = false
        courseView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        courseView.widthAnchor.constraint(equalToConstant: courseTable.frame.width).isActive = true
        courseView.tag = 100
        courseView.delegate = self
        cell.contentView.addSubview(courseView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selection
        if indexPath == self.selectedRow {
            self.courseTable.deselectRow(at: indexPath, animated: true)
            self.selectedRow = nil
        } else {
            self.selectedRow = indexPath
        }
        self.courseTable.reloadData()
        self.courseTable.scrollToRow(at: indexPath, at: .none, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // row deselection
        self.selectedRow = nil
    }
    
    //MARK: - Child View Delegate
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a default OK action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert on the current view controller
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Delete task
    @IBAction func showDeleteAction(_ sender: UIButton) {
        // show delete popup
        if let card = popupDeleteView.viewWithTag(95) as! DesignablePopUpCard?, let courseView = sender.superview?.superview as? DesignableExpandedCourseView? {
            card.titleLabel.text = "\(courseView!.courseObj!.title)"
            tempID = courseView!.courseObj!.id
        }
        animateScaleIn(desiredView: popupDeleteView, doneOrCancel: false)
    }
    
    @IBAction func doneDeleteAction(_ sender: UIButton) {
        // delete is confirmed, so delete document
        if sender.tag == 91 {
            deleteCourse(id: tempID!)
        } else { // if cancel button pressed
            tempID = nil
            animateScaleOut(desiredView: popupDeleteView)
        }
        
    }
    
    //MARK: - Popup animations
    /// Animates a view to scale in and display
    func animateScaleIn(desiredView: UIView, doneOrCancel: Bool) {
        let backgroundView = self.view!
        backgroundView.addSubview(desiredView)
        desiredView.center = backgroundView.center
        desiredView.isHidden = false
        
        
        
        desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        desiredView.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
            //            desiredView.transform = CGAffineTransform.identity
        }
    }
    
    /// Animates a view to scale out remove from the display
    func animateScaleOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            desiredView.alpha = 0
        }, completion: { (success: Bool) in
            desiredView.removeFromSuperview()
        })
        
        UIView.animate(withDuration: 0.2, animations: {
            
        }, completion: { _ in
            
        })
    }
}
