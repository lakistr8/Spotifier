//
//  TrackController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 24.11.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import UIKit
import CoreData

class TrackController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    var moc: NSManagedObjectContext? {
        didSet {
            if !self.isViewLoaded { return }
            
            self.tableView.reloadData()
        }
    }
    
    lazy var frc: NSFetchedResultsController<Track> = {
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        
        //		let predicate = NSPredicate(format: "name like 'house'")
        let predicate = NSPredicate(format: "%K contains[cd] %@", Track.Attributes.name, "house")
        fetchRequest.predicate = predicate
        
        //		let sectionNameKeyPath = "\(Track.Relationships.album).\(Album.Attributes.name)"
        
        //		let sort0 = NSSortDescriptor(key: sectionNameKeyPath, ascending: true)
        let sort1 = NSSortDescriptor(key: Track.Attributes.name, ascending: true)
        fetchRequest.sortDescriptors = [sort1]
        
        let nsfrc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                               managedObjectContext: self.moc!,
                                               sectionNameKeyPath: nil,
                                               cacheName: nil)
        nsfrc.delegate = self
        do {
            try nsfrc.performFetch()
        } catch(let error) {
            print("Error fetching from Core Data: \(error)")
        }
        
        return nsfrc
    }()
    
}


// MARK: - Table view data source
extension TrackController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = moc else { return 1 }
        
        guard let sections = frc.sections else { return 1 }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        guard let _ = moc else { return 0 }
        
        guard let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self),
                                                 for: indexPath)
        
        let item = frc.object(at: indexPath)
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.album?.name
        
        return cell
    }
}


extension TrackController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}




