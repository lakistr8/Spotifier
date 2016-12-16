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


extension ItemController: NSFetchedResultsControllerDelegate {
    
}
