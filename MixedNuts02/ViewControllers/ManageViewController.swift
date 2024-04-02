//
//  ManageViewController.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit
import Firebase

class ManageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet var popupDeleteView: UIView!
    @IBOutlet var popupDoneView: UIView!
    @IBOutlet weak var taskTable: SelfSizedTableView!
    
    var db: Firestore!
    var tempID: String?
    var selectedRow: IndexPath?
    var notifID: String?
    
    struct DaySection {
        var day: String
        var tasks: [Task]
        
        init(day: String, tasks: [Task]){
            self.day = day
            self.tasks = tasks
        }
    }
    
    var sections: [DaySection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupDeleteView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        popupDoneView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db = Firestore.firestore()
        
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self
        
        getData()
    }
    
    func getData(){
        sections = [DaySection]()
        
        db.collection("tasks").whereField("isComplete", isEqualTo: false).order(by: "dueDate").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    var dateTitle = ""
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d"
                    if task.dueDate.startOfDay < Date().startOfDay{
                        dateTitle = "Past"
                    } else if task.dueDate.startOfDay == Date().startOfDay{
                        dateTitle = "Today"
                    } else if task.dueDate.startOfDay == Calendar.current.date(byAdding: .day, value: 1, to: Date())?.startOfDay{
                        dateTitle = "Tomorrow"
                    } else {
                        dateTitle = formatter.string(from: task.dueDate.startOfDay)
                    }
                    // start sections
                    if self.sections!.count == 0 {
                        self.sections!.append(DaySection(day: dateTitle, tasks: [task]))
                    } else {
                        var added = false
                        for i in 0..<self.sections!.count {
                            if self.sections![i].day == dateTitle {
                                self.sections![i].tasks.append(task)
                                added = true
                                break
                            }
                        }
                        if added == false {
                            self.sections!.append(DaySection(day: dateTitle, tasks: [task]))
                        }
                    }
                }
                self.taskTable.reloadData();
                if self.notifID != nil{
                    self.selectNotificationTask()
                }
            }
        }
    }
    
    func selectNotificationTask(){
        for section in 0..<self.sections!.count{
            var count = 0
            for task in self.sections![section].tasks {
                if task.id == notifID {
                    let index = IndexPath(row: count, section: section)
                    self.selectedRow = index
                    taskTable.selectRow(at: index, animated: true, scrollPosition: .middle)
                    notifID = nil
                    return
                }
                count += 1
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitle")! as! SectionTitleView
        cell.title!.text = sections![section].day
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections![section]
        return section.tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedRow{
            return 459.0
        }
        
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        cell.selectionStyle = .none
        if let viewWithTag = cell.contentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        let section = self.sections![indexPath.section]
        let task = section.tasks[indexPath.row]
        
        if (indexPath == selectedRow){
            let taskView = DesignableExpandedTaskView.instanceFromNib(setTask: task)
            taskView.translatesAutoresizingMaskIntoConstraints = false
            taskView.heightAnchor.constraint(equalToConstant: 443).isActive = true
            taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
            taskView.tag = 100
            taskView.deleteButton.addTarget(self, action: #selector(showDeleteAction(_:)), for: .touchUpInside)
            taskView.taskButton.addTarget(self, action: #selector(showDoneAction(_:)), for: .touchUpInside)
            taskView.saveButton.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
            taskView.updateButtons(urlText: taskView.urlField.text!)
            cell.contentView.addSubview(taskView)
            return cell
        }
        
        let taskView = DesignableEditTaskView.instanceFromNib(setTask: task)
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
        taskView.tag = 100
        taskView.deleteButton.addTarget(self, action: #selector(showDeleteAction(_:)), for: .touchUpInside)
        taskView.taskButton.addTarget(self, action: #selector(showDoneAction(_:)), for: .touchUpInside)
        cell.contentView.addSubview(taskView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == self.selectedRow{
            self.taskTable.deselectRow(at: indexPath, animated: true)
            self.selectedRow = nil
        } else {
            self.selectedRow = indexPath
        }
        self.taskTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedRow = nil
    }
    
    func totalItems(_ sections: [DaySection]) -> Int {
        return sections.reduce(0) { $0 + $1.tasks.count }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if let taskView = sender.superview?.superview?.superview as! DesignableExpandedTaskView? {
            let docRef = db.collection("tasks").document(taskView.taskObj!.id)
            docRef.getDocument() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else {
                    querySnapshot!.reference.updateData([
                        "taskURL" : taskView.urlField.text!
                    ])
                    querySnapshot!.reference.updateData([
                        "notes" : taskView.notesView.text!
                    ])
                    self.getData()
                }
            }
        }
    }
    
    @IBAction func showDeleteAction(_ sender: UIButton) {
        if let card = popupDeleteView.viewWithTag(95) as! DesignablePopUpCard?, let taskView = sender.superview?.superview as? DesignableEditTaskView? ?? sender.superview?.superview as? DesignableExpandedTaskView? {
            card.titleLabel.text = "Delete \(taskView!.taskObj!.title)?"
            self.tempID = taskView!.taskObj!.id
        }
        animateScaleIn(desiredView: popupDeleteView, doneOrCancel: false)
    }
        
    @IBAction func doneDeleteAction(_ sender: UIButton) {
        animateScaleOut(desiredView: popupDeleteView)
        if sender.tag == 91 {
            self.deleteNotifications(taskId: self.tempID!, deletePending: true)
            let docRef = db.collection("tasks").document(self.tempID!)
            docRef.getDocument() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else {
                    querySnapshot!.reference.delete()
                    self.selectedRow = nil
                    self.getData()
                }
            }
        } else {
            tempID = nil
        }
    }
    
    @IBAction func showDoneAction(_ sender: UIButton) {
        if let card = popupDoneView as! DesignableDoneCard?, let taskView = sender.superview?.superview as? DesignableEditTaskView? ?? sender.superview?.superview as? DesignableExpandedTaskView?{
            card.titleLabel.text = "\(taskView!.taskObj!.title)"
            card.subtitleLabel.text = "Remaining Tasks: \((totalItems(self.sections!)) - 1)"
            let docRef = db.collection("tasks").document(taskView!.taskObj!.id)
            docRef.getDocument() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else {
                    querySnapshot!.reference.updateData([
                        "isComplete" : true
                    ])
                    self.selectedRow = nil
                    self.getData()
                }
            }
            animateScaleIn(desiredView: popupDoneView, doneOrCancel: true)
        }
    }
        
    @IBAction func doneDoneAction(_ sender: UIButton) {
            animateScaleOut(desiredView: popupDoneView)
        }
    
        
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
