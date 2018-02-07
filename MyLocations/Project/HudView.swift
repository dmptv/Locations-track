//
//  HudView.swift
//  MyLocations
//
//  Created by 123 on 03.12.17.
//  Copyright © 2017 123. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var text = ""
    
    // convenience constructor
    // It creates and returns a new HudView instance
    
    class func hud(inView view: UIView, animated: Bool
        ) -> HudView {
        
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        // view -> This is the navigation controller’s view so the HUD will cover the entire screen
        view.addSubview(hudView)
        
        // While the HUD is showing you don’t want the user to interact with the screen anymore
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    
    // The draw() method is invoked whenever UIKit wants your view to redraw itself
    // if you want view to redraw, you should send it the setNeedsDisplay()
    // UIKit will then trigger a draw()
    
    override func draw(_ rect: CGRect) {
        
        // When working with UIKit or Core Graphics you use CGFloat
        // instead of the regular Float or Double
        
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        let boxRect = CGRect(
            
            // The HUD rectangle centered horizontally and vertically on the screen
            x: round((bounds.size.width - boxWidth) / 2),
            
            // uses the round() function to make sure the rectangle doesn’t end up on fractional pixel 
            y: round((bounds.size.height - boxHeight) / 2),
            
            width: boxWidth,
            height: boxHeight)
        
        // take rounded rect
        let roundedRect = UIBezierPath(roundedRect: boxRect,
                                       cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // because UIImage(named) is a so-called failable initializer.
        //it  can fail
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            // it draws the image at that position
            image.draw(at: imagePoint)
            
            // draw text instead of label
            
            let attribs = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                            NSAttributedStringKey.foregroundColor: UIColor.white ]
            
            // When drawing text you first need to know how big the text is,
            // so you can figure out where to position it
            
            let textSize = text.size(withAttributes: attribs)
            let textPoint = CGPoint( x: center.x - round(textSize.width / 2),
                                     y: center.y - round(textSize.height / 2) + boxHeight / 4)
            text.draw(at: textPoint, withAttributes: attribs)
        }
    }
    
    func show(animated: Bool) {
        if animated {
            
            // Setup the initial state of the view before the animation starts
            alpha = 0
            
            // view is initially stretched out
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations:
                {
                    self.alpha = 1
                    self.transform = CGAffineTransform.identity
            },
                           completion: nil)
        }
    }
    
}





















