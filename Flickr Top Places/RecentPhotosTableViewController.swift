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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        api.search(place: nil, getRecent: true,
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Photo From Recent Tab", sender: photos[indexPath.row])
    }

    @IBAction override func refresh(_ sender: UIBarButtonItem) {
        viewDidLoad()
    }
    
}
