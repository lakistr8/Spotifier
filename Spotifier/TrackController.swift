//
//  TrackController.swift
//  Spotifier
//
//  Created by iosakademija on 12/10/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import UIKit
import CoreData
import RTCoreDataStack

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
        
//      let predicate = NSPredicate(format: "name like 'house'")
        let predicate = NSPredicate(format: "%K contains[cd] %@", Track.Attributes.name.rawValue, "house")
        fetchRequest.predicate = predicate
        
        let sort0 = NSSortDescriptor(key: "album.name", ascending: true)
        let sort1 = NSSortDescriptor(key: Track.Attributes.name.rawValue, ascending: true)
        let sort2 = NSSortDescriptor(key: Track.Attributes.name.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sort0, sort1, sort2]
        
        let nsfrc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                               managedObjectContext: self.moc!,
                                               sectionNameKeyPath: "album.name",
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
        
        guard let sections = frc.section else { return 1 }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = moc else { return 0 }
        
        guard let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath)
        
        let item = frc.object(at: indexPath)
        
        cell.textLabel?.text = item.name
        
        return cell
    }
}


extension TrackController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}





