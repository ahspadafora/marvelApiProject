//
//  MarvelCharacterTableViewCell.swift
//  Marvelous
//
//  Created by Amber Spadafora on 12/3/18.
//  Copyright © 2018 Mark Turner. All rights reserved.
//

import UIKit

class MarvelCharacterTableViewCell: UITableViewCell {

    var character: Character? {
        didSet {
            setUpCell()
        }
    }
    
    var characterImgGradientLayer: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.characterImageView.bounds
        gradient.colors = [UIColor(red:0.19, green:0.14, blue:0.68, alpha:1.0).cgColor, UIColor(red:0.78, green:0.43, blue:0.84, alpha:1.0).cgColor]
        gradient.locations = [0, 1]
        gradient.opacity = 0.4
        return gradient
    }
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var gradientOverlayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        characterImageView.layer.addSublayer(characterImgGradientLayer)
    }
    
    func setUpCell() {
        self.characterNameLabel.text = character?.name
        CharacterImagesManager.shared.cacheImage(from: character?.thumbnail?.url) { [weak self] (image) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.characterImageView.image = image
            }
        }
    }

}
