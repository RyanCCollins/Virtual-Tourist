//
//  GlobalConstants.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/21/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation

/* Helper properties to get a_sync queues */
var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}

/* typealias for completion block handlers */
typealias CallbackHandler = (success: Bool, error: NSError?) -> Void

/* Define global errors */
struct GlobalErrors : ErrorType {
    
    static let LogoutError = Errors.constructError(domain: "Global", userMessage: "An error occured while trying to logout.")
    static let GenericNetworkError = Errors.constructError(domain: "Global", userMessage:  "An error occured while getting data from the network.")
    static let GenericError = Errors.constructError(domain: "Global", userMessage:  "An error occured.  Please try again.")
    static let MissingData = Errors.constructError(domain: "Global", userMessage:  "Missing something.  Please make sure all text fields are filled out appropriately.")
    static let InvalidURL = Errors.constructError(domain: "Global", userMessage:  "The link is not valid.  Please try again.")
    static let GEOCode = Errors.constructError(domain: "Global", userMessage:  "Could not geocode your location.  Enter a more specific location and try again.")
    static let BadCredentials = Errors.constructError(domain: "Global", userMessage:  "Please enter a valid email address and password.")
    static let LogOut = Errors.constructError(domain: "Global", userMessage:  "Failed to logout of session.  Please try again.")
    
}

/* Define errors within domain of the Client */
struct ErrorMessages {
    
    static let JSONSerialization =  "An error occured when sending data to the network.  Could not properly parse the data."
    static let Parse =  "An error occured while getting data from the network.  Unable to parse the data."
    
    struct Status {
        static let Auth = "The network returned an invalid response.  Please re-enter your credentials and try again."
        static let InvalidResponse = "Unable to log you in due to an invalid response from the server.  Please make sure your username and password are correct and try again."
        static let Network = "Could not connect to the network.  Please try again."
    }
    
}

/* Helper function to construct errors project wide */
public struct Errors : ErrorType {
    public var userMessage : String
    public var httpStatusCode : Int?
    public var errorCode : Int?
    public var domain: String
    public var cause: ErrorType?
    public var timeStamp = CFAbsoluteTimeGetCurrent()
    
    
    public static func constructError(errorCode: Int? = 0, domain: String, userMessage: String) -> NSError {
        print("Error: \(errorCode) message: \(userMessage) domain: \(domain)")
        return NSError(domain: domain, code: errorCode!, userInfo: [NSLocalizedDescriptionKey : userMessage])
    }
    
}