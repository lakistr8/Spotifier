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
                
                let artists: [Artist] = self.processJSON(items: artistItems, in: moc, idProperty: Artist.Attributes.artistId)
                let albums: [Album] = self.processJSON(items: albumItems, in: moc, idProperty: Album.Attributes.albumId)
                let tracks: [Track] = self.processJSON(items: items, in: moc, idProperty: Track.Attributes.trackId)
                
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
                    guard let arti = ai["artists"] as? JSON, let artistID = arti["id"] as? String else { continue }
                    //	find that artist and connect it to the album's relationship
                    track.album?.artist = artists.filter({ $0.artistId == artistID }).first
                }
                
            case .album:
                guard let trackResult = json["albums"] as? JSON else { return }
                guard let items = trackResult["items"] as? [JSON] else { return }
                let _: [Album] = self.processJSON(items: items, in: moc, idProperty: Album.Attributes.albumId)
                
            case .artist:
                guard let trackResult = json["artists"] as? JSON else { return }
                guard let items = trackResult["items"] as? [JSON] else { return }
                let _: [Artist] = self.processJSON(items: items, in: moc, idProperty: Artist.Attributes.artistId)
                
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


