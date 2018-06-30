//
//  Engine.swift
//  FinalProject
//
//  Created by Jared Faucher on 7/30/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import Foundation


protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    init(_ rows: Int, _ cols: Int)
    func step() -> GridProtocol
}

protocol EngineDelegate {
    func engineDidUpdate(engine: EngineProtocol)
}


class StandardEngine : NSObject, EngineProtocol {
    
    var delegate: EngineDelegate?
    var title:  String?
    var tableRow: Int?
    
    var grid: GridProtocol {
        didSet {
            delegate?.engineDidUpdate(engine: self)
            let notificationName = Notification.Name(Const.gridUpdated)
            NotificationCenter.default.post(name: notificationName,
                                            object: self.grid,
                                            userInfo: nil)
        }
    }
    
    var refreshRate: Double = 2.5
    
    var refreshTimer: Timer?
    
    var rows: Int {
        didSet {
            resetMetaData()
        }
    }
    
    var cols: Int {
        didSet {
            resetMetaData()
        }
    }
    
    var gridStats: GridStats
    
    private static var shared: StandardEngine?
    
    static var sharedInstance : StandardEngine {
        if let ret = shared {
            return ret
        }
        shared = StandardEngine(10, 10)
        shared?.setupListener()
        return shared!
    }
    
    required init(_ rows: Int, _ cols: Int) {
        self.rows = rows
        self.cols = cols
        self.grid = Grid(rows, cols)
        
        self.gridStats = grid.stats
    }
    
    private func resetMetaData() {
        title = nil
        tableRow = nil
        resetStats()
    }
    
    func setupEngine(_ rows: Int, _ cols: Int) {
        self.rows = rows
        self.cols = cols
        self.grid = Grid(rows, cols)
    }
    
    func step() -> GridProtocol {
        grid = grid.next()
        let stats = grid.stats
        gridStats.numEmpty += stats.numEmpty
        gridStats.numBorn += stats.numBorn
        gridStats.numDied += stats.numDied
        gridStats.numAlive += stats.numAlive
        return grid
    }
    
    func resetStats() {
        let stats = grid.stats
        gridStats.numEmpty = stats.numEmpty
        gridStats.numBorn = stats.numBorn
        gridStats.numDied = stats.numDied
        gridStats.numAlive = stats.numAlive
    }
    
    
    
}

extension StandardEngine {
    func setupListener() {
        GridNotification.setupListener(name: Const.configSaved, observer: self, selector: #selector(notifiedSaved(notification:)))
    }
    
    func notifiedSaved(notification: Notification) {
        
        guard let grid = notification.object as? Grid else {
            print("Notification missing expected values: " +
                "<\(notification)>")
            return
        }
        self.rows = grid.size.rows
        self.cols = grid.size.cols
        self.grid = grid
        if let userInfo = notification.userInfo {
            if let title = userInfo["title"] as? String {
                if let tableRow = userInfo["tableRow"] as? Int {
                    self.title = title
                    self.tableRow = tableRow
                }
            }
        }
    }
}


