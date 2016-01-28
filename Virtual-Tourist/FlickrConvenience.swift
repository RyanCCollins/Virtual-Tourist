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
    
<<<<<<< HEAD
    func taskForFetchPhotos(forPin pin: Pin, completionHandler: (success: Bool, photos: [Photo]?, error: NSError?)-> Void) {
    
=======
    /* Fetches all photos for the pin from Flickr, note, does not handle saving to Core Data */
<<<<<<< HEAD
    func taskForFetchPhotos(forPin pin: Pin, completionHandler: (success: Bool, error: NSError?)-> Void) {
        
        /* increment the current page in order to get new photos */
//        if pin.currentPage == 0 || pin.currentPage == nil {
//            pin.currentPage = 1
//        } else {
//            pin.incrementCurrentPage()
//        }
>>>>>>> newFeat
=======
    func taskForFetchPhotos(forPin pin: Pin, completionHandler: (success: Bool, photos: [Photo]?, error: NSError?)-> Void) {
>>>>>>> codeStash
        
        let parameters = dictionaryForGetImages(forPin: pin)
        
        taskForGETMethod(Constants.Base_URL_Secure, parameters: parameters) {results, error in
            
            if error != nil {
                
                completionHandler(success: false, photos: nil, error: error)
                
            } else {
                
                if results != nil {
                    if let photosDictionary = results![JSONResponseKeys.Photos] as? [String : AnyObject], photoArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]], pages = photosDictionary[JSONResponseKeys.Pages], currentPage = photosDictionary[JSONResponseKeys.Page] {
                        
                        
                        pin.countOfPhotoPages = (pages as? NSNumber)!
                        pin.currentPage = currentPage as? NSNumber
                        
<<<<<<< HEAD
=======
                        /* Map the photo dictionary to Photo objects */
>>>>>>> newFeat
                        let photos = photoArray.map(){
                            Photo(dictionary: $0, pin: pin, context: self.sharedContext)
                        }
                        
<<<<<<< HEAD
<<<<<<< HEAD
                        
                        completionHandler(success: true, photos: photos, error: nil)
=======
                        completionHandler(success: true, error: nil)
>>>>>>> newFeat
=======
                        completionHandler(success: true, photos: photos, error: nil)
>>>>>>> codeStash
                        
                    }
                    
                }

            }
            
        }
    }
<<<<<<< HEAD

=======
    
<<<<<<< HEAD
    /* Convenience method for getting images for photo */
    func getImageForPhoto(photo: Photo, completionHandler: CompletionHandler) {
        
        FlickrClient.sharedInstance().taskForGETImageFromURL(photo.url_m!, completionHandler: {result, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
        
    }
>>>>>>> newFeat
=======
>>>>>>> codeStash
    
    func dictionaryForGetImages(forPin pin: Pin) -> [String : AnyObject] {
        
        let parameters: [String : AnyObject ] = [
            Constants.Keys.Method : Constants.Values.Methods.SEARCH,
            Constants.Keys.Page : pin.currentPage as! Int,
            Constants.Keys.APIKey : Constants.API_Key,
            Constants.Keys.Extras : Constants.Values.AllExtras,
            Constants.Keys.Safe_Search : Constants.Values.Safe_Search,
            Constants.Keys.Media_Type : Constants.Values.Media_Type,
            Constants.Keys.Data_Format : Constants.Values.Data_Format,
            Constants.Keys.No_JSON_Callback : Constants.Values.No_JSON_Callback,
            Constants.Keys.Per_Page : Constants.Values.Per_Page,
            Constants.Keys.BBox: boundingBoxForGETImages(forPin: pin)
        ]
        return parameters
    }
    
    private func boundingBoxForGETImages(forPin pin: Pin) -> String {
        
        let bottom_left_longitude = max(Double(pin.longitude) - Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lon_Min)
        let bottom_left_latitude = max(Double(pin.latitude) - Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lat_Min)
        let top_right_longitude = min(Double(pin.longitude) + Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lon_Max)
        let top_right_latitude = min(Double(pin.latitude) + Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lat_Max)
        
        return "\(bottom_left_longitude),\(bottom_left_latitude),\(top_right_longitude),\(top_right_latitude)"
    }
    
    private func randomPageFromResults() -> Int {
        return 1
    }
    


}