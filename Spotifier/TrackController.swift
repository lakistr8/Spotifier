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
    
    
}

    // MARK: - Table view data source

extension TrackController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10   
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
}
