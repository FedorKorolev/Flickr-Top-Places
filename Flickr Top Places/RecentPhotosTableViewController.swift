//
//  RecentPhotosTableViewController.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 03.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class RecentPhotosTableViewController: PhotosTableViewController {
    
    override func viewDidLoad() {
    
        let api = FlickrAPIService()
        api.search(place: nil, getRecent: true,
                   success: { photos in
                    print("loaded photos:\n\(photos)")
                    self.photos = photos
                    self.tableView.reloadData()
        }) { error in
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Photo From Recent Tab", sender: photos[indexPath.row])
    }

    
}
