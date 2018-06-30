//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Jared Faucher on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var rowSlider: UISlider!
    @IBOutlet weak var colLabel: UILabel!
    @IBOutlet weak var colSlider: UISlider!
    @IBOutlet weak var refreshSlider: UISlider!
    @IBOutlet weak var refreshSliderLabel: UILabel!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    var gridData: [GridData]?
    
    @IBAction func rowSliderChanged(sender: UISlider) {
        let currRows = Int(ceil(sender.value))
        StandardEngine.sharedInstance.setupEngine(currRows, StandardEngine.sharedInstance.cols)
        setRowLabel(from: currRows)
    }
    
    @IBAction func colSliderChanged(sender: UISlider) {
        let currCols = Int(ceil(sender.value))
        StandardEngine.sharedInstance.setupEngine(StandardEngine.sharedInstance.rows, currCols)
        setColLabel(from: currCols)
    }
    
    @IBAction func refreshSliderChanged(sender: UISlider) {
        StandardEngine.sharedInstance.refreshRate = Double(sender.value)
        setRefreshSliderLabel(from: sender.value)
        StandardEngine.sharedInstance.refreshTimer?.invalidate()
        refreshSwitch.setOn(false, animated: true)
        refreshSwitch.setNeedsDisplay()
    }
    
    @IBAction func switchToggled(sender: UISwitch) {
        if sender.isOn {
            let timeInterval = 1 / StandardEngine.sharedInstance.refreshRate
            StandardEngine.sharedInstance.refreshTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { (t) in
                StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
                StandardEngine.sharedInstance.delegate?.engineDidUpdate(engine: StandardEngine.sharedInstance)
            }
        } else {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
        }
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) {
        let data = GridData("", [[Int]]())
        if gridData == nil {
            gridData = [GridData]()
        }
        gridData?.append(data)
        tableView.reloadData()
        let indexPath = IndexPath(item: (gridData?.count)! - 1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "openConfiguration", sender: cell)
    }
    
    // MARK: - Table View

    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = gridData else {
            return 1
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configCell")!
        cell.textLabel?.text = "*No Configurations Present*"
        
        if let data = gridData {
            if data.count != 0 {
                cell.textLabel?.text = data[indexPath.row].title
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newData = gridData!
            newData.remove(at: indexPath.row)
            gridData = newData
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        if let destination = segue.destination as? ConfigurationController {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let data = gridData {
                    let configData = data[indexPath.row]
                    destination.configuration = configData
                    destination.tableRow = indexPath.row
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEngineValues()
        refreshSwitch.setOn(false, animated: false)
        
        // Here is where I call my wrapper function for retrieving data and parsing
        getData()
        
        setupListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let row = StandardEngine.sharedInstance.tableRow {
            tableView.selectRow(at:IndexPath(row: row, section: 0) ,
                                animated: false, scrollPosition: .middle)
        }
        loadEngineValues()
    }

}



// UI Label functions
extension InstrumentationViewController {
    
    func setRowLabel(from value: Int) {
        rowLabel.text = "Rows: \(value)"
        rowLabel.setNeedsDisplay()
    }
    
    func setColLabel(from value: Int) {
        colLabel.text = "Cols: \(value)"
        colLabel.setNeedsDisplay()
    }
    
    func setRefreshSliderLabel(from value: Float) {
        let doubleValue = round(Double(value) * 10) / 10
        refreshSliderLabel.text = "Refresh Frequency (frames/sec): \(doubleValue)"
        refreshSliderLabel.setNeedsDisplay()
    }
    
    func loadEngineValues() {
        refreshSlider.value = Float(StandardEngine.sharedInstance.refreshRate)
        setRefreshSliderLabel(from: Float(StandardEngine.sharedInstance.refreshRate))
        rowSlider.value = Float(StandardEngine.sharedInstance.rows)
        colSlider.value = Float(StandardEngine.sharedInstance.cols)
        setRowLabel(from: StandardEngine.sharedInstance.rows)
        setColLabel(from: StandardEngine.sharedInstance.cols)
    }
    
}

// Functions related to retreiving and parsing JSON
extension InstrumentationViewController {
    func getData() -> Void {
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string: Const.finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }

            if self.gridData == nil {
                self.gridData = [GridData]()
            }
            
            let jsonArray = json as! NSArray
            jsonArray.forEach {
                let dictionary = $0 as! NSDictionary
                let title = dictionary["title"] as! String
                let contents = dictionary["contents"] as! [[Int]]
                let data = GridData(title, contents)
                self.gridData?.append(data)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// functions related to setting up listeners
extension InstrumentationViewController {
    func setupListener() {

        GridNotification.setupListener(name: Const.configSaved,
                                       observer: self,
                                       selector: #selector(notifiedSaved(notification:)))
        GridNotification.setupListener(name: Const.simulationSaved,
                                       observer: self,
                                       selector: #selector(notifiedSimulationSaved(notification:)))
        
    }
    
    func notifiedSaved(notification: Notification) {
        
        guard let grid = notification.object as? Grid else {
            print("Notification missing expected values: " +
                "<\(notification)>")
            return
        }
        if let userInfo = notification.userInfo {
            if let title = userInfo["title"] as? String {
                if let tableRow = userInfo["tableRow"] as? Int {
                    gridData?[tableRow] = GridData(title, grid)
                    self.tableView.reloadData()
                }
            }
        }
    }
    func notifiedSimulationSaved(notification: Notification) {
        
        guard let grid = notification.object as? Grid else {
            print("Notification missing expected values: " +
                "<\(notification)>")
            return
        }
        if let userInfo = notification.userInfo {
            if let title = userInfo["title"] as? String {
                if let tableRow = userInfo["tableRow"] as? Int {
                    gridData?[tableRow] = GridData(title, grid)
                    self.tableView.reloadData()
                }
            }
        }
    }
}
