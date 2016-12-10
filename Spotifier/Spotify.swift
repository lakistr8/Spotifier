//
//  Spotify.swift
//  Spotifier
//
//  Created by iosakademija on 12/10/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import Foundation


final class Spotify {
    
    
    enum SearchType: String {
        
        case artist
        case album
        case track
        case playlist
    }
    
    enum ItemType: String {
        case albums
        case topTracks
        case relatedArtists
        
        case tracks
    }
    
    enum Path {
        
        case search(q: String, type: SearchType)
        case artist(id: String, type: SearchType?)
        case albums(id: String, type: SearchType?)
    }
    
}
