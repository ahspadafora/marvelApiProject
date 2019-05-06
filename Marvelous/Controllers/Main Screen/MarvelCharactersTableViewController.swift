//
//  MarvelCharactersTableViewController.swift
//  Marvelous
//
//  Created by Mark Turner on 11/9/18.
//  Copyright © 2018 Mark Turner. All rights reserved.
//

import UIKit

class CharacterImagesManager {
    private init(){}
    
    static let shared = CharacterImagesManager()
    let imageCache = NSCache<AnyObject, AnyObject>()
    let urlSession = URLSession.shared
    
    func cacheImage(from url: URL?, callback: @escaping (UIImage) -> Void) {
        guard let validImgUrl = url else { return }
        // check cache for already downloaded image
        if let previouslyCachedImgForURL = imageCache.object(forKey: validImgUrl as AnyObject) as? UIImage {
            callback(previouslyCachedImgForURL)
        }
        // if image is not in cache, download from network
        else {
            urlSession.dataTask(with: validImgUrl) { [weak self] (data, response, error) in
                guard let self = self else { return }
                if let data = data {
                    guard let img = UIImage(data: data) else { return }
                    self.imageCache.setObject(img, forKey: url as AnyObject)
                    callback(img)
                }
            }.resume()
        }
    }
    
    
}


class MarvelCharactersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    
    @IBOutlet weak var whiteBackgroundView: UIView!
    
    @IBOutlet weak var characterTableView: UITableView!
    
    // MARK: - Properties
    private let marvelAPI = MarvelAPI()
    private var characters = [Character]() {
        didSet {
            DispatchQueue.main.async {
                self.characterTableView.reloadData()
            }
        }
    }
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        whiteBackgroundView.layer.cornerRadius = 8.0
        setUpActivityIndicator()
        loadMarvelCharactersFromApi()
    }
    
    // MARK: - Setup Methods
    private func loadMarvelCharactersFromApi() {
        // start activity indicator and start loadingCharacters from API
        
        activityIndicator.toggleAnimation()
        
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
                    self.activityIndicator.toggleAnimation()
                })
            }
            
        }) { (error) in
            self.activityIndicator.toggleAnimation()
        }
    }
    
    private func setUpActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.color = UIColor.red
        activityIndicator.center = self.view.center
    }

}

extension MarvelCharactersTableViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "marvelCharacterCell", for: indexPath) as? MarvelCharacterTableViewCell else { fatalError() }
        
        cell.character = characters[indexPath.row]
        
        if indexPath.row == characters.count - 1 && characters.count != 0 {
            loadMarvelCharactersFromApi()
        }
        
        return cell
    }
    
}

