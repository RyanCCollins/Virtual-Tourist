//
//  FlickrConvenience.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func taskForGETImages(withBBoxParameters parameters: [String : AnyObject], completionHandler: (success: Bool, results: [Photo]?, error: NSError?)-> Void) {
        var mutableParameters = parameters
        
        mutableParameters[Constants.Keys.BBox] = [
            "bbox" : boundingBoxForGETImages(parameters[Constants.Keys.Latitude] as! Double, longitude: parameters[Constants.Keys.Latitude] as! Double),
        ]
        
        
        taskForGETMethod(Methods.SEARCH, parameters: mutableParameters, queryParameters: nil) {results, error in
            
            if error != nil {
                
            } else {
                
            }
            
        }
    }
    
    func boundingBoxForGETImages(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_longitude = max(latitude - Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lon_Min)
        let bottom_left_latitude = max(longitude - Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lat_Min)
        let top_right_longitude = max(longitude + Constants.Values.Bounding_Box_Half_Height, Constants.Values.Lon_Max)
        let top_right_latitude = max(latitude + Constants.Values.Bounding_Box_Half_Width, Constants.Values.Lat_Max)
        
        return "\(bottom_left_longitude),\(bottom_left_latitude),\(top_right_longitude),\(top_right_latitude)"
    }
    
}