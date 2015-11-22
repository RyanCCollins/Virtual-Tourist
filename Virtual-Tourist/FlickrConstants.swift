//
//  FlickrConstants.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        
        
        static let Base_URL_Secure = "https://api.flickr.com/services/rest/"
        static let API_Key = "05851cc43d9794ea18fa650d03310676"
        
        
        struct Keys {
            static let Latitude = "latitude"
            static let longitude = "longitude"
            static let Sort = "sort"
            static let Page = "page"
            static let Per_Page = "per_page"
            static let Safe_Search = "safe_search"
            static let BBox = "bbox"
            static let No_JSON_Callback = "no_json_callback"
            static let Data_Format = "data_format"
            static let Extras = "extras"
            static let Media_Type = "media"
        }
        
        struct Values {
            static let Extras = "url_m"
            static let Data_Format = "json"
            static let No_JSON_Callback = "1"
            static let Safe_Search = "2"
            static let Bounding_Box_Half_Height = 1.5
            static let Bounding_Box_Half_Width = 0.36
            static let Lat_Min = -90.0
            static let Lat_Max = 90.0
            static let Lon_Min = -180.0
            static let Lon_Max = 180.0
            static let Media_Type = "photos"
            static let Pages = 1
            static let Per_Page = 96
        }
        
        struct SearchMethodArguments {
            static let dictionary: [String : AnyObject ] = [
                Constants.Keys.Extras : Constants.Values.Extras,
                Constants.Keys.Safe_Search : Constants.Values.Safe_Search,
                Constants.Keys.Media_Type : Constants.Values.Media_Type,
                Constants.Keys.Data_Format : Constants.Values.Data_Format,
                Constants.Keys.No_JSON_Callback : Constants.Values.No_JSON_Callback,
                Constants.Keys.Page : Constants.Values.Pages,
                Constants.Keys.Per_Page : Constants.Values.Per_Page,
                Constants.Keys.BBox: ""
            ]
        }
    }
    
    struct Methods {
        static let SEARCH = "flickr.photos.search"
    }
    
    struct JSONResponseKeys {
        
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}