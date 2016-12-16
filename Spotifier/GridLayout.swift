//
//  GridLayout.swift
//  Spotifier
//
//  Created by iosakademija on 12/16/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import UIKit

class GridLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.itemSize = CGSize(width: 150, height: 150)
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        self.sectionInset = .zero
        self.scrollDirection = .vertical
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        
        return cv.bounds.size != newBounds.size
    }
}
