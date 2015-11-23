////
////  Config.swift
////  Virtual-Tourist
////
////  Created by Ryan Collins on 11/22/15.
////  Modified from FavoriteActors by Jason on 1/23/15.
////  Copyright © 2015 Tech Rapport. All rights reserved.
////
//
//import Foundation
//
///* The config class handles configuration for downloading images from Flickr for given file sizes.  It also handles when images should be updated and directs the FlickrClient to use stored images if possible. */
//
//// MARK: - Files Support
//private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("TheMovieDB-Context")
//
//
//class Config: NSObject, NSCoding {
//    
//    // Default values from 1/12/15
//    var baseImageURLString = "http://image.tmdb.org/t/p/"
//    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
//    var posterSizes = ["s", "q","t","m","n","-","z","c","b","h","k","o"]
//    var dateUpdated: NSDate? = nil
//    
//    override init() {
//        
//    }
//    
//    convenience init?(dictionary: [String : AnyObject]) {
//        
//        self.init()
//        
//        if let imageDictionary = dictionary[TheMovieDB.Keys.ConfigImages] as? [String : AnyObject] {
//            
//            if let urlString = imageDictionary[TheMovieDB.Keys.ConfigBaseImageURL] as? String {
//                baseImageURLString = urlString
//            } else {return nil}
//            
//            if let secureUrlString = imageDictionary[TheMovieDB.Keys.ConfigSecureBaseImageURL] as? String {
//                secureBaseImageURLString = secureUrlString
//            } else {return nil}
//            
//            if let posterSizesArray = imageDictionary[TheMovieDB.Keys.ConfigPosterSizes] as? [String] {
//                posterSizes = posterSizesArray
//            } else {return nil}
//            
//            if let profileSizesArray = imageDictionary[TheMovieDB.Keys.ConfigProfileSizes] as? [String] {
//                profileSizes = profileSizesArray
//            } else {return nil}
//            
//            dateUpdated = NSDate()
//            
//        } else {
//            return nil
//        }
//    }
//    
//    
//    // Returns the number days since the config was last updated.
//    
//    var daysSinceLastUpdate: Int? {
//        
//        if let lastUpdate = dateUpdated {
//            return Int(NSDate().timeIntervalSinceDate(lastUpdate)) / 60*60*24
//        } else {
//            return nil
//        }
//    }
//    
//    func updateIfDaysSinceUpdateExceeds(days: Int) {
//        
//        // If the config is up to date then return
//        if let daysSinceLastUpdate = daysSinceLastUpdate {
//            if (daysSinceLastUpdate <= days) {
//                return
//            }
//        }
//        
//        // Otherwise, update
//        FlickrClient.sharedInstance().updateConfig() { didSucceed, error in
//            
//            if let error = error {
//                print("Error updating config: \(error.localizedDescription)")
//            } else {
//                print("Updated Config: \(didSucceed)")
//                TheMovieDB.sharedInstance().config.save()
//            }
//        }
//    }
//    
//    // MARK: - NSCoding
//    
//    let BaseImageURLStringKey = "config.base_image_url_string_key"
//    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
//    let PosterSizesKey = "config.poster_size_key"
//    let ProfileSizesKey = "config.profile_size_key"
//    let DateUpdatedKey = "config.date_update_key"
//    
//    required init?(coder aDecoder: NSCoder) {
//        baseImageURLString = aDecoder.decodeObjectForKey(BaseImageURLStringKey) as! String
//        secureBaseImageURLString = aDecoder.decodeObjectForKey(SecureBaseImageURLStringKey) as! String
//        posterSizes = aDecoder.decodeObjectForKey(PosterSizesKey) as! [String]
//        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(baseImageURLString, forKey: BaseImageURLStringKey)
//        aCoder.encodeObject(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
//        aCoder.encodeObject(posterSizes, forKey: PosterSizesKey)
//        aCoder.encodeObject(profileSizes, forKey: ProfileSizesKey)
//        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
//    }
//    
//    func save() {
//        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
//    }
//    
//    class func unarchivedInstance() -> Config? {
//        
//        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
//            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? Config
//        } else {
//            return nil
//        }
//    }
//}
//
