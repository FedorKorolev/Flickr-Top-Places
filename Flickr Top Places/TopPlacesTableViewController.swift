//
//  TopPlacesTableViewController.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 01.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class TopPlacesTableViewController: UITableViewController {

    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let api = FlickrAPIService()
        
        api.loadTopPlacesList(
            success: { places in
                print("Loaded places:\n\(places)")
                DispatchQueue.main.async {
                    self.places = places
                    self.tableView.reloadData()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
        },
            failure: { error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print(error)
        })
        
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }


    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Photos of Place", sender: places[indexPath.row])
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if let destVC = segue.destination as? PhotosTableViewController,
            let selectedPlace = sender as? Place {
            destVC.place = selectedPlace
        }
    }
 

}
