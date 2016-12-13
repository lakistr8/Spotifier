//
//  DataManager.swift
//  Spotifier
//
//  Created by iosakademija on 12/12/16.
//  Copyright © 2016 iosakademija. All rights reserved.
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
                let jsonIDs = items.flatMap({ item in item["id"] as? String })
                
                //	pick-up (possibly) existing tracks in Core Data, with those IDs
                let predicate = NSPredicate(format: "%K IN %@",
                                            Track.Attributes.trackId,
                                            jsonIDs)
                
                let existingIDS: Set<Track> = Track.fetch(property: Track.Attributes.trackId,
                                                          context: moc,
                                                          predicate: predicate)
                
                for item in items {
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
