//
//  TimetableViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-11.
//

import UIKit
import SpreadsheetView


class TimetableViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    @IBOutlet weak var spreadsheetContainer: UIView!
    
    let spreadsheetView = SpreadsheetView()
    
    // Define constants for start and end times
    //let hoursPerDay = 18  // From 6 AM (index 0) to 11 PM (index 17)
    //let daysOfWeek = 7    // Monday to Sunday
    
    //let dates = ["7/10/2017", "7/11/2017", "7/12/2017", "7/13/2017", "7/14/2017", "7/15/2017", "7/16/2017"]
    var mergedRanges: [CellRange] = [] // Store merged ranges as a property
    //let days = ["MONDAY", "TUESDAY", "WEDNSDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
    private lazy var days: [String] = {
        let startOfWeek = Calendar.current.startOfWeek() ?? Date() // Calculate the start of the current week
        return generateDateHeaders(startDate: startOfWeek, daysCount: 7) // Generate headers for 7 days
    }()
    let dayColors = [UIColor(red: 0.918, green: 0.224, blue: 0.153, alpha: 1),
                     UIColor(red: 0.106, green: 0.541, blue: 0.827, alpha: 1),
                     UIColor(red: 0.200, green: 0.620, blue: 0.565, alpha: 1),
                     UIColor(red: 0.953, green: 0.498, blue: 0.098, alpha: 1),
                     UIColor(red: 0.400, green: 0.584, blue: 0.141, alpha: 1),
                     UIColor(red: 0.835, green: 0.655, blue: 0.051, alpha: 1),
                     UIColor(red: 0.153, green: 0.569, blue: 0.835, alpha: 1)]
    let hours = ["6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 AM", "1:00 PM", "2:00 PM",
                 "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    let evenRowColor: UIColor = .white
    let oddRowColor = UIColor(red: 0.914, green: 0.914, blue: 0.906, alpha: 1)
    var data = [
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
    ]
    
    var columnWidths: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    
    private let viewModel = CourseListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spreadsheetView.translatesAutoresizingMaskIntoConstraints = false
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        spreadsheetView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        
        spreadsheetView.intercellSpacing = CGSize(width: 4, height: 1)
        spreadsheetView.gridStyle = .none
        
        //spreadsheetView.register(DateCell.self, forCellWithReuseIdentifier: String(describing: DateCell.self))
        spreadsheetView.register(TimeTitleCell.self, forCellWithReuseIdentifier: String(describing: TimeTitleCell.self))
        spreadsheetView.register(TimeCell.self, forCellWithReuseIdentifier: String(describing: TimeCell.self))
        spreadsheetView.register(DayTitleCell.self, forCellWithReuseIdentifier: String(describing: DayTitleCell.self))
        spreadsheetView.register(ScheduleCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCell.self))
        
        spreadsheetContainer.addSubview(spreadsheetView)
        
        NSLayoutConstraint.activate([
            spreadsheetView.topAnchor.constraint(equalTo: spreadsheetContainer.topAnchor),
            spreadsheetView.leadingAnchor.constraint(equalTo: spreadsheetContainer.leadingAnchor),
            spreadsheetView.bottomAnchor.constraint(equalTo: spreadsheetContainer.bottomAnchor),
            spreadsheetView.trailingAnchor.constraint(equalTo: spreadsheetContainer.trailingAnchor)
        ])
        
        // Bind ViewModel to ViewController
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spreadsheetView.flashScrollIndicators()
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
                if self!.viewModel.courseCollection.count > 0 {
                    self?.data = self!.generateScheduleArray(from: self!.viewModel.courseCollection)
                    self?.mergedRanges = self!.mergedCells(in: self!.spreadsheetView)
                    self?.calculateColumnWidths()
                    self?.spreadsheetView.reloadData();
                }
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
    
    
    // MARK: - DataSource
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + days.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + hours.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 70
        } else {
            return max(120, columnWidths[column - 1])
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 32
        } else {
            return 40
        }
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        // Handle day titles (frozen row at the top)
        if case (1...(days.count + 1), 0) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DayTitleCell.self), for: indexPath) as! DayTitleCell
            cell.label.text = days[indexPath.column - 1]
            cell.label.textColor = dayColors[indexPath.column - 1]
            cell.backgroundColor = .clear
            return cell
        }

        // Handle time titles (frozen column on the left)
        else if case (0, 1...(hours.count + 1)) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as! TimeCell
            cell.label.text = hours[indexPath.row - 1]
            cell.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
            return cell
        }

        // Handle schedule cells
        else if case (1...(days.count + 1), 1...(hours.count + 2)) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as! ScheduleCell
            let text = data[indexPath.column - 1][indexPath.row - 1]

            // Reset the cell
            cell.label.text = nil
            cell.backgroundColor = .clear

            if !text.isEmpty {
                cell.label.text = text

                // Differentiate between tasks and courses
                if text.contains("Task:") {
                    // Highlight tasks differently
                    cell.backgroundColor = UIColor.orange.withAlphaComponent(0.3) // Task color
                    cell.label.textColor = .orange
                } else {
                    // Default for courses
                    let color = dayColors[indexPath.column - 1]
                    cell.backgroundColor = color.withAlphaComponent(0.3)
                    cell.label.textColor = color
                }
            } else {
                // Empty cells
                cell.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
            }

            return cell
        }

        // Default return
        return nil
    }
    
//    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
//        // Handle the case for day titles (frozen row)
//        if case (1...(days.count + 1), 0) = (indexPath.column, indexPath.row) {
//            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DayTitleCell.self), for: indexPath) as! DayTitleCell
//            cell.label.text = days[indexPath.column - 1]
//            cell.label.textColor = dayColors[indexPath.column - 1]
//            cell.backgroundColor = .clear // Set a clear background for header cells
//            return cell
//        }
//        
//        // Handle the case for the time title (frozen cell)
//        else if case (0, 0) = (indexPath.column, indexPath.row) {
//            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as! TimeTitleCell
//            cell.label.text = "TIME"
//            cell.backgroundColor = .clear // Set a clear background for header cells
//            return cell
//        }
//        
//        // Handle the case for time cells
//        else if case (0, 1...(hours.count + 1)) = (indexPath.column, indexPath.row) {
//            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as! TimeCell
//            cell.label.text = hours[indexPath.row - 1]
//            cell.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
//            return cell
//        }
//        
//        // Handle schedule cells
//        else if case (1...(days.count + 1), 1...(hours.count + 2)) = (indexPath.column, indexPath.row) {
//            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as! ScheduleCell
//            let text = data[indexPath.column - 1][indexPath.row - 1]
//            
//            // Reset the cell's label and background color for every call
//            cell.label.text = nil
//            cell.backgroundColor = .clear // Clear background initially
//
//            // Check if the current cell is part of a merged cell range
//            if isMergedCellAt(indexPath) {
//                // If this cell is part of a merged range but not the top-left, we do not display text
//                if isTopLeftOfMergedCell(at: indexPath) {
//                    // Display text for the top-left cell of the merged range
//                    cell.label.text = text
//                    let color = dayColors[indexPath.column - 1]
//                    cell.label.textColor = color
//                    cell.backgroundColor = color.withAlphaComponent(0.3) // Set background for filled cells
//                } else {
//                    // This is a merged cell but not the top-left cell
//                    cell.label.text = nil
//                    cell.backgroundColor = .clear // Keep it clear or a default color
//                }
//            } else {
//                // If the cell is empty
//                if text.isEmpty {
//                    cell.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor // Alternating color for empty cells
//                } else {
//                    // If the cell contains text but isn't part of a merge
//                    cell.label.text = text
//                    let color = dayColors[indexPath.column - 1]
//                    cell.label.textColor = color
//                    cell.backgroundColor = color.withAlphaComponent(0.3) // Set background for filled cells
//                }
//            }
//
//            return cell
//        }
//        
//        return nil
//    }

    // Helper function to determine if this cell is the top-left cell of a merged range
    private func isTopLeftOfMergedCell(at indexPath: IndexPath) -> Bool {
        // Check your mergedRanges array or structure to see if the current indexPath is the top-left of a merged cell range
        for range in mergedRanges {
            if range.from.row == indexPath.row && range.from.column == indexPath.column {
                return true
            }
        }
        return false
    }

    // Helper function to determine if a cell is part of a merged range
    private func isMergedCellAt(_ indexPath: IndexPath) -> Bool {
        for range in mergedRanges {
            if range.contains(indexPath) {
                return true
            }
        }
        return false
    }
    // Updated mergedCells function
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var mergedRanges: [CellRange] = []

        // Loop through each column (days of the week)
        for column in 0..<data.count { // Start from 0 since there are no frozen columns
            var startRow: Int? = nil

            // Loop through each row
            for row in 0..<data[column].count { // Start from 0 since there are no frozen rows
                let cellText = data[column][row]

                // Check if we are starting a new merge
                if !cellText.isEmpty && startRow == nil {
                    startRow = row // Begin merging at this row
                }

                // Check if the current cell is empty or if it's the last row
                if cellText.isEmpty || row == data[column].count - 1 {
                    // If the current cell is empty or it's the last filled cell, create a merged range
                    if let start = startRow, start < row {
                        // Create a merged range with +1 row and +1 column
                        let range = CellRange(from: (start + 1, column + 1), to: (row, column + 1))
                        mergedRanges.append(range)
                    }
                    startRow = nil  // Reset startRow
                } else if row > 0 && cellText != data[column][row - 1] {
                    // If the cell text changes, close off the previous range
                    if let start = startRow, start < row {
                        let range = CellRange(from: (start + 1, column + 1), to: (row, column + 1))
                        mergedRanges.append(range)
                    }
                    startRow = row // Start a new merge from the current row
                }
            }
        }

        return mergedRanges
    }
    
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }
    
    //MARK: - Data formatting
    
    // Function to convert time into an index (6 AM -> 0, 7 AM -> 1, ..., 11 PM -> 17)
    func timeToIndex(_ time: Time) -> Int {
        return (time.hour - 6) // e.g., 6 AM -> 0, 7 AM -> 1, ..., 11 PM -> 17
    }
    
    // Initialize the 2D array with empty strings
    func generateScheduleArray(from dailyCourses: [DailyCourses]) -> [[String]] {
        // Create an empty 7x18 2D array (7 days, 18 hours)
        var scheduleArray = Array(repeating: Array(repeating: "", count: 18), count: 7)
        
        // Helper to map DayOfWeek to a column index (0 = Monday, 6 = Sunday)
        func dayToColumnIndex(_ day: DayOfWeek) -> Int {
            switch day {
            case .monday: return 0
            case .tuesday: return 1
            case .wednesday: return 2
            case .thursday: return 3
            case .friday: return 4
            case .saturday: return 5
            case .sunday: return 6
            }
        }
        
        // Helper to map time to a row index (6 AM = row 0, 7 AM = row 1, ..., 11 PM = row 17)
        func timeToRowIndex(_ time: Time) -> Int {
            return time.hour - 6  // 6 AM starts at row 0
        }
        
        // Populate the 2D array with course data
        for dailyCourse in dailyCourses {
            let columnIndex = dayToColumnIndex(dailyCourse.weekday)
            
            for course in dailyCourse.courses {
                for schedule in course.schedule {
                    guard let start = schedule.startTime, let end = schedule.endTime, let classroom = schedule.classroom else { continue }
                    
                    let startRow = timeToRowIndex(start)
                    let endRow = timeToRowIndex(end) - 1
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm a" // dd/MMM
                    // Create the formatted text
                    let courseText = "\(course.code)\n\(course.title)\n\(formatter.string(from: start.toTodaysDate()!)) - \(formatter.string(from: end.toTodaysDate()!))\n\(classroom)"
                    
                    // Fill the array for each hour the course spans
                    for row in startRow...endRow {
                        scheduleArray[columnIndex][row] = courseText
                    }
                }
            }
        }
        
        return scheduleArray
    }
    
    //MARK: - Layout helpers
    
    func calculateColumnWidths() {
        let font = UIFont.systemFont(ofSize: 12)
        
        // Initialize column widths to zero
        columnWidths = Array(repeating: CGFloat(0), count: data[0].count)
        
        // Calculate maximum width for each column
        for column in 0..<data.count {
            for row in data[column] {
                let text = row
                let lines = text.components(separatedBy: "\n").prefix(4) // Limit to 4 lines
                
            // Measure the width of each line
                 var maxWidth: CGFloat = 0
                 for line in lines {
                     let width = line.size(withAttributes: [.font: font]).width
                     maxWidth = max(maxWidth, width)
                 }
        
                columnWidths[column] = max(columnWidths[column], maxWidth + 20) // Add padding
            }
        }
        
        print(columnWidths)
    }
    
    
    //generating the date headers
    private func generateDateHeaders(startDate: Date, daysCount: Int) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd" // Format: Mon, Nov 27

        var headers: [String] = []
        var currentDate = startDate

        for _ in 0..<daysCount {
            headers.append(formatter.string(from: currentDate))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return headers
    }
    
}
