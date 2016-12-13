//
//  ItemController.swift
//  Spotifier
//
//  Created by iosakademija on 12/13/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import UIKit

class ItemController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

extension ItemController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 300
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell",
                                                      for: indexPath)
        return cell
    }
}
