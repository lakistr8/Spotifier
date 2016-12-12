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


final class DataManager {
    
    static let shared = DataManager()
    private init() {}
    
    var coreDataStack : RTCoreDataStack?
    
    func search(for string: String, type: Spotify.SearchType) {
        guard let coreDataStack = coreDataStack else { return }
        
        let path : Spotify.Path = .search(q: "taylor", type: .artist)
        Spotify.shared.call(path: path) {
            json, error in
            
            if let _ = error { return }
            guard let json = json else { return }
            
            switch type {
            case .track:
                guard let trackResult = json["tracks"] as? Spotify.JSON else { return }
                guard let items = trackResult["items"] as? [Spotify.JSON] else { return }
                
            default:
                break
            }
            
            //	process JSON or errors
        }
    }
}
