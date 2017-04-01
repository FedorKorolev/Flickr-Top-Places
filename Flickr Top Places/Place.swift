//
//  Place.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 01.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import Foundation

struct Place {
    let id: String
    let name: String
    
    init?(json: [String : Any]) {
        guard let id = json["place_id"] as? String,
              let name = json["_content"] as? String
            else {
                return nil
        }
        self.id = id
        self.name = name
    }
}
