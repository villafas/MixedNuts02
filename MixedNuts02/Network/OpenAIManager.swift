import Foundation
import SwiftOpenAI



class OpenAIManager {
    private let apiKey = "APIKEYHERE"
    
    // Async function to create a thread
    private func createThread() async throws -> String {
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let threadParameters = CreateThreadParameters()
        let thread = try await service.createThread(parameters: threadParameters)
        return thread.id
    }

    // Async function to send a message
    
    private func sendMessage(to threadID: String, content: [TaskToDo]) async throws {
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let messageParameters = SwiftOpenAI.MessageParameter(role: SwiftOpenAI.MessageParameter.Role(rawValue: "user")!, content: createMessageBody(tasks: content) ?? "No tasks")
        _ = try await service.createMessage(threadID: threadID, parameters: messageParameters)
    }
    
    private func sendSystemMessage(to threadID: String, content: [TaskToDo]) async throws {
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let messageParameters = SwiftOpenAI.MessageParameter(role: SwiftOpenAI.MessageParameter.Role(rawValue: "assistant")!, content: "How may I help you?")
        _ = try await service.createMessage(threadID: threadID, parameters: messageParameters)
    }
     
     
    // Async function to run the thread
    private func runThread(threadID: String, assistantID: String) async throws -> String {
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let runParameters = SwiftOpenAI.RunParameter(assistantID: assistantID)
        let run = try await service.createRun(threadID: threadID, parameters: runParameters)
        return run.id
    }
    
    private func listLastMessageText(from threadID: String) async throws -> String{
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let message = try await service.listMessages(threadID: threadID, limit: 1, order: nil, after: nil, before: nil, runID: nil)
        let data = message.data[0].content[0]
        switch data {
        case .text(let text):
            return text.text.value
        default:
            return "There was an error getting the response from the Assistant. Please try again."
        }
    }
    
    private func listLastMessageWithTask(from threadID: String) async throws -> (String, TaskToDo?){
        let service = OpenAIServiceFactory.service(apiKey: apiKey)
        let message = try await service.listMessages(threadID: threadID, limit: 1, order: nil, after: nil, before: nil, runID: nil)
        let data = message.data[0].content[0]
        
        switch data {
        case .text(let text):
            return parseAPIResponse(from: (text.text.value))!
        default:
            return ("There was an error getting the response from the Assistant. Please try again.", nil)
        }
    }
    
    // Poll for the run's status at regular intervals
    func pollRunStatus(runID: String, threadID: String) async throws -> Run {
        let url = URL(string: "https://api.openai.com/v1/threads/\(threadID)/runs/\(runID)")!
        print(url)
        while true {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")

            let (data, _) = try await URLSession.shared.data(for: request)
            let run = try JSONDecoder().decode(Run.self, from: data)

            print("Current Status: \(run.status)")
            
            // Check if the run has completed or failed
            if run.status == "completed" || run.status == "failed" {
                return run
            }

            // Wait 2 seconds before the next poll
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        }
    }

    
    // Public method to manage the workflow
    func performToDoAssistantOperations(message: [TaskToDo], assistantID: String, completion: @escaping (Result<(String, TaskToDo?), Error>) -> Void) {
        Task {
            do {
                // Create a thread
                let threadID = try await createThread()
                //print("Thread created with ID: \(threadID)")

                try await sendSystemMessage(to: threadID, content: message)
                
                // Send a message
                try await sendMessage(to: threadID, content: message)
                
                // run thread
                let runID = try await runThread(threadID: threadID, assistantID: assistantID)

                // wait until run is done
                try await pollRunStatus(runID: runID, threadID: threadID)
                
                // list the new message
                let message = try await listLastMessageWithTask(from: threadID)

                completion(.success((message)))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func performDoneAssistantOperations(message: [TaskToDo], assistantID: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                // Create a thread
                let threadID = try await createThread()
                //print("Thread created with ID: \(threadID)")

                try await sendSystemMessage(to: threadID, content: message)
                
                // Send a message
                try await sendMessage(to: threadID, content: message)
                
                // run thread
                let runID = try await runThread(threadID: threadID, assistantID: assistantID)

                // wait until run is done
                try await pollRunStatus(runID: runID, threadID: threadID)
                
                // list the new message
                let message = try await listLastMessageText(from: threadID)

                completion(.success((message)))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    // Sends a list of tasks to your assistant
    /*
    func sendTasksToAssistant(assistantID: String, tasks: [Task], completion: @escaping (Result<String, Error>) -> Void) {
        let requestURL = "/\(assistantID)/threads"
        guard let requestBody = createRequestBody(tasks: tasks) else {
            completion(.failure(NSError(domain: "Invalid Request", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Convert data to string to debug
            if let jsonString = String(data: data!, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            guard let data = data, let decodedResponse = try? JSONDecoder().decode(AssistantResponse.self, from: data) else {
                completion(.failure(NSError(domain: "Decoding Error", code: 500, userInfo: nil)))
                return
            }

            // Extract the content from the assistant's response
            let responseText = decodedResponse.message.content
            completion(.success(responseText))
        }
        task.resume()
    }
     */

    func sendTasksDone(assistantID: String, tasks: [TaskToDo], completion: @escaping (Result<String, Error>) -> Void) {

        performDoneAssistantOperations(message: tasks, assistantID: assistantID) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendTasksToDo(assistantID: String, tasks: [TaskToDo], completion: @escaping (Result<(String, TaskToDo?), Error>) -> Void) {

        performToDoAssistantOperations(message: tasks, assistantID: assistantID) { result in
            switch result {
            case .success(let content):
                completion(.success(content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createMessageBody(tasks: [TaskToDo]) -> String? {
        // Convert tasks to a formatted string
        let taskDescriptions = tasks.map { task in
            var description = "\(task.title)\nCourse: \(task.course)\nDue: \(task.dueDate.formatted())"
            if let notes = task.notes {
                description += "\nNotes: \(notes)"
            }
            description += "\nWeight: \(task.markWeight != nil ? "\(task.markWeight!)%" : "N/A")"
            description += "\nCompleted: \(task.isComplete ? "Yes" : "No")"
            return description
        }.joined(separator: "\n\n") // Separate tasks with an extra line

        return taskDescriptions
    }
    
    func parseAPIResponse(from jsonString: String) -> (String, TaskToDo)? {
        guard let jsonData = jsonString.data(using: .utf8) else {
               print("Failed to convert JSON string to Data.")
               return nil
           }
        
        do {
            // Debugging: Print the raw JSON as string
            
            // Decode the JSON into APIResponse object
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: jsonData)
            
            // Extract the text response and task object
            let textResponse = decodedResponse.textResponse
            let task = decodedResponse.task
            
            print(textResponse)
            print(task)
            
            return (textResponse, task)
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}

struct Run: Codable {
    let id: String
    let status: String
    let result: String? // Adjust fields based on actual response structure
}

struct APIResponse: Codable {
    let textResponse: String
    let task: TaskToDo
}
