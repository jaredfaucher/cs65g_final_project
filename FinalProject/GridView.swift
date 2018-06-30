//
//  GridView.swift
//  Assignment3
//
//  Created by Jared Faucher on 7/6/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

@IBDesignable
class GridView: UIView {
    
    @IBInspectable var livingColor : UIColor = UIColor.red
    @IBInspectable var emptyColor : UIColor = UIColor.white
    @IBInspectable var bornColor : UIColor = UIColor.purple
    @IBInspectable var diedColor : UIColor = UIColor.gray
    @IBInspectable var gridColor : UIColor = UIColor.black
    @IBInspectable var gridWidth : CGFloat = 1.0
    
    
    var grid: GridProtocol = StandardEngine.sharedInstance.grid
    
    var rowHeight : CGFloat {
        return frame.size.height / CGFloat(grid.size.rows)
    }
    
    var colWidth : CGFloat {
        return frame.size.width / CGFloat(grid.size.cols)
    }
    
    var cellRadius : CGFloat {
        return min(rowHeight, colWidth) / 2 - gridWidth
    }
    
    override func draw(_ rect: CGRect) {
        let startTime = Date()

        let gridPath = UIBezierPath()
        
        gridPath.lineWidth = gridWidth
        
        for i in 0 ... grid.size.rows {
            drawHorizontalLine(rect, gridPath, offset: rowHeight * CGFloat(i))
        }

        for i in 0 ... grid.size.cols {
            drawVerticalLine(rect, gridPath, offset: colWidth * CGFloat(i))
        }
        
        gridColor.setStroke()
        gridPath.stroke()
        
        lazyPositions(grid.size).forEach {
            let cellState = self.grid[$0.row, $0.col]
            var cellColor: UIColor {
                switch cellState {
                case .alive : return self.livingColor
                case .born : return self.bornColor
                case .died : return self.diedColor
                case .empty : return self.emptyColor
                }
            }
            let midPoint = CGPoint(x: CGFloat($0.col) * self.colWidth + (self.colWidth/2),
                                   y: CGFloat($0.row) * self.rowHeight + (self.rowHeight/2))
            self.drawCell(midPoint, self.cellRadius, cellColor)
        }
        let timeDiff = Date().timeIntervalSince(startTime)
        
        print("Draw Time Diff: \(timeDiff)")
    }
    
    func drawHorizontalLine(_ rect: CGRect, _ path: UIBezierPath, offset: CGFloat) {
        path.move(to: CGPoint(x: rect.origin.x, y: offset))
        path.addLine(to: CGPoint(x: rect.width, y: offset))
    }
    
    func drawVerticalLine(_ rect: CGRect, _ path: UIBezierPath, offset: CGFloat) {
        path.move(to: CGPoint(x: offset, y: rect.origin.y))
        path.addLine(to: CGPoint(x: offset, y: rect.height))
    }
    
    func drawCell(_ midPoint: CGPoint, _ radius: CGFloat, _ color: UIColor) {
        let circlePath = UIBezierPath(arcCenter: midPoint,
                                      radius: radius,
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        color.setStroke()
        circlePath.stroke()
        color.setFill()
        circlePath.fill()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    var lastTouchedPosition: GridPosition?
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        
        //************* IMPORTANT ****************
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        //****************************************
        grid[pos.row, pos.col].toggle()
        StandardEngine.sharedInstance.grid = grid
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> GridPosition {
        let touchPoint = touch.location(in: self)
        let row : Int = Int(touchPoint.y / rowHeight)
        let col : Int = Int(touchPoint.x / colWidth)
        return GridPosition(row: Int(row), col: Int(col))
    }
    
}
