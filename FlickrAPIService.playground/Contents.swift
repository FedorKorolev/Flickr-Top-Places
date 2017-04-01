//: Playground - noun: a place where people can play

import UIKit

class FlickrAPIService {
    
    enum APIError: Error {
        case wrongServerResponce
        case emptyServerResponce
    }
    
    static func loadTopPlacesList(failure: @escaping( (Error) -> Void ) ) {
        
        // Build URL
        func buildURL() -> URL {
            
            struct Constants {
                static let serviceURL = "https://api.flickr.com/services/rest/"
                static let method = "method"
                static let apiKey = "77791ca940bba36e3b8facb70e26d836"
                
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
            
            return URL(string: urlString)!
            
        }
        
        // Access URL
        print("Server Access...")
        let url = buildURL()
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
        }
        
        task.resume()
    }
    
}

FlickrAPIService.loadTopPlacesList(failure: {error in })