//
//  PhotoInfo.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 02.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import Foundation

struct PhotoInfo {
    let title: String?
    
    let iconLink: String
    let fullPhotoLink: String
    
    init?(json: [String : Any])
    {
        guard let icon = json["url_s"] as? String,
              let fullPhoto = json["url_l"] as? String
            else {
                return nil
        }
        
        self.iconLink = icon
        self.fullPhotoLink = fullPhoto
        self.title = json["title"] as? String
    }
}
