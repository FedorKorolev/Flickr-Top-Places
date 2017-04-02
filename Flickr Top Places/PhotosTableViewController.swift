//
//  PhotosTableViewController.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 02.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController {

    var place = Place(json: ["":""])
    
    var photos = [PhotoInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.title = place?.name
        
        let api = FlickrAPIService()
        api.search(place: (place?.id)!,
                   success: { photos in
                    print("loaded photos:\n\(photos)")
                    DispatchQueue.main.async {
                        self.photos = photos
                        self.tableView.reloadData()
                    }
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }) { error in
            print(error)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        
        
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        image.loadImage(link: photos[indexPath.row].iconLink)
        print("Loaded image: \(image)")
        cell.addSubview(image)
        
        cell.textLabel?.text = photos[indexPath.row].title

        return cell
    }

    
    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Photo", sender: photos[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? SinglePhotoViewController,
            let selectedPhoto = sender as? PhotoInfo {
            destVC.photo = selectedPhoto
        }
    }
}
