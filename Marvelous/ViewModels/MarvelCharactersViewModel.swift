//
//  MarvelCharactersViewModel.swift
//  Marvelous
//
//  Created by Amber Spadafora on 5/6/19.
//  Copyright © 2019 Mark Turner. All rights reserved.
//

import Foundation

final class MarvelCharactersViewModel {
    
    private let marvelAPI = MarvelAPI()
    private var characters = [Character]()
    
    init(){}
    
    public func getCharacterCount() -> Int {
        return characters.count
    }
    
    public func getCharcterForIndex(indexPath: Int) -> Character? {
        guard indexPath < characters.count else { return nil }
        return characters[indexPath]
    }
    
    public func loadMarvelCharactersFromApi(callback: @escaping (Error?)->()) {
        marvelAPI.loadCharacters(offset: characters.count, limit: 50, success: { [weak self] (response) in
            guard let self = self else { return }
            
            // download each img for each character before updating tableView by using a DispatchGroup
            let imageGetterDispatchGroup = DispatchGroup()
            DispatchQueue.global(qos: .default).async {
                
                for marvelCharacter in response.results {
                    imageGetterDispatchGroup.enter()
                    guard let marvelCharacterImgUrl = marvelCharacter.thumbnail?.url else { return }
                    CharacterImagesManager.shared.cacheImage(from: marvelCharacterImgUrl, callback: { (_) in
                        imageGetterDispatchGroup.leave()
                    })
                }
                imageGetterDispatchGroup.notify(queue: DispatchQueue.main, execute: {
                    self.characters += response.results
                    callback(nil)
                })
            }
            
        }) { (error) in
            callback(error)
        }
    }
    
    
}
