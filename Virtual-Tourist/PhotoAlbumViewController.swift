//
//  PhotoAlbumViewController.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, PinLocationPickerViewControllerDelegate, UIGestureRecognizerDelegate  {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let regionRadius: CLLocationDistance = 1000
    var selectedPin: Pin!
    
    /* Pin picker delegate method, loads photos and centers map on pin */
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin) {
        
        selectedPin = pin
        subscribeToImageLoadingNotifications()
    }
    
    var selectedIndexPaths = [NSIndexPath]()
    var instertedIndexPaths = [NSIndexPath]()
    var deletedIndexPaths = [NSIndexPath]()
    var updatedIndexPaths = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set collection view delegate and data source */
        collectionView.delegate = self
        collectionView.dataSource = self
        
        /* Add annotations to map for selected pin and center */
        mapView.addAnnotation(selectedPin)
        centerMapOnLocation(forPin: selectedPin)
        
        performFetch()
        
        let gestureRecognizer = UIGestureRecognizer(target: view, action: "handleLongPress:")
        gestureRecognizer.delegate = self
        
        collectionView.addGestureRecognizer(gestureRecognizer)
    }
    
    func subscribeToImageLoadingNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLoadingThumbnails", name: Notifications.didFinishLoadingThumbails, object: selectedPin)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "isLoadingThumbnails", name: Notifications.willFinishLoadingThumbnails, object: selectedPin)
    }
    
    func isLoadingThumbnails() {
        print("Notification for isLoadingThumbnails Received")
        view.alpha = 0.6
        activityIndicator.startAnimating()
    }
    
    func didFinishLoadingThumbnails() {
        print("Notification for didFinishLoadingThumbnails Received")
        collectionView.reloadData()
        self.activityIndicator.stopAnimating()
        view.fadeIn(0.3, delay: 0.0, alpha: 1.0, completion: {_ in})
        
        if selectedPin.loadingError != nil {
            alertController(withTitles: ["Ok", "Retry"], message: (selectedPin.loadingError?.localizedDescription)!, callbackHandler: [nil, {Void in
                    self.selectedPin.fetchThumbnail(nil)
                }])
        }
        
    }
    
    /* Setup flowlayout upon layout of subviews */
    override func viewDidLayoutSubviews() {
        
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        let contentSize: CGFloat = ((collectionView.bounds.width / 3) - 8)
        flowLayout.itemSize = CGSize(width: contentSize, height: contentSize)
        
    }
    
    func performFetch() {
        
        do {
            
            try fetchedResultsController.performFetch()

        } catch let error as NSError {
            alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                self.performFetch()
            }])
        }
    }
    
    @IBAction func didTapCollectionButtonUpInside(sender: AnyObject) {
        /* If there are no selected index paths, download new photos for the selected pin */
        if selectedIndexPaths.count == 0 {
            
            downloadNewPhotos(forPin: selectedPin)
            
        } else {
            
            for index in selectedIndexPaths {
                
                let photoToDelete = fetchedResultsController.objectAtIndexPath(index) as! NSManagedObject
                sharedContext.deleteObject(photoToDelete)
            }

            selectedIndexPaths.removeAll()
            configureCollectionButton()
            
            CoreDataStackManager.sharedInstance().saveContext()
            //Get new photos?
            performFetch()
        }
    }
    
    func downloadNewPhotos(forPin pin: Pin) {
        
        /* Loop through and delete photos from shared context */
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            
            sharedContext.deleteObject(photo)
            
        }
        

        CoreDataStackManager.sharedInstance().saveContext()
        
        
        FlickrClient.sharedInstance().taskForFetchPhotos(forPin: pin, completionHandler: {success, error in
            
            if error != nil {
                
                self.handleErrors(forPin: pin, error: pin.loadingError!)
                
            } else {
                pin.fetchThumbnail({success, error in
                    if error != nil {
                        self.handleErrors(forPin: pin, error: pin.loadingError!)
                    }
                    
                })
            }
            
        })
    }
    
    func handleErrors(forPin pin: Pin, error: NSError) {
        activityIndicator.stopAnimating()
        view.fadeIn()
        alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
            self.downloadNewPhotos(forPin: pin)
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
        if controller.fetchedObjects?.count > 0 {
            print("No images fetched")
        }
        
        collectionView.performBatchUpdates({
            
            self.collectionView.insertItemsAtIndexPaths(self.instertedIndexPaths)
            
            self.collectionView.deleteItemsAtIndexPaths(self.deletedIndexPaths)
            
            self.collectionView.reloadItemsAtIndexPaths(self.updatedIndexPaths)
            
            }, completion: {Void in
                self.instertedIndexPaths.removeAll()
                self.deletedIndexPaths.removeAll()
                self.updatedIndexPaths.removeAll()
        })
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            instertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update :
            updatedIndexPaths.append(indexPath!)
        default :
            break
        }
    }
    
    func configureCollectionButton() {
        if selectedIndexPaths.count > 0 {
            collectionButton.setTitle("Delete Selected Images", forState: .Normal)
        } else {
            collectionButton.setTitle("New Collection", forState: .Normal)
        }
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo? {
            print(sections)
            return sections.numberOfObjects
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        //cell.activityIndicator.startAnimating()
        
        if photo.imageThumb != nil {
            print(">>>Photo for cell: \(indexPath.row) is \(photo.imageThumb?.description)")
            cell.imageView.image = photo.imageThumb
            
        } else if photo.filePath != nil {
            
            if let data = NSData(contentsOfFile: (photo.filePath?.thumbnailName)!) {
                photo.imageThumb = UIImage(data: data)
                cell.imageView.image = photo.imageThumb
                
            }
        } else {
            cell.imageView.image = cell.stockPhoto
            
        }
        
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.fadeOut()
        cell.imageView.fadeIn()
        
        return cell
    }


    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        
        if cell.isUpdating {
            return false
        }
        return true
    }
    
    func handLongPress(gestureRecognizer: UIGestureRecognizer) {
//        if gestureRecognizer.state != .Ended {
//            return
//        }
//        
//        let point = gestureRecognizer.locationInView(collectionView)
//        
//        let index = collectionView.indexPathForItemAtPoint(point)
//        
//        guard index != nil else {
//            return
//        }
//        
//        let cell = UICollectionViewCell() as! PhotoAlbumCollectionViewCell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
//        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
//        
//        if photo.filePath == nil || photo.filePath == "" {
//            
//            /* Try refetching here */
//            performFetch(nil)
//            return
//        }
//        
        if selectedIndexPaths.contains(indexPath) {
            cell.isSelected(false)
        } else {
            cell.isSelected(true)
        }
        
        /* COnfigure cell and update UI */
        
        configureCollectionButton()
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
    
    func centerMapOnLocation(forPin pin: Pin) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, regionRadius * 20.0, regionRadius * 20.0)
        mapView.setRegion(coordinateRegion, animated: false)
        
    }
}

