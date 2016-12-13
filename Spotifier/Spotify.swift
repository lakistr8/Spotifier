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
    
    static let commonHeaders: [String: String] = {
        return [
            "User-Agent": "Spotifier/1.0",
            "Accept": "application/json",
            "Accept-Charset": "utf-8",
            "Accept-Encoding": "gzip, deflate"
        ]
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
        
        private var headerFields: [String: String] {
//            var headers = commonHeaders
            //			switch self {
            //			case .albums:
            //				headers["Accept"] = "text/html"
            //			default:
            //				break
            //			}
//            return headers
            return commonHeaders
        }
        
        var fullURL : URL {
            
            var path = ""
            
            switch self {
            case .search:
                path = "search"
            case .artist(let id, let type):
                path = "artist/\(id)/\(type)"
            default:
                break
            }
            return baseURL.appendingPathComponent(path)
        }
        
        
        private var params: [String: String] {
            var p = [String: String]()
            switch self {
            case .search(let q, let type):
                p["q"] = q
                p["type"] = type.rawValue
                p["limit"] = "50"
            default:
                break
            }
            
            return p
        }
        
        private func queryEncoded(params : [String: String]) -> String {
            if params.count == 0 { return "" }
            var arr = [String]()
            for (key,value) in params {
                let s = "\(key)=\(value)"
                arr.append(s)
            }
            
            return arr.joined(separator: "&")
        }
        
        var urlRequest: URLRequest {
            
            guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else { fatalError("Invalid URL") }
            components.query = queryEncoded(params: params)
            
            guard let url = components.url else { fatalError("Invalid URL") }
            var r = URLRequest(url: url)
            r.httpMethod = method.rawValue
            r.allHTTPHeaderFields = headerFields
            
            return r
        }
    }
}

extension Spotify {
    
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






