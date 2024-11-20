//
//  ShareTaskViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-27.
//

import UIKit

class ShareTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendTable: SelfSizedTableView!
    @IBOutlet weak var noFriendsBox: UIView!
    @IBOutlet weak var navBarBottom: UIView!
    @IBOutlet weak var shareButton: DesignableUIButton!
    
    var selectedItems: [IndexPath] = []
    
    var taskObj: TaskToDo?
    
    private let viewModel = ShareTaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        friendTable.register(UITableViewCell.self, forCellReuseIdentifier: "friend")
        friendTable.delegate = self
        friendTable.dataSource = self
        
        // Do any additional setup after loading the view.
        navBarBottom.dropShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFriends()
        updateButton()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onTaskSent = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        viewModel.onFriendsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.friendTable.reloadData()
                self?.updateFriendsMessage()
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
    func shareTask(){
        viewModel.shareTask(selectedItems, taskObj!)
    }
    
    func updateFriends(){
        viewModel.fetchFriends()
    }
    
    //MARK: - Data updating
    func updateFriendsMessage(){
        if viewModel.friendsCollection.count == 0 {
            noFriendsBox.isHidden = false
        } else {
            noFriendsBox.isHidden = true
        }
    }
    
    //MARK: - Button actions
    
    @IBAction func sendTaskTapped(_ sender: UIButton) {
        shareTask()
    }
    
    func updateButton(){
        if viewModel.canSendTask {
            shareButton.setEnabled()
        } else {
            shareButton.setDisabled()
        }
    }
    
    //MARK: - Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.friendsCollection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath)
        cell.selectionStyle = .none
        if let viewWithTag = cell.contentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        
        let friendView = DesignableFriendCheckView.instanceFromNib(setFriend: viewModel.friendsCollection[indexPath.row], isTop: indexPath.row == 0, isBottom: indexPath.row == viewModel.friendsCollection.count - 1)
        friendView.translatesAutoresizingMaskIntoConstraints = false
        friendView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        friendView.widthAnchor.constraint(equalToConstant: friendTable.frame.width).isActive = true
        friendView.tag = 100
        
        cell.contentView.addSubview(friendView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let friendView = cell.viewWithTag(100) as? DesignableFriendCheckView {
            if !selectedItems.contains(indexPath) {
                selectedItems.append(indexPath)
            }
            friendView.updateImage(true)
            
            if selectedItems.count > 0 {
                viewModel.canSendTask = true
            } else {
                viewModel.canSendTask = false
            }
            
            updateButton()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let friendView = cell.viewWithTag(100) as? DesignableFriendCheckView {
            selectedItems.removeAll { $0 == indexPath }
            friendView.updateImage(false)
            
            if selectedItems.count > 0 {
                viewModel.canSendTask = true
            } else {
                viewModel.canSendTask = false
            }
            
            updateButton()
        }
    }
}
