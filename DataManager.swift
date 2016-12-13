//
//  DataManager.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 1.12.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import Foundation
import CoreData
import RTCoreDataStack


typealias JSON = [String: Any]


enum DataImportError: Error {
    case typeMismatch(expected: Any, actual: Any, key: String)
}



final class DataManager {
    
    static let shared = DataManager()
    private init() {}
    
    var coreDataStack: RTCoreDataStack?
    
    func search(for string: String, type: Spotify.SearchType) {
        guard let coreDataStack = coreDataStack else { return }
        
        let path : Spotify.Path = .search(q: string, type: type)
        
        Spotify.shared.call(path: path) {
            json, error in
            
            if let _ = error { return }
            guard let json = json else { return }
            
            let moc = coreDataStack.importerContext()
            
            switch type {
            case .track:
                guard let trackResult = json["tracks"] as? JSON else { return }
                guard let items = trackResult["items"] as? [JSON] else { return }
                
                //	extract track IDs from JSON
                let jsonIDs = items.flatMap({ item in return item["id"] as? String })
                let setIDs = Set(jsonIDs)
                
                //	pick-up (possibly) existing tracks in Core Data, with those IDs
                let predicate = NSPredicate(format: "%K IN %@",
                                            Track.Attributes.trackId,
                                            jsonIDs)
                //	fetch IDs only for existing tracks that are sent in this JSON payload
                let existingIDs: Set<String> = Track.fetch(property: Track.Attributes.trackId,
                                                           context: moc,
                                                           predicate: predicate)
                
                //	IDs for new tracks to add:
                let inserted = setIDs.subtracting(existingIDs)
                //	IDs for existing tracks to update:
                let updated = setIDs.intersection(existingIDs)
                //	IDs for tracks to (maybe) delete:
                let deleted = existingIDs.subtracting(setIDs)
                
                //	insert all new Tracks
                for id in inserted {
                    //	find JSON for current ID
                    let filteredItems = items.filter({ item in
                        guard let jsonID = item["id"] as? String else { return false }
                        return jsonID == id
                    })
                    //	there should be only one item
                    guard let item = filteredItems.first else { continue }
                    //	insert that item
                    let _ = Track(json: item, in: moc)
                }
                
                do {
                    try moc.save()
                } catch(let error) {
                    print("Context Save failed due to: \(error)")
                }
                
            default:
                break
            }
        }
    }
    
    
}
