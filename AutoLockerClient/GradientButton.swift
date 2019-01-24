//
//  GradientButton.swift
//  AutoLockerClient
//
//  Created by Oleksandr Hordiienko on 1/24/19.
//  Copyright © 2019 sss. All rights reserved.
//

import UIKit

@IBDesignable class GradientButton: UIButton {
    
    @IBInspectable var rounded: Bool = false
    
    
    @IBInspectable var firstColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    
    @IBInspectable var secondColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    
    private func updateView() -> Void {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
    }
    
    
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = rounded
        layer.cornerRadius = rounded ? bounds.size.height / 2.0 : 0
    }
    
}
