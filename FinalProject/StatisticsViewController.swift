//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Jared Faucher on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var bornLabel: UILabel!
    @IBOutlet weak var aliveLabel: UILabel!
    @IBOutlet weak var diedLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!

    var previousGridSize: GridSize = StandardEngine.sharedInstance.grid.size
    
    @IBAction func buttonPressed(sender: UIButton) {
        StandardEngine.sharedInstance.resetStats()
        setCountLabels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        setupListener()
        setCountLabels()
    }
    
    func setCountLabels() {
        setLabel(emptyLabel, StandardEngine.sharedInstance.gridStats.numEmpty)
        setLabel(bornLabel, StandardEngine.sharedInstance.gridStats.numBorn)
        setLabel(aliveLabel, StandardEngine.sharedInstance.gridStats.numAlive)
        setLabel(diedLabel, StandardEngine.sharedInstance.gridStats.numDied)
    }
    
    func setLabel(_ label: UILabel, _ count: Int) {
        switch label {
        case emptyLabel: label.text = "Empty: \(count)"
        case bornLabel: label.text = "Born : \(count)"
        case aliveLabel: label.text = "Alive: \(count)"
        case diedLabel: label.text = "Died: \(count)"
        default: return
        }
        label.setNeedsDisplay()
    }

}

extension StatisticsViewController {
    
    func setupListener() {
        
        GridNotification.setupListener(name: Const.gridUpdated,
                                       observer: self,
                                       selector: #selector(notified(notification:)))
        
    }
    
    func notified(notification: Notification) {
        
        setCountLabels()
        
    }
}
