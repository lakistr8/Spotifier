//
//  DataManager.swift
//  Spotifier
//
//  Created by iosakademija on 12/12/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import Foundation
import CoreData



final class DataManager {
    
    func search(for string: String, type: Spotify.SearchType) {
        
        let path : Spotify.Path = .search(q: "taylor", type: .artist)
        Spotify.shared.call(path: path) {
            json, error in
            
            if let _ = error { return }
            
            
            
            //	process JSON or errors
        }
}
