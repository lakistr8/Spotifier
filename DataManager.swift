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
                let albumItems = items.flatMap({ $0["album"] as? JSON })
                let artistItems = albumItems.flatMap({ $0["artists"] as? [JSON] }).flatMap({ $0 })
                
                let artists: [Artist] = self.processJSONartists(artistItems, in: moc)
                let albums: [Album] = self.processJSONalbums(albumItems, in: moc)
                let tracks: [Track] = self.processJSONTracks(items, in: moc)
                
                for ti in items {
                    //	ID for the current track
                    guard let trackID = ti["id"] as? String else { continue }
                    //	find Track managed object for current id
                    guard let track = tracks.filter({ $0.trackId == trackID }).first else { continue }
                    
                    //	fetch album ID from the track-item's JSON
                    guard let ai = ti["album"] as? JSON, let albumID = ai["id"] as? String else { continue }
                    //	find that album and connect it to the track's relationship
                    track.album = albums.filter({ $0.albumId == albumID }).first
                    
                    //	fetch artist ID from the track-item's JSON
                    guard let arti = ai["artists"] as? [JSON], let artistID = arti.first?["id"] as? String else { continue }
                    //	find that artist and connect it to the album's relationship
                    track.album?.artist = artists.filter({ $0.artistId == artistID }).first
                }
                
                //			case .album:
                //				guard let trackResult = json["albums"] as? JSON else { return }
                //				guard let items = trackResult["items"] as? [JSON] else { return }
                //				let _: [Album] = self.processJSON(items: items, in: moc, idProperty: Album.Attributes.albumId)
                //				let tracks = self.processJSONTracks(items, in: moc)
                
            default:
                break
            }
            
            //	finally, save!
            do {
                try moc.save()
            } catch(let error) {
                print("Context Save failed due to: \(error)")
            }
        }
    }
    
}


extension DataManager {
    
    func processJSONTracks(_ items: [JSON], in moc: NSManagedObjectContext) -> [Track] {
        var arr = [Track]()
        let objectIDProperty = Track.Attributes.trackId
        
        //	extract IDs from JSON
        let jsonIDs = items.flatMap({ item in return item["id"] as? String })
        let setIDs = Set(jsonIDs)
        
        //	pick-up (possibly) existing objects in Core Data, with those IDs
        let predicate = NSPredicate(format: "%K IN %@",
                                    objectIDProperty,
                                    jsonIDs)
        //	fetch IDs only for existing objects that are sent in this JSON payload
        let existingIDs: Set<String> = Track.fetch(property: objectIDProperty,
                                                   context: moc,
                                                   predicate: predicate)
        
        //	IDs for new objects to create:
        let inserted = setIDs.subtracting(existingIDs)
        //	IDs for existing objects to update them:
        let updated = setIDs.intersection(existingIDs)
        //	IDs for objects to (maybe) delete:
        let deleted = existingIDs.subtracting(setIDs)
        
        //	insert all new objects
        for id in inserted {
            //	find JSON for current ID
            let filteredItems = items.filter({ item in
                guard let jsonID = item["id"] as? String else { return false }
                return jsonID == id
            })
            //	there should be only one JSON item
            guard let item = filteredItems.first else { continue }
            //	create managed object using that JSON item
            if let mobject = Track(json: item, in: moc) {
                arr.append(mobject)
            }
        }
        
        if updated.count > 0 {
            //	fetch all existing objects, using just one call
            //	this predicate means: `FETCH Object WHERE objectId IN updated`
            let predicate = NSPredicate(format: "%K IN %@",
                                        objectIDProperty,
                                        updated)
            let mobjects = Track.fetch(withContext: moc, predicate: predicate)
            
            for id in updated {
                //	find JSON for current `id`
                let filteredItems = items.filter({ item in
                    guard let jsonID = item["id"] as? String else { return false }
                    return jsonID == id
                })
                //	there should be only one JSON item for each `id` in `updated`
                guard let item = filteredItems.first else { continue }
                //	similarly, there should be only one object in Core Data for any given `id`
                guard let mobject = mobjects.filter({ mo in
                    guard let moId = mo.value(forKey: objectIDProperty) as? String else { fatalError("Failed to convert object's id property to String") }
                    return moId == id
                }).first else { continue }
                
                do {
                    try mobject.update(with: item)
                    arr.append(mobject)
                } catch (let coredataError) {
                    print(coredataError)
                }
            }
        }
        
        if deleted.count > 0 {
            //	TBD.
        }
        
        return arr
    }
    
    func processJSONalbums(_ items: [JSON], in moc: NSManagedObjectContext) -> [Album] {
        var arr = [Album]()
        let objectIDProperty = Album.Attributes.albumId
        
        //	extract IDs from JSON
        let jsonIDs = items.flatMap({ item in return item["id"] as? String })
        let setIDs = Set(jsonIDs)
        
        //	pick-up (possibly) existing objects in Core Data, with those IDs
        let predicate = NSPredicate(format: "%K IN %@",
                                    objectIDProperty,
                                    jsonIDs)
        //	fetch IDs only for existing objects that are sent in this JSON payload
        let existingIDs: Set<String> = Album.fetch(property: objectIDProperty,
                                                   context: moc,
                                                   predicate: predicate)
        
        //	IDs for new objects to create:
        let inserted = setIDs.subtracting(existingIDs)
        //	IDs for existing objects to update them:
        let updated = setIDs.intersection(existingIDs)
        //	IDs for objects to (maybe) delete:
        let deleted = existingIDs.subtracting(setIDs)
        
        //	insert all new objects
        for id in inserted {
            //	find JSON for current ID
            let filteredItems = items.filter({ item in
                guard let jsonID = item["id"] as? String else { return false }
                return jsonID == id
            })
            //	there should be only one JSON item
            guard let item = filteredItems.first else { continue }
            //	create managed object using that JSON item
            if let mobject = Album(json: item, in: moc) {
                arr.append(mobject)
            }
        }
        
        if updated.count > 0 {
            //	fetch all existing objects, using just one call
            //	this predicate means: `FETCH Object WHERE objectId IN updated`
            let predicate = NSPredicate(format: "%K IN %@",
                                        objectIDProperty,
                                        updated)
            let mobjects = Album.fetch(withContext: moc, predicate: predicate)
            
            for id in updated {
                //	find JSON for current `id`
                let filteredItems = items.filter({ item in
                    guard let jsonID = item["id"] as? String else { return false }
                    return jsonID == id
                })
                //	there should be only one JSON item for each `id` in `updated`
                guard let item = filteredItems.first else { continue }
                //	similarly, there should be only one object in Core Data for any given `id`
                guard let mobject = mobjects.filter({ mo in
                    guard let moId = mo.value(forKey: objectIDProperty) as? String else { fatalError("Failed to convert object's id property to String") }
                    return moId == id
                }).first else { continue }
                
                do {
                    try mobject.update(with: item)
                    arr.append(mobject)
                } catch (let coredataError) {
                    print(coredataError)
                }
            }
        }
        
        if deleted.count > 0 {
            //	TBD.
        }
        
        return arr
    }
    
    func processJSONartists(_ items: [JSON], in moc: NSManagedObjectContext) -> [Artist] {
        var arr = [Artist]()
        let objectIDProperty = Artist.Attributes.artistId
        
        //	extract IDs from JSON
        let jsonIDs = items.flatMap({ item in return item["id"] as? String })
        let setIDs = Set(jsonIDs)
        
        //	pick-up (possibly) existing objects in Core Data, with those IDs
        let predicate = NSPredicate(format: "%K IN %@",
                                    objectIDProperty,
                                    jsonIDs)
        //	fetch IDs only for existing objects that are sent in this JSON payload
        let existingIDs: Set<String> = Artist.fetch(property: objectIDProperty,
                                                    context: moc,
                                                    predicate: predicate)
        
        //	IDs for new objects to create:
        let inserted = setIDs.subtracting(existingIDs)
        //	IDs for existing objects to update them:
        let updated = setIDs.intersection(existingIDs)
        //	IDs for objects to (maybe) delete:
        let deleted = existingIDs.subtracting(setIDs)
        
        //	insert all new objects
        for id in inserted {
            //	find JSON for current ID
            let filteredItems = items.filter({ item in
                guard let jsonID = item["id"] as? String else { return false }
                return jsonID == id
            })
            //	there should be only one JSON item
            guard let item = filteredItems.first else { continue }
            //	create managed object using that JSON item
            if let mobject = Artist(json: item, in: moc) {
                arr.append(mobject)
            }
        }
        
        if updated.count > 0 {
            //	fetch all existing objects, using just one call
            //	this predicate means: `FETCH Object WHERE objectId IN updated`
            let predicate = NSPredicate(format: "%K IN %@",
                                        objectIDProperty,
                                        updated)
            let mobjects = Artist.fetch(withContext: moc, predicate: predicate)
            
            for id in updated {
                //	find JSON for current `id`
                let filteredItems = items.filter({ item in
                    guard let jsonID = item["id"] as? String else { return false }
                    return jsonID == id
                })
                //	there should be only one JSON item for each `id` in `updated`
                guard let item = filteredItems.first else { continue }
                //	similarly, there should be only one object in Core Data for any given `id`
                guard let mobject = mobjects.filter({ mo in
                    guard let moId = mo.value(forKey: objectIDProperty) as? String else { fatalError("Failed to convert object's id property to String") }
                    return moId == id
                }).first else { continue }
                
                do {
                    try mobject.update(with: item)
                    arr.append(mobject)
                } catch (let coredataError) {
                    print(coredataError)
                }
            }
        }
        
        if deleted.count > 0 {
            //	TBD.
        }
        
        return arr
    }
}


