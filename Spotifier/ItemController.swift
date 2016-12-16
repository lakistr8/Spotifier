//
//  ItemsController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 8.12.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import UIKit
import CoreData

class ItemController: UIViewController {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //		self.automaticallyAdjustsScrollViewInsets = true
        
        let cellNib = UINib(nibName: "ItemCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "ItemCell")
    }
    
    var moc: NSManagedObjectContext? {
        didSet {
            if !self.isViewLoaded { return }
            self.collectionView.reloadData()
        }
    }
    
    lazy var frc: NSFetchedResultsController<Track> = {
        guard let moc = self.moc else { fatalError("NEMA MOC BRE!") }
        
        let sectionNameKeyPath = "\(Track.Relationships.album).\(Album.Attributes.name)"
        
        let sort0 = NSSortDescriptor(key: sectionNameKeyPath, ascending: true)
        let sort1 = NSSortDescriptor(key: Track.Attributes.name, ascending: true)
        
        let predicate = NSPredicate(format: "%K.%K != nil",
                                    Track.Relationships.album,
                                    Album.Attributes.imageLink)
        
        let nsfrc = Track.fetchedResultsController(withContext: moc,
                                                   sectionNameKeyPath: nil,
                                                   predicate: predicate,
                                                   sortedWith: [sort0, sort1])
        nsfrc.delegate = self
        do {
            try nsfrc.performFetch()
        } catch(let error) {
            print("Error fetching from Core Data: \(error)")
        }
        
        return nsfrc
    }()
    
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}


extension ItemController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let _ = moc else { return 0 }
        
        guard let sections = frc.sections else { return 0 }
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let _ = moc else { return 0 }
        
        guard let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell",
                                                      for: indexPath) as! ItemCell
        let item = frc.object(at: indexPath)
        cell.configure(using: item)
        return cell
    }
}



extension ItemController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! GridLayout
        
        let availableWidth = collectionView.bounds.size.width
        let columns = (availableWidth / 4 > 150) ? 4 : 2
        var itemTotalWidth = availableWidth - CGFloat(columns-1) * layout.minimumInteritemSpacing
        itemTotalWidth -= (layout.sectionInset.left + layout.sectionInset.right)
        
        let itemWidth = itemTotalWidth / CGFloat(columns)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}



extension ItemController: NSFetchedResultsControllerDelegate {
    
}


extension ItemController {
    
    @IBAction func didTapSearch(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchController") as! SearchController
        vc.moc = moc
        show(vc, sender: self)
    }
}
