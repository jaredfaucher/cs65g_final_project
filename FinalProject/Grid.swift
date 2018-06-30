//
//  Grid.swift
//

import Foundation

public typealias GridPosition = (row: Int, col: Int)
public typealias GridSize = (rows: Int, cols: Int)

fileprivate func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

public enum CellState {
    case alive, empty, born, died
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
    
    public mutating func toggle() -> Void {
        switch self {
        case .empty, .died: self = .alive
        case .alive, .born: self = .empty
        }
    }
}

public protocol GridProtocol {
    init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState)
    var description: String { get }
    var size: GridSize { get }
    var stats: GridStats { get set }
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self 
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition($0) }
}


let offsets: [GridPosition] = [
    (row: -1, col:  -1), (row: -1, col:  0), (row: -1, col:  1),
    (row:  0, col:  -1),                     (row:  0, col:  1),
    (row:  1, col:  -1), (row:  1, col:  0), (row:  1, col:  1)
]

extension GridProtocol {
    
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Self {
        var nextGrid = Self(size.rows, size.cols) { _, _ in .empty }
        lazyPositions(self.size).forEach {
            let cellState = self.nextState(of: $0)
            switch cellState {
            case .alive: nextGrid.stats.numAlive += 1
            case .born: nextGrid.stats.numBorn += 1
            case .died: nextGrid.stats.numDied += 1
            case .empty: nextGrid.stats.numEmpty += 1
            }
            nextGrid[$0.row, $0.col] = cellState
        }
        return nextGrid
    }
}

public struct Grid: GridProtocol {
    public var stats: GridStats
    private var _cells: [[CellState]]
    public let size: GridSize

    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState = { _, _ in .empty }) {
        _cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: cols)), count: rows))
        size = GridSize(rows, cols)
        stats = GridStats(numEmpty: 0,numAlive: 0,numBorn: 0,numDied: 0)
        lazyPositions(self.size).forEach {
            let cellState = cellInitializer($0)
            switch cellState {
            case .alive: stats.numAlive += 1
            case .born: stats.numBorn += 1
            case .died: stats.numDied += 1
            case .empty: stats.numEmpty += 1
            }
            self[$0.row, $0.col] = cellState
        }
    }
}

extension Grid: Sequence {
    fileprivate var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive   }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: GridProtocol
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> GridProtocol? {
            if history.hasCycle { return nil }
            let newGrid:Grid = grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case (0, 1), (1, 2), (2, 0), (2, 1), (2, 2): return .alive
        default: return .empty
        }
    }
    
}

public extension GridProtocol {
 
    public mutating func reset() -> Void {
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = .empty }
    }
    
    public mutating func setPositions(_ positions: [GridPosition], _ state: CellState) {
        positions.forEach {
            self[$0.row, $0.col] = state
        }
    }
    
}

public struct GridStats {
    var numEmpty: Int = 0
    var numAlive: Int = 0
    var numBorn: Int = 0
    var numDied: Int = 0
}

struct GridData {
    var title: String
    var contents: [[Int]]
    
    init(_ title: String, _ contents: [[Int]]) {
        self.title = title
        self.contents = contents
    }
    
    init(_ title: String = "default", _ grid: GridProtocol) {
        self.title = title
        self.contents = [[Int]]()
        lazyPositions(grid.size).filter { return  grid[$0.row, $0.col].isAlive   }
            .forEach { position in
                self.contents.append([position.row, position.col])
        }
    }
    
    func toPositions() -> [GridPosition] {
        var positions = [GridPosition]()
        contents.forEach {
            if $0.count == 2 {
                let newPosition = GridPosition(row: $0[0], col: $0[1])
                positions.append(newPosition)
            }
        }
        return positions
    }
    
    var maxX : Int {
        var ret = 0
        contents.forEach {
            if $0[0] > ret {
                ret = $0[0]
            }
        }
        return ret
    }
    
    var maxY : Int {
        var ret = 0
        contents.forEach {
            if $0[1] > ret {
                ret = $0[1]
            }
        }
        return ret
    }
    
    var jsonString: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                      options: .prettyPrinted)
            let jsonString = String(data: jsonData,
                                    encoding: .utf8)
            if jsonString == nil {
                print("Unable to convert to String: <\(jsonObject)>")
            }
            print("jsonString <\(jsonString ?? "*nil*")>")
            return jsonString
        } catch {
            print("Unable to convert <\(jsonObject)>")
        }
        return nil
    }
    
    var jsonObject: Any {
        let tmpJsonDict: Dictionary<String, Any> =
            ["title": title,
             "contents" : contents]
        
        return tmpJsonDict
    }
}

struct Const {
    static let gridUpdated = "notification.name.gridUpdated"
    static let configSaved = "notification.name.configSaved"
    static let simulationSaved = "notification.name.simulationSaved"
    static let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"
}
