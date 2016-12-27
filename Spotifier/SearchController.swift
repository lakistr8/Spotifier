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
    
    var searchController : UISearchController?
    
    
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    var moc: NSManagedObjectContext? {
        didSet {
            if !self.isViewLoaded { return }
            self.collectionView.reloadData()
        }
    }
    
    var searchString: String? {
        didSet {
            self.updateDataSource()
        }
    }
    var searchType: Spotify.SearchType = .artist
    lazy var frc: NSFetchedResultsController<Track> = {
        guard let moc = self.moc else { fatalError("NEMA MOC BRE!") }
        
        let sort1 = NSSortDescriptor(key: Track.Attributes.name, ascending: true)
        let nsfrc = Track.fetchedResultsController(withContext: moc,
                                                   sectionNameKeyPath: nil,
                                                   predicate: nil,
                                                   sortedWith: [sort1])
        nsfrc.delegate = self
        do {
            try nsfrc.performFetch()
        } catch(let error) {
            print("Error fetching from Core Data: \(error)")
        }
        return nsfrc
    }()
}


extension SearchController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ItemCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "ItemCell")
        segmentedControl.selectedSegmentIndex = Spotify.SearchType.artist.integerId
        
        setupSearch()
    }
}


extension SearchController: UICollectionViewDataSource {
    
    func updateDataSource() {
        guard let searchString = searchString else { return }
        let predicate = NSPredicate(format: "%K contains[cd] %@",
                                    Track.Attributes.name,
                                    searchString)
        frc.fetchRequest.predicate = predicate
        do {
            try frc.performFetch()
            collectionView.reloadData()
        } catch(let error) {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
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
        let item = frc.object(at: indexPath)
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

extension SearchController : UISearchResultsUpdating {
    
    func setupSearch() {
        searchController = {
            let sc = UISearchController(searchResultsController: nil)
            sc.searchResultsUpdater = self
            //
            sc.hidesNavigationBarDuringPresentation = false
            sc.dimsBackgroundDuringPresentation = false
            
            //
            sc.searchBar.searchBarStyle = UISearchBarStyle.minimal
            self.navigationItem.titleView = sc.searchBar
            sc.searchBar.sizeToFit()
            
            return sc
        }()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.searchString = searchController.searchBar.text
        self.collectionView.reloadData()
    }
    
}

