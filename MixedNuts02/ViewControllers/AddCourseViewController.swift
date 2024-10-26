//
//  AddCourseViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-16.
//

import UIKit

class AddCourseViewController: BaseScrollViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var navBarBottom: UIView!
    
    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var codeField: DesignableUITextField!
    @IBOutlet weak var termField: DesignableUITextField!
    @IBOutlet weak var scheduleTable: SelfSizedTableView!
    @IBOutlet weak var urlField: DesignableUITextField!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var instructorField: DesignableUITextField!
    @IBOutlet weak var instructorButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scheduleButton: UIButton!
    var tapGesture: UITapGestureRecognizer?
    
    let overlayView = UIView()
    
    // Visibility bools
    var isAdditionalFieldVisible = false
    var isUrlFieldVisible = false
    var isInstructorFieldVisible = false
    var isTermDropdownVisible = false
    var ignoreHideOnScroll = false
    
    // Literals
    var ignoreTime = 0.8
    
    // Constraints
    @IBOutlet weak var urlFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var instructorFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalScheduleFieldHeightConstraint: NSLayoutConstraint!
    
    private let viewModel = AddCourseViewModel()
    
    // Dropdown properties
    var termDropdown: DropdownTableView?
    var termOptions: [String] = ["Loading..."]
    
    var scheduleList: [DaySchedule]!
    
    var isEditMode: Bool = false
    var courseObj: Course?
    var onDismiss: ((String?) -> Void)?  // Closure to notify MainViewController
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bind ViewModel to ViewController
        bindViewModel()
        
        navBarBottom.dropShadow()
        
        viewModel.fetchTerms()
        scheduleList = [DaySchedule]()
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        titleField.delegate = self
        codeField.delegate = self
        instructorField.delegate = self
        urlField.delegate = self
        configureOverlayView()
        configureTermDropdown()
        updateAllFieldsVisibility()
        scrollView.delegate = self
        
        hideElementWhenTappedAround()
        
        scrollView.delegate = self
        
        // Do any additional setup after loading the view.
        self.baseScrollView = scrollView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTerms()
        setEditingMode()
    }
    
    //MARK: - Add Course
    
    @IBAction func addCourseButtonTapped(_ sender: UIButton) {
        // Gather input from the text fields
        guard let title = titleField.text, !title.isEmpty,
              let code = codeField.text, !code.isEmpty,
              let term = termField.text, !term.isEmpty,
              !scheduleList.isEmpty,
              validateDaySchedules(schedules: scheduleList) else {
            print("All fields are required.")
            return
        }
        
        // Optional values
        let professor = instructorField.text?.isEmpty == true ? nil : instructorField.text
        let courseURL = urlField.text?.isEmpty == true ? nil : urlField.text
        
        // Here you can save the course object to your database or use it as needed
        
        if isEditMode {
            courseObj = Course(id: courseObj!.id, title: title, code: code, schedule: scheduleList, term: term, prof: professor, courseURL: courseURL)
            
            updateCourse()
        } else {
            viewModel.addCourse(title: title, code: code, schedule: scheduleList, term: term, prof: professor, courseURL: courseURL)
        }
        
        dismissView()
    }
    
    func validateDaySchedules(schedules: [DaySchedule]) -> Bool {
        for schedule in schedules {
            if let day = schedule.day,
               let startTime = schedule.startTime,
               let endTime = schedule.endTime,
               let classroom = schedule.classroom {
                // All fields are filled; do something with the valid schedule
            } else {
                // At least one field is empty
                return false // You can return or handle it as needed
            }
        }
        return true // All schedules are valid
    }
    
    // Function to clear the input fields after adding a course
    func clearAllFields() {
        titleField.text = ""
        codeField.text = ""
        termField.text = ""
        termDropdown?.deselectAllCells()
        instructorField.text = ""
        isInstructorFieldVisible = false
        urlField.text = ""
        isUrlFieldVisible = false
        isAdditionalFieldVisible = false
        scheduleList = [DaySchedule]()
        scheduleTable.reloadData()
        updateAllFieldsVisibility()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onCourseAdded = { [weak self] in
            DispatchQueue.main.async {
                self?.clearAllFields()
            }
        }
        
        viewModel.onTermsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.termOptions = self!.viewModel.termList.map { $0.caption }
                self?.termDropdown?.options = self!.termOptions
                self?.termDropdown?.tableView.reloadData()
                self?.termDropdown?.calculateTableHeight()
                if self!.isEditMode {
                    self?.selectTermDropdownRow()
                }
            }
        }
        
        viewModel.onCourseUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.clearAllFields()
                self?.navigationController?.popViewController(animated: true)
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
    
    //MARK: - Dismiss Closure
    
    func dismissView() {
        dismiss(animated: true) { [weak self] in
            // Call the closure to notify MainViewController
            self?.onDismiss?(self!.viewModel.newID)
        }
    }
    
    //MARK: - Data Reading
    
    func refreshTerms(){
        viewModel.fetchTerms()
    }
    
    func updateCourse(){
        viewModel.updateCourse(course: courseObj!)
    }
    
    //MARK: - Editing Mode Config
    
    func setEditingMode(){
        if isEditMode{
            pageTitle.text = "Edit Course"
            setFieldsForCourse()
            updateAllFieldsVisibility()
            initialButtonConfig()
        }
    }
    
    func setFieldsForCourse(){
        titleField.text = courseObj?.title
        codeField.text = courseObj?.code
        termField.text = courseObj?.term
        
        if let professor = courseObj?.prof, !professor.isEmpty {
            isInstructorFieldVisible = true
            instructorField.text = "\(professor)"
        }
        
        scheduleList = courseObj?.schedule
        
        if let url = courseObj?.courseURL, !url.isEmpty {
            isUrlFieldVisible = true
            urlField.text = "\(url)"
        }
    }
    
    //MARK: - Overlay Config
    
    func configureOverlayView(){
        // Setup the overlay view
        overlayView.backgroundColor = UIColor.clear // transparent
        // Assuming overlayView is already added as a subview
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true // Initially hidden
        scrollView.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    
    //MARK: - Dropdown Frame Configs
    
    func setTermDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = termField.convert(termField.bounds, to: scrollView)
        
        // Set the dropdown's frame to appear right below the text field
        termDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: termDropdown!.height!) // Adjust height as needed
    }
    
    
    //MARK: - Dropdown Configs
    func configureTermDropdown(){
        termDropdown = DropdownTableView.instanceFromNib(setOptions: termOptions, maxVisibleRows: 4)
        termDropdown!.alpha = 0
        termDropdown!.textField = termField
        scrollView.addSubview(termDropdown!)
        
        termField.delegate = self
    }
    
    //MARK: - Dropdown Animations
    
    func showTermDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            termDropdown!.alpha = 1
            isTermDropdownVisible = true
            overlayView.isHidden = false
            //view.layoutIfNeeded()
        }
    }
    
    func hideTermDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            termDropdown!.alpha = 0
            isTermDropdownVisible = false
            overlayView.isHidden = true
            view.layoutIfNeeded()
        }
    }
    
    //MARK: - Dropdown selections
    
    func selectTermDropdownRow(){
        if let index = termDropdown?.options.firstIndex(of: termField.text ?? "") {
            termDropdown?.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    //MARK: - Field Toggles
    
    @IBAction func urlToggled(_ sender: UIButton) {
        // Toggle the field visibility
        isUrlFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.toggleButtonImage(sender, self.isUrlFieldVisible)
            self.updateUrlFieldVisibility()
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    @IBAction func instructorToggled(_ sender: UIButton) {
        // Toggle the field visibility
        isInstructorFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.toggleButtonImage(sender, self.isInstructorFieldVisible)
            self.updateInstructorFieldVisibility()
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    func additionalToggled() {
        // Toggle the field visibility
        isAdditionalFieldVisible.toggle()
        updateAdditionalFieldVisibility()
    }
    
    //MARK: - Visibility toggles
    
    // Update the height constraint based on whether the field is visible
    func updateAdditionalFieldVisibility() {
        if isAdditionalFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            additionalScheduleFieldHeightConstraint.constant = 40
            scheduleButton.alpha = 0
        } else {
            // Set the height to 0 to hide the form field
            scheduleButton.alpha = 1
            additionalScheduleFieldHeightConstraint.constant = 0
        }
    }
    
    // Update the height constraint based on whether the field is visible
    func updateUrlFieldVisibility() {
        if isUrlFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            urlFieldHeightConstraint.constant = 58
        } else {
            // Set the height to 0 to hide the form field
            urlField.text = ""
            urlFieldHeightConstraint.constant = 0
        }
    }
    
    // Update the height constraint based on whether the field is visible
    func updateInstructorFieldVisibility() {
        if isInstructorFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            instructorFieldHeightConstraint.constant = 58
        } else {
            // Set the height to 0 to hide the form field
            instructorField.text = ""
            instructorFieldHeightConstraint.constant = 0
        }
    }
    
    func updateAllFieldsVisibility(){
        updateInstructorFieldVisibility()
        updateAdditionalFieldVisibility()
        updateUrlFieldVisibility()
    }
    
    func toggleButtonImage(_ button: UIButton, _ state: Bool){
        if state == false {
            let config = UIImage.SymbolConfiguration(scale: .large)
            if let image = UIImage(systemName: "plus.circle", withConfiguration: config) {
                button.setImage(image, for: .normal)
            }
        } else {
            let config = UIImage.SymbolConfiguration(scale: .large)
            if let image = UIImage(systemName: "minus.circle", withConfiguration: config) {
                button.setImage(image, for: .normal)
            }
        }
    }
    
    func initialButtonConfig(){
        toggleButtonImage(instructorButton, isInstructorFieldVisible)
        toggleButtonImage(urlButton, isUrlFieldVisible)
        if scheduleList!.count >= 1 {
            additionalToggled()
            scheduleTable.reloadData()
        }
    }
    
    //MARK: - Schedule handling
    @IBAction func addSchedulePressed(_ sender: Any) {
        scheduleList.append(DaySchedule())
        UIView.animate(withDuration: 0.2, animations: {
            // First animation block
            if self.scheduleList!.count == 1 {
                self.additionalToggled()
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Second animation block after the first completes
            UIView.animate(withDuration: 0.3) {
                self.scheduleTable.reloadData()
                //self.view.layoutIfNeeded()
            }
        })
    }
    
    @IBAction func removeSchedulePressed(_ sender: UIButton){
        if let scheduleView = sender.superview?.superview?.superview?.superview?.superview as? CourseScheduleView, let index = scheduleList!.firstIndex(where: { $0 == scheduleView.scheduleObj }) {
            scheduleList.remove(at: index)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            // First animation block
            self.scheduleTable.reloadData()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Second animation block after the first completes
            UIView.animate(withDuration: 0.2) {
                if self.scheduleList!.count == 0 {
                    self.additionalToggled()
                }
                self.view.layoutIfNeeded()
            }
        })
    }
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleList!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schedule", for: indexPath)
        if let viewWithTag = cell.contentView.viewWithTag(80) {
            viewWithTag.removeFromSuperview()
        }
        
        let scheduleView = CourseScheduleView.instanceFromNib(setSchedule: scheduleList![indexPath.row], parentScrollView: scrollView, parentOverlayView: overlayView, parentView: self, parentTapGesture: tapGesture!)
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scheduleView.heightAnchor.constraint(equalToConstant: 227).isActive = true
        scheduleView.widthAnchor.constraint(equalToConstant: scheduleTable.frame.width).isActive = true
        scheduleView.tag = 80
        
        scheduleView.removeButton.addTarget(self, action: #selector(removeSchedulePressed(_:)), for: .touchUpInside)
        
        cell.contentView.addSubview(scheduleView)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 227.0
    }
    
    
    //MARK: - Text Field Delegate
    // UITextFieldDelegate method to detect when the text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleScrollIgnore()
        
        if textField == termField{
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isTermDropdownVisible {
                hideTermDropdown()
            } else {
                setTermDropdownFrame()
                showTermDropdown()
            }
        } else {
            overlayView.isHidden = false
        }
    }
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !ignoreHideOnScroll {
            view.endEditing(true)
        }
        
        // This function is called every time the scroll view is scrolled
        if isTermDropdownVisible{
            hideTermDropdown()
        }
        for row in 0..<scheduleTable.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            
            if let cell = scheduleTable.cellForRow(at: indexPath) {
                let scheduleView = cell.viewWithTag(80) as? CourseScheduleView
                scheduleView?.hideWeekdayDropdown()
            }
        }
        
        if !overlayView.isHidden {
            overlayView.isHidden = true
        }
    }
    
    func toggleScrollIgnore(){
        ignoreHideOnScroll = true
        DispatchQueue.main.asyncAfter(deadline: .now() + ignoreTime) {
            self.ignoreHideOnScroll = false
        }
    }
    
    //MARK: - Tap Dismiss
    
    func hideElementWhenTappedAround() {
        // Add a single tap gesture recognizer to hide both the dropdown and the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false // Let other touches work normally
        self.view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
    
    
    // Handle tap outside to hide both dropdown and keyboard
    @objc func handleTapOutside(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.view)
        
        // Check if the tap was outside the dropdown
        if isTermDropdownVisible {//}&& !termDropdown!.frame.contains(tapLocation){
            hideTermDropdown()
        }
        
        if !overlayView.isHidden {
            overlayView.isHidden = true
        }
        
        // Hide the keyboard
        view.endEditing(true)
    }
    
    
    
}
