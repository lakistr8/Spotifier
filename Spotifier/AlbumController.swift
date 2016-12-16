//
//  AlbumController.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 15.12.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import UIKit
import CoreData

class AlbumController: UIViewController {
    
    weak var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AlbumController.handle(notification:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
}


extension AlbumController {
    
    func handle(notification: Notification) {
        
        switch notification.name {
        case Notification.Name.NSManagedObjectContextObjectsDidChange:
            guard let album = album else { return }
            guard let userInfo = notification.userInfo as? [String: Any] else { return }
            //	was it updated?
            if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                //	we can't use the obejct themselves, as these updates
                //	could have happened on diff. ManagedObjectContext
                //	the only thing that's safe to access across contexts is `objectID`
                let updatedObjectIDs = updated.flatMap({ $0.objectID })
                if updatedObjectIDs.contains(album.objectID) {
                    //	it was updated, then do reloadData() or something
                }
            }
            //	deleted? inserted? similar processing is needed
            
        default:
            break
        }
    }
}
