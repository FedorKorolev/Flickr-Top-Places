//
//  FlickrAPIService.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 01.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import Foundation

class FlickrAPIService {
    
    enum APIError: Error {
        case wrongServerResponce
        case emptyPlacesList
    }
    
    static func loadTopPlacesList(success: @escaping( ([Place]) -> Void ), failure: @escaping( (Error) -> Void ) ) {
        
        // Build URL
        struct Constants {
            static let serviceURL = "https://api.flickr.com/services/rest/"
            static let method = "method"
            static let apiKey = "330926c4466e3c78331faf6db828c278"
            
            static func buildWith(methodName: String) -> String {
                return serviceURL + "?" + method + "=" + methodName + "&api_key=" + apiKey + "&format=json&nojsoncallback=1"
            }
        }
        
        var urlString = Constants.buildWith(methodName: "flickr.places.getTopPlacesList")
        
        let arguments = ["place_type_id" : 7]
        
        for (key, value) in arguments {
            urlString.append("&\(key)=\(value)")
        }
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        print("URL built:\n" + urlString)
        
        let url = URL(string: urlString)!

        
        // Access URL
        print("Server Access...")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            print("data: \(String(describing: data))\nresponse: \(String(describing: response))\nerror: \(String(describing: error))")
            guard error == nil
                else {
                    failure(error!)
                    return
            }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200,
                let jsonData = data else {
                    failure( APIError.wrongServerResponce)
                    return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                let dictionary = jsonObject as? [String : Any]
                else {
                    failure(APIError.wrongServerResponce)
                    return
            }
            
            print("Got dictionary: \(dictionary)")
            
            
            // Build places
            var places = [Place]()
            
            guard let placesDict = dictionary["places"] as? [String : Any] else {
                places = []
                return
            }
            guard let placeJSONs = placesDict["place"] as? [ [String : Any] ] else {
                places = []
                return
            }
            
            for placeJSON in placeJSONs {
                if let place = Place(json: placeJSON) {
                    places.append(place)
                }
            }
            
            guard places.count > 0 else {
                failure(APIError.emptyPlacesList)
                return
            }
            
            success(places)
            
            
        }
        
        task.resume()
    }
    
}


