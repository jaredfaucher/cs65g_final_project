//
//  ConfigurationController.swift
//  FinalProject
//
//  Created by Jared Faucher on 7/23/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class ConfigurationController: UIViewController, UITextFieldDelegate {
    
    var configuration: GridData?
    var tableRow: Int?
    @IBOutlet weak var configurationTextField: UITextField!
    @IBOutlet weak var gridView: GridView!
    
    
    @IBAction func saveTapped(sender: UIBarButtonItem) {
        
        let notificationName = Notification.Name(Const.configSaved)
        NotificationCenter.default.post(name: notificationName,
                                        object: self.gridView.grid,
                                        userInfo: ["tableRow": tableRow!,
                                                   "title": configurationTextField.text ?? "default"])
        navigationController?.popToRootViewController(animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        configurationTextField!.text = configuration?.title
        configurationTextField.delegate = self
        if let configuration = configuration {
            if configuration.contents.count > 0 {
            let maxCoord = Int(1.3 * max(Double(configuration.maxX), 1.3 * Double(configuration.maxY)))
            gridView.grid = Grid(maxCoord, maxCoord)
            gridView.grid.setPositions(configuration.toPositions(), .alive)
            } else {
                gridView.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
