//
//  SinglePhotoViewController.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 03.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class SinglePhotoViewController: UIViewController {
    
    var photo = PhotoInfo(json: ["" : ""])
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        imageView.loadImage(link: (photo?.fullPhotoLink)!, highPriority: true)
        title = photo?.title
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    
}
