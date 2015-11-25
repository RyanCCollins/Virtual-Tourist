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
    
    let regionRadius: CLLocationDistance = 1000
    var selectedPin: Pin!
    
    /* Pin picker delegate method, loads photos and centers map on pin */
    func pinLocation(pinPicker: PinLocationViewController, didPickPin pin: Pin) {
        
        selectedPin = pin
    }
    
    var selectedIndexPaths = [NSIndexPath]()
    var instertedIndexPaths = [NSIndexPath]()
    var deletedIndexPaths = [NSIndexPath]()
    var updatedIndexPaths = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mapView.addAnnotation(selectedPin)
        centerMapOnLocation(forPin: selectedPin)
        performFetch({success in
            if !success {
                self.noPhotosLabel.hidden = false
            } else {
                self.noPhotosLabel.hidden = true
            }
        })
        
        let gestureRecognizer = UIGestureRecognizer(target: view, action: "handleLongPress:")
        gestureRecognizer.delegate = self
        
        collectionView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        let contentSize: CGFloat = ((collectionView.bounds.width / 3) - 8)
        flowLayout.itemSize = CGSize(width: contentSize, height: contentSize)
        
        
        
    }
    
    func performFetch(callbackHandler: ((success:Bool)->Void)?) {
        
        do {
            try fetchedResultsController.performFetch()

        } catch let error as NSError {
            alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                self.performFetch(nil)
            }])
        }
    }
    
    @IBAction func didTapCollectionButtonUpInside(sender: AnyObject) {
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
            performFetch(nil)
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
                
                self.alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                    self.downloadNewPhotos(forPin: pin)
                }])
                
            }
            
        })
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
        
        cell.isReloading(true)
        
        if photo.filePath == nil || photo.filePath == "" {
            cell.imageView.image = cell.stockPhoto
            cell.imageView.fadeIn()
            performFetch(nil)
        } else if photo.image != nil {
            cell.imageView.image = photo.image
            cell.imageView.fadeIn()
        } else {
            
            print(photo.filePath)
            if let data = NSData(contentsOfFile: photo.filePath!) {
                print("Made it")
                photo.image = UIImage(data: data)
                
                dispatch_async(GlobalMainQueue, {
                    cell.imageView.image = photo.image
                })
                
            }
        }
        
        cell.isReloading(false)
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
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if photo.filePath == nil || photo.filePath == "" {
            
            cell.isReloading(true)
            /* Try refetching here */
            performFetch(nil)
            return
        }
        
        if let indexPath = selectedIndexPaths.indexOf(indexPath) {
            selectedIndexPaths.removeAtIndex(indexPath)
            cell.isSelected(false)
        } else {
            selectedIndexPaths.append(indexPath)
            cell.isSelected(true)
        }
        
        /* COnfigure cell and update UI */
        
        configureCollectionButton()
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
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, regionRadius * 20.0, regionRadius * 20.0)
        mapView.setRegion(coordinateRegion, animated: false)
        
    }
}

