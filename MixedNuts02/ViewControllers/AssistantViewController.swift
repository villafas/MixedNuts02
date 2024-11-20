//
//  AssistantViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-29.
//

import UIKit

class AssistantViewController: UIViewController {
    
    @IBOutlet weak var navBarBottom: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var toDoBox: DesignableQuestionView!
    @IBOutlet weak var doneBox: DesignableQuestionView!
    @IBOutlet weak var taskBox: UIView!
    
    @IBOutlet weak var responseStack: UIStackView!
    @IBOutlet weak var responseLabel: UILabel!
    
    private let viewModel = AssistantViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        
        // Do any additional setup after loading the view.
        navBarBottom.dropShadow()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onTasksFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.askAssistantToDo()
            }
        }
        
        viewModel.onWeeklyTasksFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.askAssistantDone()
            }
        }
        
        
        viewModel.onToDoResponseGenerated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateResponse()
                self?.showTaskResponse()
                self?.enableButtons()
            }
        }
        
        viewModel.onDoneResponseGenerated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateResponse()
                self?.enableButtons()
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
    
    func askAssistantToDo(){
        viewModel.askToDo(tasks: viewModel.completedTaskList)
    }
    
    func askAssistantDone(){
        viewModel.askComplete(tasks: viewModel.completedTaskList)
    }
    
    func fetchWeeklyTasks(){
        viewModel.fetchWeeklyTasks()
    }
    
    func fetchTasks(){
        viewModel.fetchTasks()
    }
    
    //MARK: - UI Update
    func showResponseLoading(){
        responseStack.isHidden = false
        responseLabel.text = "Loading..."
        taskBox.isHidden = true
    }
    
    func updateResponse(){
        responseLabel.text = viewModel.responseText
    }
    
    func showTaskResponse(){
        setTaskView()
        responseStack.isHidden = false
        taskBox.isHidden = false
    }
    
    func disableButtons(){
        toDoBox.setDisabled()
        doneBox.setDisabled()
    }
    
    func enableButtons(){
        toDoBox.setEnabled()
        doneBox.setEnabled()
    }
    
    func setTaskView(){
        if let viewWithTag = taskBox.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        
        if let task = viewModel.responseTask {
            let taskView = DesignableTaskView.instanceFromNib(setTask: task)
            taskView.translatesAutoresizingMaskIntoConstraints = false
            taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
            taskView.widthAnchor.constraint(equalToConstant: taskBox.frame.width).isActive = true
            taskView.tag = 100
            //taskView.taskButton.removeTarget(nil, action: nil, for: .allEvents)
            //taskView.taskButton.addTarget(self, action: #selector(showDoneAction(_:)), for: .touchUpInside)
            taskBox.addSubview(taskView)
        }
    }
    
    //MARK: - Button actions
    
    @IBAction func toDoTapped(_ sender: UIButton) {
        fetchTasks()
        disableButtons()
        showResponseLoading()
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        fetchWeeklyTasks()
        disableButtons()
        showResponseLoading()
    }

}
