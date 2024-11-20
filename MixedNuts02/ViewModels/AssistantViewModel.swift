//
//  AssistantViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-29.
//

import Foundation

//MARK: - Variables

class AssistantViewModel {
    
    private let firebaseManager = FirebaseManager.shared
    
    var errorMessage: String?
    
    var completedTaskList: [TaskToDo]!
    var responseText: String?
    var responseTask: TaskToDo?
    
    var onToDoResponseGenerated: (() -> Void)?
    var onDoneResponseGenerated: (() -> Void)?
    var onTasksFetched: (() -> Void)?
    var onWeeklyTasksFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    
    let toDoAssistantID = "ASSISTANT1IDHERE"  // Replace with your assistant's ID
    let doneAssistantID = "ASSISTANT2IDHERE"
    let openAIManager = OpenAIManager()
    
    //MARK: - Methods
    func askToDo(tasks: [TaskToDo]){
        openAIManager.sendTasksToDo(assistantID: toDoAssistantID, tasks: completedTaskList) { result in
            switch result {
            case .success(let response):
                self.responseText = response.0
                self.responseTask = response.1
                self.onToDoResponseGenerated?()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.onError?(self.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    
    func askComplete(tasks: [TaskToDo]){
        openAIManager.sendTasksDone(assistantID: doneAssistantID, tasks: completedTaskList) { result in
            switch result {
            case .success(let textResponse):
                self.responseText = textResponse
                self.onDoneResponseGenerated?()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.onError?(self.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    
    func fetchTasks() {
        firebaseManager.fetchTasks() { [weak self] result in
            switch result {
            case .success(let fetchedTasks):
                self?.completedTaskList = [TaskToDo]()
                self?.completedTaskList = fetchedTasks
                self?.onTasksFetched?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func fetchWeeklyTasks(){
        firebaseManager.fetchWeeklyTasks() { [weak self] result in
            switch result {
            case .success(let fetchedTasks):
                self?.completedTaskList = [TaskToDo]()
                self?.completedTaskList = fetchedTasks
                self?.onWeeklyTasksFetched?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
}
