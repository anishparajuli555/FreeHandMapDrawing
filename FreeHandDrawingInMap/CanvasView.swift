//
//  CanvasView.swift
//  Relly
//
//  Created by Anish on 7/7/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit
import Foundation

protocol NotifyTouchEvents:class {
    func touchBegan(touch:UITouch)
    func touchEnded(touch:UITouch)
    func touchMoved(touch:UITouch)
}

class CanvasView: UIImageView {
    
    weak var delegate:NotifyTouchEvents?
    var lastPoint = CGPoint.zero
    let brushWidth:CGFloat = 3.0
    let opacity :CGFloat = 1.0
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if let touch = touches.first {
            
            self.delegate?.touchBegan(touch: touch)
            lastPoint = touch.location(in: self)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first  {
            
            self.delegate?.touchMoved(touch: touch)
            let currentPoint = touch.location(in: self)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first  {
            
            self.delegate?.touchEnded(touch: touch)
            
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        self.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setBlendMode(.normal)
        context?.strokePath()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
}
