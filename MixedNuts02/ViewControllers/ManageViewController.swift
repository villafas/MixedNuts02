//
//  ManageViewController.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit
import Firebase

class ManageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var completeBtn: UIButton!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet var popupDeleteView: UIView!
    @IBOutlet var popupDoneView: UIView!
    @IBOutlet weak var taskTable: SelfSizedTableView!
    
    var db: Firestore!
    
    struct DaySection {
        var day: String
        var tasks: [Task]
        
        init(day: String, tasks: [Task]){
            self.day = day
            self.tasks = tasks
        }
    }
    
    var sections = [DaySection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupDeleteView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        popupDoneView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        db = Firestore.firestore()
        
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self

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
                    } else {
                        dateTitle = formatter.string(from: task.dueDate.startOfDay)
                    }
                    // start sections
                    if self.sections.count == 0 {
                        self.sections.append(DaySection(day: dateTitle, tasks: [task]))
                    } else {
                        var added = false
                        for i in 0..<self.sections.count {
                            if self.sections[i].day == dateTitle {
                                self.sections[i].tasks.append(task)
                                added = true
                                break
                            }
                        }
                        if added == false {
                            self.sections.append(DaySection(day: dateTitle, tasks: [task]))
                        }
                    }
                }
                print(self.sections)
                self.taskTable.reloadData();
            }
        }


    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitle")! as! SectionTitleView
        cell.title!.text = sections[section].day
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        if let viewWithTag = cell.contentView.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
        }
        let section = self.sections[indexPath.section]
        let task = section.tasks[indexPath.row]
        
        let taskView = DesignableEditTaskView.instanceFromNib(setTask: task)
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.tag = 100
        cell.contentView.addSubview(taskView)
        return cell
    }
    
    
    @IBAction func showDeleteAction(_ sender: Any) {
            animateScaleIn(desiredView: popupDeleteView)
        }
        
    @IBAction func doneDeleteAction(_ sender: Any) {
            animateScaleOut(desiredView: popupDeleteView)
        }
    
    @IBAction func showDoneAction(_ sender: Any) {
            animateScaleIn(desiredView: popupDoneView)
        }
        
    @IBAction func doneDoneAction(_ sender: Any) {
            animateScaleOut(desiredView: popupDoneView)
        }
    
        
    /// Animates a view to scale in and display
    func animateScaleIn(desiredView: UIView) {
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
