//
//  SearchController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 15.12.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import UIKit
import CoreData

class SearchController: UIViewController {
    
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    var moc: NSManagedObjectContext? {
        didSet {
            if !self.isViewLoaded { return }
            self.setupDataSource()
        }
    }
    
    var searchString: String?
    var searchType: Spotify.SearchType = .artist
    var frc: NSFetchedResultsController<Track>?
}


extension SearchController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ItemCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "ItemCell")
        segmentedControl.selectedSegmentIndex = Spotify.SearchType.artist.integerId
        
        setupDataSource()
    }
}


extension SearchController: UICollectionViewDataSource {
    
    func setupDataSource() {
        guard let moc = self.moc else { fatalError("NEMA MOC BRE!") }
        
        let sort1 = NSSortDescriptor(key: Track.Attributes.name, ascending: true)
        
        var predicate: NSPredicate?
        if let searchString = searchString {
            predicate = NSPredicate(format: "%K contains[cd] %@",
                                    Track.Attributes.name,
                                    searchString)
        }
        let nsfrc = Track.fetchedResultsController(withContext: moc,
                                                   sectionNameKeyPath: nil,
                                                   predicate: predicate,
                                                   sortedWith: [sort1])
        nsfrc.delegate = self
        do {
            try nsfrc.performFetch()
            collectionView.reloadData()
        } catch(let error) {
            print("Error fetching from Core Data: \(error)")
        }
        frc = nsfrc
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let _ = moc else { return 0 }
        
        guard let sections = frc?.sections else { return 0 }
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let _ = moc else { return 0 }
        
        guard let sections = frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = frc?.object(at: indexPath) else { fatalError("Item not found in FRC at indexPath: \(indexPath)") }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell",
                                                      for: indexPath) as! ItemCell
        cell.configure(using: item)
        return cell
    }
}



extension SearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! GridLayout
        
        let availableWidth = collectionView.bounds.size.width
        let columns = 3
        var itemTotalWidth = availableWidth - CGFloat(columns-1) * layout.minimumInteritemSpacing
        itemTotalWidth -= (layout.sectionInset.left + layout.sectionInset.right)
        
        let itemWidth = itemTotalWidth / CGFloat(columns)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}



extension SearchController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}


extension SearchController {
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        searchType = Spotify.SearchType(with: index)!
    }
}
