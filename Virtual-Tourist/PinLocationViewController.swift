//
//  PinLocationViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Spring

/* Protocol for passing pin to delegate */
protocol PinLocationPickerViewControllerDelegate {
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin)
}

class PinLocationViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tapPinsToDeleteBanner: SpringLabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    /* Creating my own editing var because included is being changed randomly */
    var _editing: Bool = false
    

    let regionRadius: CLLocationDistance = 1000
    
    /* Pin to add defined globally, for use when rearranging and adding new pins */
    var pinToAdd: Pin? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Map view delegate methods */
        mapView.delegate = self
        mapView.userInteractionEnabled = true
        
        restoreMapRegionState(false)
        
        /* Add long press gesture recognizer for adding pins */
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.addTarget(self, action: "addAnnotation:")
        configureAllAnnotations()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Handle editing button here */
        _editing = false
        editButton.title = "Edit"
        tapPinsToDeleteBanner.hidden = true
    }
    
    @IBAction func didTapSettingsUpInside(sender: AnyObject) {
        /* Instantiate the settings view controller for showing the settings view */
        let controller = storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        
        /* Set us as the controllers delegate */
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    /* Add an annotation to the map based on our custom Pin class */
    func addAnnotation(sender: UIGestureRecognizer) {
        
        /* Get out of here if we are editing, or nasty things will happen :). */
        guard _editing != true else {
            return
        }
        
        let point: CGPoint = sender.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
    
        switch sender.state {
        case .Began :

            pinToAdd = Pin(coordinate: coordinate, context: sharedContext)
            
            dispatch_async(GlobalMainQueue, {
                self.mapView.addAnnotation(self.pinToAdd!)
            })
            
        case .Changed :
            /* Use Key Value Observation for changing our coordinate */
            pinToAdd?.willChangeValueForKey("coordinate")
            self.pinToAdd!.coordinate = coordinate
            pinToAdd?.didChangeValueForKey("coordinate")
            print("Changing")
        case .Ended :
            
            fetchNewPhotos(forPin: pinToAdd!)
            print("Fetching Photos")

        default :
            return
        }
        
    }
    
    func fetchNewPhotos(forPin pin: Pin) {
        
        /* Create a notification for updating the UI once photos have finished loading */
        let DidFinishLoadingNotification = NSNotification(name: Notifications.PinDidFinishLoading, object: pin)
            editButton.enabled = false
            pin.fetchAndStoreImages({success, error in
                
                /* Either way, call the DidFinishLoadingNotification and handle errors on the next view. */
                if success == true || error != nil {
                    dispatch_async(GlobalMainQueue, {
                        
                        self.editButton.enabled = true
                        NSNotificationCenter.defaultCenter().postNotification(DidFinishLoadingNotification)
                        
                    })
                    CoreDataStackManager.sharedInstance().saveContext()
                }
            
        })
    }
    

    /* When the fetched results controller changes pins, handle the mapview insertion and deletion (The only time that this is used presently is when we remove all annoations, but we can
     * use this for later purposes if we have multiple sources for the pins.
    */
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let pin = anObject as! Pin
        switch type {
        case .Insert :
            mapView.addAnnotation(pin)
        case .Update :
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
        case .Delete :
            mapView.removeAnnotation(pin)
            print("Map view did remove annotation")
        default :
            break
        }
    }
    
    
    /* Fetched Results controller for Pin entities will return all entities for the pin */
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetch = NSFetchRequest(entityName: "Pin")
        
        fetch.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    /* Convenience for removing and adding all mapview annotations */
    func configureAllAnnotations() {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [Pin])
        
    }
    
    @IBAction func didTapEditingUpInside(sender: AnyObject) {
        /* Switch editing state when the editing button is tapped */
        _editing = !_editing
        
        if _editing {
            editButton.title = "Done"
            tapPinsToDeleteBanner.hidden = false
            tapPinsToDeleteBanner.animate()
        } else {
            editButton.title = "Edit"
            tapPinsToDeleteBanner.fadeOut(0.5, delay: 0.0, endAlpha: 0.0, completion: {Void in
                self.tapPinsToDeleteBanner.hidden = true
            })
        }
    }

    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    /* The following three functions save and restore the map stay, helping to persist map annotations between sessions */
    func restoreMapRegionState(animated: Bool) {
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude =  regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let latitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let longitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(savedRegion, animated: animated)
        }
        
    }
    
    
    
    /* Core data stuff for saving map state */
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegion").path!
    }
    
    func saveMapState() {
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
        
    }

    
}

/* Map view extension methods */
extension PinLocationViewController: MKMapViewDelegate {
    
    /* Save map state when region changes. */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if !_editing {
            
            /* When not editing, open the gallery view controller */
            let galleryViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            let pin = view.annotation as! Pin

            galleryViewController.pinLocation(self, didPickPin: pin)
            navigationController?.pushViewController(galleryViewController, animated: true)
            
        } else {
            
            /* Delete pins when edit button is toggled */
            let pin = view.annotation as! Pin
            
            deletePinAndPhotos(pin)
            
            /* Note, the fetched results controller handles removing the annotation, but we are using this to make sure that the change happens immediately. */
            mapView.removeAnnotation(pin)
        }
    }
    
    /* Convenience method for deleting all associated photos and pin from the context.   */
    func deletePinAndPhotos(pin: Pin) {
        dispatch_async(GlobalMainQueue, {
            if !pin.loadingStatus.isLoading {
                pin.deleteAllAssociatedPhotos()
                self.sharedContext.deleteObject(pin)
            }
            CoreDataStackManager.sharedInstance().saveContext()
        })
    }
    
    /* Watch for dragging of the pin and delete the photos when dragged.  Fetch new photos when complete */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        /* If we are editing, get out of here to avoid issues */
        guard _editing == false else {
            return
        }
        
        /* Create a temporary reference to our pin */
        pinToAdd = view.annotation as? Pin
        
        switch(newState) {
        case .Starting:
            
            pinToAdd!.deleteAllAssociatedPhotos()
            
        case .Ending, .Canceling:

            fetchNewPhotos(forPin: pinToAdd!)
        default: break
        }
    }
    
    /* Create a mapView pin indicator */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            
            let pinId = "pin"
            
            var annotationViewToReturn: MKPinAnnotationView
            
            /* If we are reusing the annotation view, set a new annotation */
            if let pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinId) as? MKPinAnnotationView {
                
                pinAnnotationView.annotation = annotation
                annotationViewToReturn = pinAnnotationView
            } else {
                /* If new annotation view, configure and return */
                annotationViewToReturn = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
                annotationViewToReturn.animatesDrop = true
                annotationViewToReturn.draggable = true
                annotationViewToReturn.canShowCallout = false
            }
            return annotationViewToReturn
        }
        return nil
    }
    
}

