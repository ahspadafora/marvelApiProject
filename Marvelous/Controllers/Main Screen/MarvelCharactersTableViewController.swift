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
    
    let marvelCharacterViewModels = MarvelCharactersViewModel()
    
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        whiteBackgroundView.layer.cornerRadius = 8.0
        setUpActivityIndicator()
        self.activityIndicator.startAnimating()
        marvelCharacterViewModels.loadMarvelCharactersFromApi { (error) in
            DispatchQueue.main.async {
                self.characterTableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
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
        return self.marvelCharacterViewModels.getCharacterCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "marvelCharacterCell", for: indexPath) as? MarvelCharacterTableViewCell, let characterForCell = self.marvelCharacterViewModels.getCharcterForIndex(indexPath: indexPath.row) else { fatalError() }
        
        cell.character = characterForCell
        
        if indexPath.row == self.marvelCharacterViewModels.getCharacterCount() - 1 && self.marvelCharacterViewModels.getCharacterCount() != 0 {
            self.activityIndicator.startAnimating()
            self.marvelCharacterViewModels.loadMarvelCharactersFromApi { (error) in
                self.activityIndicator.stopAnimating()
                self.characterTableView.reloadData()
            }
        }
        
        return cell
    }
    
}

