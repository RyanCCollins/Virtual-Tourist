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
        static let API_Key = "9a20ed67f3b6ca6c9f8a5c66e62903f0"
        static let Photo_Source_URL = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}"
        
        
        struct Keys {
            static let Latitude = "latitude"
            static let longitude = "longitude"
            static let Sort = "sort"
            static let Page = "page"
            static let Per_Page = "per_page"
            static let Safe_Search = "safe_search"
            static let BBox = "bbox"
            static let No_JSON_Callback = "nojsoncallback"
            static let Data_Format = "format"
            static let Extras = "extras"
            static let Media_Type = "media"
            static let Method = "method"
            static let APIKey = "api_key"
        }
        
        struct Values {
            static let AllExtras = "url_m"
            static let Data_Format = "json"
            static let No_JSON_Callback = 1
            static let Safe_Search = 2
            static let Bounding_Box_Half_Height = 1.5
            static let Bounding_Box_Half_Width = 0.36
            static let Lat_Min = -90.0
            static let Lat_Max = 90.0
            static let Lon_Min = -180.0
            static let Lon_Max = 180.0
            static let Media_Type = "photos"
            static let Per_Page = 24
            
            struct Methods {
                static let SEARCH = "flickr.photos.search"
            }
        }
        
    }

    
    struct JSONResponseKeys {
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Photo = "photo"
        static let Photos = "photos"
        static let Pages = "pages"
        static let Page =  "page"
        static let ID = "id"
        static let Title = "title"
        
        struct StatusMessage {
            static let OK = "ok"
            static let Fail = "fail"
        }
        struct ImageSizes {
            static let MediumURL = "url_m"
            static let ThumbnailURL = "url_t"
            static let LargeURL = "url_b"
        }
        
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}