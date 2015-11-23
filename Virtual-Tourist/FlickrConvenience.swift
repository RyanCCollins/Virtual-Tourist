//
//  FlickrConvenience.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    
    func taskForFetchPhotos(forPin pin: Pin, completionHandler: (success: Bool, error: NSError?)-> Void) {
        
        let parameters = dictionaryForGetImages(pin.latitude, longitude: pin.longitude)
        taskForGETMethod(Constants.Base_URL_Secure, parameters: parameters) {results, error in
            
            if error != nil {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                if let photosDictionary = results![JSONResponseKeys.Photos] as? [String : AnyObject], photoArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]], pages = photosDictionary[JSONResponseKeys.Pages] {
                    
                    pin.countOfPhotoPages = pages as? NSNumber
                    
                    for photo in photoArray {

                        let mediumURL = photo[JSONResponseKeys.ImageSizes.MediumURL] as! String
                        
                        let dictionary: [String : AnyObject] = [
                            FlickrClient.JSONResponseKeys.ImageSizes.MediumURL : mediumURL
                        ]
                        
                        let photo = Photo(dictionary: dictionary, pin: pin, context: self.sharedContext)
                        
                        self.downloadResource(forPhoto: photo, completionHandler: {success, error in
                            if error != nil {
                                print(error)
                            } else {

                            CoreDataStackManager.sharedInstance().saveContext()
                                
                            }
                        })
                        
                    }
                    
                }

            }
            
        }
    }
    
    func downloadResource(forPhoto photo: Photo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        taskForGETMethod(photo.fileURL!, parameters: nil, completionHandler: {results, error in
            
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                
                if let results = results {
                    let image = UIImage(data: results as! NSData)
                    photo.image = image
                    completionHandler(success: true, error: nil)
                }
                
            }
            
        })
    }
    
    private func dictionaryForGetImages(latitude: NSNumber, longitude: NSNumber) -> [String : AnyObject] {
        let parameters: [String : AnyObject ] = [
            "method" : "flickr.photos.search",
            Constants.Keys.APIKey : Constants.API_Key,
            Constants.Keys.Extras : Constants.Values.AllExtras,
            Constants.Keys.Safe_Search : Constants.Values.Safe_Search,
            Constants.Keys.Media_Type : Constants.Values.Media_Type,
            Constants.Keys.Data_Format : Constants.Values.Data_Format,
            Constants.Keys.No_JSON_Callback : Constants.Values.No_JSON_Callback,
            Constants.Keys.Per_Page : Constants.Values.Per_Page,
            Constants.Keys.BBox: boundingBoxForGETImages(Double(latitude), longitude: Double(longitude))
        ]
        return parameters
    }
    
    private func boundingBoxForGETImages(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_longitude = max(latitude - Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lon_Min)
        let bottom_left_latitude = max(longitude - Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lat_Min)
        let top_right_longitude = min(longitude + Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lon_Max)
        let top_right_latitude = min(latitude + Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lat_Max)
        
        return "\(bottom_left_longitude),\(bottom_left_latitude),\(top_right_longitude),\(top_right_latitude)"
    }
    
    private func randomPageFromResults() -> Int {
        return 1
    }
    


}