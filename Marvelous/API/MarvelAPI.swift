//
//  MarvelAPI.swift
//  Marvelous
//
//  Created by Mark Turner on 11/9/18.
//  Copyright © 2018 Mark Turner. All rights reserved.
//

import Foundation

class MarvelAPI {
    
    enum MarvelAPIError : Error {
        case noData
    }
    
    private struct ResponseBody<T : Codable> : Codable {
        let code   : Int
        let status : String
        let data   : ResponseData<T>
    }
    
    struct ResponseData<T : Codable> : Codable {
        let offset  : Int
        let total   : Int
        let count   : Int
        let results : [T]
    }
    
    private let session = URLSession(configuration: .default)
    
    func loadCharacters(offset : Int, limit :Int, success: @escaping (ResponseData<Character>)->Void, error errorHandler: @escaping (Error)->Void) {
        
        let publicKey = "236b73580fbeb44ea22457fe1e0cb5cf"
        let privateKey = "aa0296464f7553ef1349eb4ac1e6241f9ae52fe9"
        
        let ts = UUID().uuidString
        
        let hash = (ts + privateKey + publicKey).md5Hash
        
        let url = URL(string: "https://gateway.marvel.com/v1/public/characters?ts=\(ts)&apikey=\(publicKey)&hash=\(hash)&offset=\(offset)&limit=\(limit)")!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                errorHandler(error)
                return
            }
            
            guard let data = data else {
                errorHandler(MarvelAPIError.noData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let body = try decoder.decode(ResponseBody<Character>.self, from: data)
                
                success(body.data)
            }
            catch (let error) {
                errorHandler(error)
            }
        }
        
        task.resume()
    }
    
    
    
}
