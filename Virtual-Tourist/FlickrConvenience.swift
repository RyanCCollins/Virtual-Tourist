//
//  FlickrConvenience.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func fetchPhotos(forPin pin: Pin, completionHandler: (success: Bool, results: [Photo]?, error: NSError?)-> Void) {
        
        let parameters: [String : AnyObject] = [
            "bbox" : boundingBoxForGETImages(Double(pin.latitude), longitude: Double(pin.longitude))
        ]
        
        
        taskForGETMethod(Methods.SEARCH, parameters: parameters, queryParameters: nil) {results, error in
            
            if error != nil {
                print(error)
                completionHandler(success: false, results: nil, error: error)
            } else {
                
                if let photosDictionary = results![JSONResponseKeys.Photos] as? [String : AnyObject], photoArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]], pages = photosDictionary[JSONResponseKeys.Pages] {
                    
                    pin.countOfPhotoPages = pages as? NSNumber
                    
                    for photo in photoArray {
                        
                        let thumbNailURL = photo[JSONResponseKeys.Extras.ThumbnailURL] as! String
                        
                        let mediumURL = photo[JSONResponseKeys.Extras.MediumURL] as! String
                        
                        let largeURL = photo[JSONResponseKeys.Extras.LargeURL] as! String
                        
                        let dictionary: [String : AnyObject] = [
                            
                        ]
                        
                        let photo = Photo(dictionary: <#T##[String : AnyObject]#>, context: <#T##NSManagedObjectContext#>)
                        
                    }
                    
                }

            }
            
        }
    }
    
    func getImages(forPhoto photo: Photo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
    }
    
    private func boundingBoxForGETImages(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_longitude = max(latitude - Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lon_Min)
        let bottom_left_latitude = max(longitude - Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lat_Min)
        let top_right_longitude = max(longitude + Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lon_Max)
        let top_right_latitude = max(latitude + Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lat_Max)
        
        return "\(bottom_left_longitude),\(bottom_left_latitude),\(top_right_longitude),\(top_right_latitude)"
    }
    
    private func randomPageFromResults() -> Int {
        
    }
    
}