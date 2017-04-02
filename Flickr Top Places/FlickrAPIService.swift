//
//  FlickrAPIService.swift
//  Flickr Top Places
//
//  Created by Фёдор Королёв on 01.04.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class FlickrAPIService {
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    enum APIError: Error {
        case wrongServerResponse
        case emptyPlacesList
        case noPhotosFound
    }
    
    struct Constants {
        static let serviceURL = "https://api.flickr.com/services/rest/"
        static let method = "method"
        static let apiKey = "330926c4466e3c78331faf6db828c278"
        
        static func buildWith(methodName: String) -> String {
            return serviceURL + "?" + method + "=" + methodName + "&api_key=" + apiKey + "&format=json&nojsoncallback=1"
        }
    }
    
    private func buildURL(methodName: String, arguments: [String : Any]) -> URL {
        var urlString = Constants.buildWith(methodName: methodName)
        
        let arguments = arguments
        
        if arguments.isEmpty != true {
            for (key, value) in arguments {
                urlString.append("&\(key)=\(value)")
            }
        }
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        print("URL built:\n" + urlString)
        
        return URL(string: urlString)!
    }
    
    // LOAD TOP PLACES
    func loadTopPlacesList(success: @escaping( ([Place]) -> Void ), failure: @escaping( (Error) -> Void ) ) {
        
        // Build URL
        let url = buildURL(methodName: "flickr.places.getTopPlacesList", arguments: ["place_type_id" : 7])
        
        // Download JSON
        print("Server Access...")
        
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
                    failure( APIError.wrongServerResponse)
                    return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                let dictionary = jsonObject as? [String : Any]
                else {
                    failure(APIError.wrongServerResponse)
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
    
    
    
    // LOAD PLACE PHOTOS
    
    func search(place id: String?, getRecent: Bool = false,
                //escaping означает, что это замыкание будет выполнено не в течение работы метода search
        //а когда-то потом
        success:@escaping( ([PhotoInfo]) -> Void ),
        failure:@escaping ( (Error) -> Void ))
    {
        print("а сейчас мы обратимся к серверу")
        
        let url: URL
        
        if getRecent {
            url = self.buildURL(methodName: "flickr.photos.getRecent", arguments: ["extras":"geo,url_l,url_s"])
        } else {
            url = self.buildURL(methodName: "flickr.photos.search", arguments: ["place_id" : id!,
                                                                                "has_geo":"1",
                                                                                "extras":"geo,url_l,url_s"])
        }
        
        
        //данные получаются не мгновенно
        //и резальтат будет вызван уже после работы метода search
        //и после resumе
        //поэтому мы обязаны для замыканий success и failure
        //добавить @escaping
        let task:URLSessionTask = session.dataTask(with: url) { (data, response, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print("\n=============data:\(String(describing:data)) \nresponse:\(String(describing:response)) \nerror:\(String(describing:error))")
            guard error == nil else {
                failure(error!)
                return
            }
            
            //убедимся, что ответ от сервера успешный
            guard let serverResponse = response as? HTTPURLResponse,
                //код ответа успешный
                serverResponse.statusCode == 200,
                //убедимся, что какие-то данные нам пришли
                //и мы их сможем преобразовать
                let jsonData = data else {
                    failure( APIError.wrongServerResponse )
                    return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData,
                                                                     options: []),
                let dictionary = jsonObject as? [String:Any] else {
                    failure(APIError.wrongServerResponse)
                    return
            }
            
            let photos = self.buildPhotos(from: dictionary)
            
            
            guard photos.count > 0 else {
                failure(APIError.noPhotosFound)
                return
            }
            success(photos)
        }
        
        //запустим выполенение созданной задачи
        task.resume()
        
        //https://api.flickr.com/services/rest/?
        print("вызов метода search завершен")
    }
    
    private func buildPhotos(from dictionary: [String:Any])->[PhotoInfo]
    {
        //попробуем прорваться через тернии ключей и значений
        //до массива с описанием фотографий
        guard let photoS = dictionary["photos"] as? [String: Any] else {
            return []
        }
        guard let photoJSONs = photoS["photo"] as? [ [String:Any] ] else {
            return []
        }
        
        var result = [PhotoInfo]()
        
        //пробежимся по словарям и попробуем из них получить
        //фотографии
        for photoJSON in photoJSONs {
            if let info = PhotoInfo(json: photoJSON){
                result.append(info)
            }
        }
        
        return result
    }

    
    
}


