# Virtual Tourist
This application was created as the fourth project in the Udacity iOS Nanodegree.  It is called Virtual Tourist and showcases my ability to create a production ready iOS Application that utilizes Core Data and iOS networking to get image data from Flickr. 

Technologies used
`Core Data` `Networking` `MapKit` `CoreLocation` `RESTful API` `Grand Central Dispatch` `Multithreading` `Model View Controller (MVC)` `Asynchronous & Concurrent Multithreading`

- Developer: Ryan Collins 

## Project Setup
- To install, download the project and open the Virtual-Tourist.xcworkspace file in XCode version 7.0+ (opening the .xcprojectfile will NOT work)
- Follow the steps below to install the CocoaPods dependencies.

Fist, make sure you have cocoapods installed
```
gem install cocoapods
```
Then
```
cd /whatever/directory/theproject/isin/Virtual-Tourist
```
run this to install the dependencies
```
pod install
```

If this does not work, follow the steps located below in Troubleshooting.

- Runs best on an iPhone 6 or later with Swift 2.0 and iOS version 8.0+

##__Features__
-  Add a pin to the map to download new Flickr Photos
-  Persist new Pins, Settings and Photos to disk
-  View pins in a map showing your photo albums
-  Tap a pin to find photos taken at that location 
-  Organize your collection of photos
-  View your photo galleries
-  Double tap a photo to view full screen

##__Technologies and Best Practices__
During the development of this application, I experimented with many different technologies and I utilized best practices.  I used CocoaPods to extend the capabilities of the app.  The main feature of this application is showing the usage of Core Data and networking in Swift.  Read the description below to find out more.


##__Running the App__
---
To run this app, please download the [project file]({{page.downloads.zip}}), open the Virtual-Tourist.xcworkspace workspace file, select a device to run it on and press the run button.  

As noted above, you need to run 
```
pod install
```

from the root directory of the project in order to install project dependencies.

Then, feel free to walk through and see all of the features.  Please get in touch with me if you have any issues.  Make sure to play around with all of the functionality and see all of the great features I added.

##__Description & Specifications__
---

### Travel Locations Map

When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.
The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.
Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.

### Photo Album

If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin.
If no images are found a “No Images” label will be displayed.
If there are images, then they will be displayed in a collection view.
While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled. The app should determine how many images are available for the pin location, and display a placeholder image for each.

Once the images have all been downloaded, the app should enable the New Collection button at the bottom of the page. Tapping this button should empty the photo album and fetch a new set of images. Note that in locations that have a fairly static set of Flickr images, “new” images might overlap with previous collections of images.
Users should be able to remove photos from an album by tapping them. Pictures will flow up to fill the space vacated by the removed photo.
All changes to the photo album should be automatically made persistent.
Tapping the back button should return the user to the Map view.

If the user selects a pin that already has a photo album then the Photo Album view should display the album and the New Collection button should be enabled.

### Troubleshooting
If for some reason, you run into issues installing, it's likely due to cocoapods.  What cocoapods does is it manages package dependencies for the project.  You need to make sure that you upen the .xcworkspace project because that is a requirement of cocoapods. 

If you still have difficulties, please see the [CocoaPods troubleshooting guide](https://guides.cocoapods.org/using/troubleshooting.html)
