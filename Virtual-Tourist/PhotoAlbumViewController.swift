//
//  PhotoAlbumViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit
import Spring
import CoreData

class PhotoAlbumViewController: UIViewController, PinLocationPickerViewControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak  var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let regionRadius: CLLocationDistance = 1000
    var selectedPin: Pin!
    
    let transitionDelegate: TransitioningDelegate = TransitioningDelegate()
    
    /* Pin picker delegate method, selects the photo and subscribes to image loading notifs */
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin) {
        selectedPin = pin
        subscribeToImageLoadingNotifications()
    }

    var selectedIndexPaths = [NSIndexPath]()
    var insertedIndexPaths = [NSIndexPath]()
    var deletedIndexPaths = [NSIndexPath]()
    var updatedIndexPaths = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set collection view delegate and data source */
        collectionView.delegate = self
        collectionView.dataSource = self
        
        /* Add annotations to map for selected pin and center */
        dispatch_async(GlobalMainQueue, {
            self.mapView.addAnnotation(self.selectedPin)
            self.centerMapOnLocation(forPin: self.selectedPin)
        })
        
        
        performInitialFetch()
        
        configureGestureRecognizers()
  
    }
    
    func configureGestureRecognizers(){
        /* Create a long press gesture recognizer for handling long presses to open photos. */
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        longPressGestureRecognizer.delegate = self
        
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        collectionView.addGestureRecognizer(doubleTapRecognizer)
        
    }
    
    /* Life cycle */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(GlobalMainQueue, {
            self.configureDisplay()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToImageLoadingNotifications()
    }
    
    /* Show loading indicator while performing fetch */
    func performInitialFetch() {
        sharedContext.performBlockAndWait({
            self.performFetch()
        })
        dispatch_async(GlobalMainQueue, {
            self.configureDisplay()
        })
    }
    
    /* Handles all of the display logic for various life cycle methods */
    func configureDisplay(){
    
        noPhotosLabel.hidden = !self.selectedPin.loadingStatus.noPhotosFound
        
        /* Wait half a second to show the loading indicator */
        loadingView.hidden = !self.selectedPin.loadingStatus.isLoading
        
        if selectedPin.loadingStatus.error != nil {
            handleErrors(forPin: selectedPin, error: selectedPin.loadingStatus.error!)
        }
    
        collectionButton.enabled = fetchedResultsController.fetchedObjects!.count > 0
        /* Note, calling reload data fixes a bug that was causing bad access issues.  Must be called outside of global queue. */
        collectionView.reloadData()

    }
    
    /* Long taps will configure the cell to be deleted */
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        /* Ensure that the touch doesn't register unless ended */
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }

        let point = gestureRecognizer.locationInView(collectionView)
        let indexPath = collectionView.indexPathForItemAtPoint(point)
        
        if let index = indexPath {
            let cell = collectionView.cellForItemAtIndexPath(index) as! PhotoAlbumCollectionViewCell
            if selectedIndexPaths.contains(index) {
                cell.selected = false
                cell.setSelectedState()
                
                let index = selectedIndexPaths.indexOf(index)
                selectedIndexPaths.removeAtIndex(index!)
                print(selectedIndexPaths)
            } else {
                selectedIndexPaths.append(index)
                cell.selected = true
                cell.setSelectedState()
            }
            
            /* Configure cell and update UI */
            configureCollectionButton()
            
        }

    }

        /* Double taps will show the photo in fullscreen */
    func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        let point = gestureRecognizer.locationInView(collectionView)
        let indexPath = collectionView.indexPathForItemAtPoint(point)
        
        if let index = indexPath {
            let cell = collectionView.cellForItemAtIndexPath(index) as! PhotoAlbumCollectionViewCell
            
            /* Guard that the cell is not selected to ensure that a double tap works only when cell is not selected */
            openImageFullscreen(forCell: cell, atIndexPath: index)
            
        }
    }
    
    func openImageFullscreen(forCell cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        /* Define our attributes for the animation within the frame */
        let attributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let attributesFrame = attributes?.frame
        
        
        /* Define a frame for the collectionview cell we want to open */
        let frameOfImageToOpenFrom = collectionView.convertRect(attributesFrame!, toView: collectionView.superview)
        transitionDelegate.openingFrame = frameOfImageToOpenFrom
        
        let fullImageController = storyboard?.instantiateViewControllerWithIdentifier("FullImageViewController") as! FullImageViewController
        
        fullImageController.transitioningDelegate = transitionDelegate
        fullImageController.modalPresentationStyle = .Custom
        fullImageController.photo = cell.photo
        
        presentViewController(fullImageController, animated: true, completion: nil)
    }
    
    /* The image loading notifications solve the issue where the collectionview would not update after imgaes loaded
    */
    func subscribeToImageLoadingNotifications() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLoading", name: Notifications.PinDidFinishLoading, object: selectedPin)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLoadingWithErrors", name: Notifications.PinDidFinishLoadingWithErrors, object: selectedPin)
    }
    
    func unsubscribeToImageLoadingNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didFinishLoading() {
        /* Configure the display after loading finishes */
        
        dispatch_async(GlobalMainQueue, {
            self.configureDisplay()
        })
    }
    
    /* Setup flowlayout upon layout of subviews */
    override func viewDidLayoutSubviews() {
        
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        let contentSize: CGFloat = ((collectionView.bounds.width / 3) - 8)
        flowLayout.itemSize = CGSize(width: contentSize, height: contentSize)
        
    }
    
    /* perform our fetch with the fetched results controller */
    func performFetch() {

            do {
                
                try self.fetchedResultsController.performFetch()
                
            } catch let error as NSError {
                self.alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                    self.performFetch()
                    }])
            }

    }
    
    @IBAction func didTapCollectionButtonUpInside(sender: AnyObject) {

        
        /* Set loading and configure display */
        dispatch_async(GlobalMainQueue, {
            /* Configure the display to show loading */
            self.configureDisplay()
        })

        if selectedIndexPaths.count == 0 {
            
            deletePhotos()
            
            getImagesForPin({success, error in
                
                
                if error != nil {
                    /* Configure the display to show errors */
                    dispatch_async(GlobalMainQueue, {
                        self.configureDisplay()
                    })
                    
                    
                } else {
                    
                    self.sharedContext.performBlockAndWait({
                        
                        CoreDataStackManager.sharedInstance().saveContext()
                        self.configureDisplay()
                    })
                   
                }
                
                
            })
 
        } else {
            /* Delete the selected photos and save the context */
            sharedContext.performBlockAndWait({
                for index in self.selectedIndexPaths {
                    
                    let photoToDelete = self.fetchedResultsController.objectAtIndexPath(index) as! NSManagedObject
                    self.sharedContext.deleteObject(photoToDelete)
                    CoreDataStackManager.sharedInstance().saveContext()
                }
                dispatch_async(GlobalMainQueue, {
                    self.configureDisplay()
                })
            })
           
            /* Remove the selected index paths, reconfigure the collection button and save the context */
            selectedIndexPaths.removeAll()
            configureCollectionButton()
            
    
            
        }
    }
    
    func deletePhotos(){
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            self.sharedContext.deleteObject(photo)
        }
        /* Delete all associated photos and get new ones */
        selectedPin.deleteAllAssociatedPhotos()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    

    
    /* Handle logic for getting new photos for a pin and manage errors */
    func getImagesForPin(completionHandler: (success: Bool, error: NSError?) -> Void) {

        /* Make sure that there are photos left.  If not, then set the no photos label */
        guard selectedPin.hasPhotosLeft() else {

            completionHandler(success: false, error: nil)
            return
        }
        
        selectedPin.paginate()
        
        selectedPin.fetchAndStoreImages({success, error in
            
            if error != nil {
                
                completionHandler(success: false, error: error!)
                
            } else {
                
                completionHandler(success: true, error: nil)
                
            }

            
        })


    }
    
    /* Handle any errors in an easy succint way */
    func handleErrors(forPin pin: Pin, error: NSError) {
        view.fadeIn()
        alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
            self.didTapCollectionButtonUpInside(self)
        }])
    }
    
    
    /* Core data */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selectedPin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller.fetchedObjects?.count < 0 {
            print("No images fetched")
            noPhotosLabel.hidden = false
            collectionButton.enabled = false
            return
        }
        self.configureDisplay()

    }
    
    
    /* For keeping track of our index paths with the fetched results controller */
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Update :
            updatedIndexPaths.append(indexPath!)
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        default :
            break
        }
    }
    
    /* Toggle the delete / show collection button */
    func configureCollectionButton() {
        if selectedIndexPaths.count > 0 {
            
            collectionButton.setTitle("Delete Selected Images", forState: .Normal)
        
        } else {
        
            collectionButton.setTitle("New Collection", forState: .Normal)
        
        }
    }
    
}


/* Collection view delegate and data source methods */
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects

    }
    
    /* Return the count of the sections within the collection view */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    /* Configure each cell when there are new photos */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
            
        return cell
    }
    
    /* Refactor to keep cell logic out of data source methods. :) */
    func configureCell(cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath){
        
        if let photo = fetchedResultsController.fetchedObjects![indexPath.row] as? Photo {
            
            /* Set the cells photo to pass to the full image view */
            
            cell.photo = photo
            if photo.image != nil {
                
                /* Set the image and fade the image in with the setUpdating Call */
                cell.imageView.image = photo.image
                cell.setUpdatingState(false)
            } else {
                
                /* Make sure to fade the cell out when updating */
                cell.setUpdatingState(true)
                
                /* If fun mode is on, set the image to be something fun :) */
                if AppSettings.GlobalConfig.Settings.funMode == true {
                    cell.imageView.image = UIImage(named: "fun-mode")
                } else {
                    cell.imageView.image = UIImage(named: "missing-resource")
                }
                
            }
            
        }

    }


    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        
        if cell.isUpdating {
            return false
        }
        return true
    }

    /* Handle logic for selecting table view cells */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    }

}

/* Handles showing the map view for pins selected */
extension PhotoAlbumViewController: MKMapViewDelegate {
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
                annotationViewToReturn.enabled = false
                annotationViewToReturn.canShowCallout = false
            }
            return annotationViewToReturn
        }
        return nil
    }
    
    /* Center on map for selected pin */
    func centerMapOnLocation(forPin pin: Pin) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, regionRadius * 20.0, regionRadius * 20.0)
        mapView.setRegion(coordinateRegion, animated: false)
        
    }
}



