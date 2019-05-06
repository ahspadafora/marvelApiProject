//
//  MarvelDataModels.swift
//  Marvelous
//
//  Created by Mark Turner on 11/9/18.
//  Copyright © 2018 Mark Turner. All rights reserved.
//

import Foundation

struct Character : Codable {
    let id          : Int?
    let name        : String?
    let description : String?
    let thumbnail   : ImageReference?
}

struct ImageReference : Codable {
    let path          : String
    let fileExtension : String?
    
    enum CodingKeys : String, CodingKey {
        case path
        case fileExtension = "extension"
    }
}

extension ImageReference {
    
    var url : URL {
        return URL(string: path + "/landscape_incredible"  + "." + (fileExtension ?? ""))!
    }
}


