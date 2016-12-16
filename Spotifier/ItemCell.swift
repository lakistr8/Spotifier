//
//  ItemCell.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 8.12.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var photoView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
}


extension ItemCell {
    
    func configure(using track: Track) {
        titleLabel.text = track.name
        
        photoView.image = nil
        guard
            let link = track.album?.imageLink,
            let url = URL(string: link)
            else {
                return
        }
        
        self.photoView.kf.setImage(with: url)
    }
}
