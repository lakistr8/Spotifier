//
//  Spotify.swift
//  Spotifier
//
//  Created by iosakademija on 12/10/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import Foundation


final class Spotify {
    
    static let baseURL : URL = {
        
        guard let url = URL(string: "https://api.spotify.com/v1/") else {
            fatalError("faild to create a base url!")}
        return url
    }()
    
}




extension Spotify {
    
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
        
        var apiValue: String {
            switch self {
            case .relatedArtists:
                return "related-artists"
            case .topTracks:
                return "top-tracks"
            default:
                return self.rawValue
            }
        }
        
    }
    
    enum Path {
        
        case search(q: String, type: SearchType)
        case artist(id: String, type: SearchType?)
        case albums(id: String, type: SearchType?)
        
        var fullURL : URL {
            
            var path = ""
            
            switch self {
            case .search(let q, let type):
                path = "search"
            case .artist(let id, let type):
                path = "artist/\(id)/\(type)"
            default:
                break
            }
            return baseURL.appendingPathComponent(path)
        }
    }
}







