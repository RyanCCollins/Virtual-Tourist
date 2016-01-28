##__Virtual-Tourist__

This application was created as the fourth project in the Udacity iOS Nanodegree.  It is called Virtual Tourist and showcases my ability to create a production ready iOS Application that utilizes networking to get and post data and persist that data using Apple's Core Data technology. 

Technologies used
´Core Data´ ´Networking´ ´MapKit´ `Spring Animations´ ´TouchID´ ´CoreLocation´ ´RESTful API´ ´Cocoa Pods´ ´Grand Central Dispatch´ ´Multithreading´ ´Model View Controller (MVC)´ ´Asynchronous & Concurrent Multithreading´ ´Objective C´
##__Features__
-  Drop pins on a map
-  POST GET and DELETE Data from FLickr
-  View pins in a map showing locations added by user
-  When a pin is dropped, the Flickr Client searches for photos taken at that location
-  Edit your various photo collections and save them using Core Data
-  Persist settings and all data

##__Technologies and Best Practices__
During the development of this application, I experimented with many different technologies and I utilized best practices.  I used CocoaPods to extend the capabilities of the app. The main feature of this application is showing the usage of networking and Core Data in Swift.  Read the description below to find out more.


##__Running the App__
---
To run this app, please download the [project file]({{page.downloads.zip}}), open the workspace file, select a device to run it on and press the run button.  Make sure to play around with all of the functionality and see all of the great features I added.


##__Description & Specifications__
---
This app shows my ability to build software that incorporates networking, Core Data and many modern Cocoa technologies.  I built a custom API client that connects to the Flickr API.  It connects to the APIs and makes POST, GET, PUT, DELETE and Query requests.  It does this while utilizing MVC to the full extent in the sense that all API calls are done in the background while the view remains responsive.

I abstracted away a lot of the functionality into the Model classes to keep my View Controller lightweight.  All of the API functionality happens in the API Model classes and the data gets returned via callback handlers to the client. 

To keep the UI responsive, I used Grand Central Dispatch to run UI Events on the one of three of the Global Queues.  Some of the network API calls also happen in a Utility GCD Queue.

I certainly went above and beyond in the creation of this application, which I will go into below.

###__User Interface__
I used some great features when building the UI of this application.  I utilized several Cocoa Pods while creating this application, including Chameleon, Spring Animations and more.  I used these Pods, along with my own code, to make a very interesting and fun user interface.  

I used custom map annotations in the ´MapViewController´ which really makes the user interface look nice.  The standard map pin annotations are replaced by little pins with the Udacity logo on them.  I set a global color theme that really looks nice and changes the color of the navigation bars to a nice flat blue color.  I used color appropriately to highlight different areas.  I also integrated nice animations into the user interface for the main view and the gallery view.

###__Error Checking__
This application uses error checking extensively to ensure a great experience for the user.  In the ´OnTheMapConstants´ file, I defined an ´ErrorType´ data model, which helps to create errors with messages that can be passed on to the user.  If authentication or any other network request fails, the user is alerted with a nice message.

Also, the API Clients extensively use Guard statements to safeguard against any bad network requests.  This application is extremely solid and should not produce any fatal errors.  The user interface remains responsive and when the network gets hung up, it will show progress indicators and error messages to the user.  I tested this extensively using Apple's Network Conditioner.

###GET Requests
For any GET requests, use the `taskForGETMethod:`, passing in the method call, parameters (excluding the api_key), and a completion handler for the callback method. The method returns an `NSURLSessionTask` object.

{% highlight raw %}
func taskForGETImage(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask
{% endhighlight %}

###__POST Requests__
For POST requests, use the `taskForPOSTMethod`, passing in the method, parameters, a `JSONBody` dictionary, which includes the data you wish to pass in the request and also pass in a completion handler.  This method returns an `NSURLSessionDataTask` object.
{% highlight raw %}
func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
{% endhighlight %}

Credit for icons and fonts:
<a href='http://www.freepik.com/free-vector/world-paper-map-free-template_718589.htm'>Designed by Freepik</a>
<div>Icons made by <a href="http://www.flaticon.com/authors/catalin-fertu" title="Catalin Fertu">Catalin Fertu</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>

<a href="http://www.freepik.<div>Icons made by <a href="http://www.flaticon.com/authors/pavel-kozlov" title="Pavel Kozlov">Pavel Kozlov</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>/free-vector/world-map-with-pointers_780564.htm">Designed by Freepik</a>

<div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
<div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
<div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
<div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
<a href='http://www.freepik.com/free-vector/mobile-phone-with-pointer-on-screen_766416.htm'>Designed by Freepik</a>
Prime Font from: http://fontfabric.com/prime-free-font  by Max Pirsky

Modeka Font From: http://freshhh.ritcreative.com/modeka.html

Udacity Logo Copyright Udacity
