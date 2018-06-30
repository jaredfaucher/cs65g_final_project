//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Jared Faucher on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, EngineDelegate {
    
    func engineDidUpdate(engine: EngineProtocol) {
        gridView.grid = engine.grid
        gridView.setNeedsDisplay()
    }

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var stepButton: UIButton!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var configLabel: UILabel!
    var tableRow: Int?
    
    @IBAction func stepButtonPressed(sender: UIButton) {
    
        StandardEngine.sharedInstance.grid = gridView.grid
        gridView.grid = StandardEngine.sharedInstance.step()
        gridView.setNeedsDisplay()
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        if let tableRow = tableRow {
            let notificationName = Notification.Name(Const.simulationSaved)
            NotificationCenter.default.post(name: notificationName,
                                            object: self.gridView.grid,
                                            userInfo: ["tableRow": tableRow,
                                                       "title": configLabel.text ?? "default"])
        }
        saveConfiguration(StandardEngine.sharedInstance.grid)
    }
    
    @IBAction func resetButtonPressed(sender: UIButton) {
        StandardEngine.sharedInstance.grid.reset()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stepButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        gridView.grid = StandardEngine.sharedInstance.grid
        tableRow = StandardEngine.sharedInstance.tableRow
        reloadConfigTitle()
        gridView.setNeedsDisplay()
        StandardEngine.sharedInstance.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadConfigTitle()
        gridView.setNeedsDisplay()
    }
}

extension SimulationViewController {
    func saveConfiguration(_ grid: GridProtocol) {
        if let title = configLabel.text {
            let gridData = GridData(title, grid)
            if let jsonString =  gridData.jsonString {
                UDWrapper.setLastSavedConfig(value: jsonString)
            } else {
                print("Unable to save lastSaved")
            }
        }
    }
    
    func reloadConfigTitle() {
        if let title = StandardEngine.sharedInstance.title {
            configLabel.text = title
        } else {
            configLabel.text = ""
        }
    }
}
