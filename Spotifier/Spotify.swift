//
//  Spotify.swift
//  Spotifier
//
//  Created by iosakademija on 12/10/16.
//  Copyright © 2016 iosakademija. All rights reserved.
//

import Foundation


final class Spotify {
    
    static let shared = Spotify()
    private init() {}
    
    static let baseURL : URL = {
        
        guard let url = URL(string: "https://api.spotify.com/v1/") else {
            fatalError("faild to create a base url!")}
        return url
    }()
    
}




extension Spotify {
    
    enum Method: String {
        case GET, POST, PUT, DELETE
    }
    
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
        
        private var method: Method {
            return .GET
        }
        
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
        
        var urlRequest: URLRequest {
            
            var r = URLRequest(url: fullURL)
            r.httpMethod = method.rawValue
            
            return r
        }
    }
}

extension Spotify {
    
    typealias JSON = [String:Any]
    typealias CallBack = (JSON?, Error?) -> Void
    
    
    func call(path: Path, completion: @escaping CallBack) {
        
        let urlRequest = path.urlRequest
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, urlResponse, error in
            
            //	process the returned stuff, now
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                completion(nil, error)
                return
            }
            
            if httpURLResponse.statusCode != 200 {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            guard
                let obj = try? JSONSerialization.jsonObject(with: data),
                let json = obj as? JSON
            else {
                completion(nil, nil)
                return
            }
            completion(json, nil)
            
        }
        
        task.resume()
    }
    
    
}






