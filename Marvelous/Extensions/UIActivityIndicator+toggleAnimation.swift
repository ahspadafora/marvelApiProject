//
//  UIActivityIndicatorView+Ext.swift
//  Marvelous
//
//  Created by Amber Spadafora on 12/3/18.
//  Copyright © 2018 Mark Turner. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    
    func toggleAnimation() {
        DispatchQueue.main.async {
            self.isAnimating ? self.stopAnimating() : self.startAnimating()
        }
    }
}
