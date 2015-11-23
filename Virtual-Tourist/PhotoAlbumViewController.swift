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

class PhotoAlbumViewController: UIViewController  {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    let regionRadius: CLLocationDistance = 1000
    
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin?) {
        
    }
    
    var pinToShow: Pin?
    
    var selectedIndexPaths = [NSIndexPath]()
    var instertedIndexPaths = [NSIndexPath]()
    var deletedIndexPaths = [NSIndexPath]()
    var updatedIndexPaths = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        centerMapOnLocation(forPin: pinToShow!)
    }
    
    @IBAction func didTapCollectionButtonUpInside(sender: AnyObject) {
    }
    
    /* Core data */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pinToShow!)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    func attemptToDownload(photo: Photo) {
        
        FlickrClient.sharedInstance().downloadResource(forPhoto: photo, completionHandler: {success, error in
            CoreDataStackManager.sharedInstance().saveContext()
            if error != nil {
                self.alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                    self.attemptToDownload(photo)
                }])
            }

        })
        
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller.fetchedObjects?.count > 0 {
            
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
    
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo? {
            return sections.numberOfObjects
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if photo.image != nil {
            configureUIState(forCell: cell, atIndexPath: indexPath)
        } else {
            cell.imageView.image = stockPhoto
        }
        
        return cell
    }
    
    func configureUIState(forCell cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func downloadPhotos() {
        let task = FlickrClient.sharedInstance()
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        
        if cell.activityIndicator.isAnimating() {
            
            return false
            
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        let image = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if image.filePath == nil || image.filePath == "" {
            
            cell.isReloading(true)
            /* Try refetching here */
            
            return
        }
        
        if let indexPath = selectedIndexPaths.indexOf(indexPath) {
            selectedIndexPaths.removeAtIndex(indexPath)
        } else {
            selectedIndexPaths.append(indexPath)
        }
        
        /* COnfigure cell and update UI */
    }
    
}

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
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, regionRadius * 4.0, regionRadius * 4.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
}

