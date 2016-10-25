//
//  ViewController.swift
//  FreeHandDrawingInMap
//
//  Created by Anish on 10/25/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit
import CoreLocation
import  GoogleMaps

class ViewController: UIViewController {
    
    var locationManager = HelperLocationManager.sharedInstance
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var cancelDrawingBtn: UIButton!{
        
        didSet{
            
            cancelDrawingBtn.isHidden = true
            let origImage = UIImage(named: "cross-1")
            let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cancelDrawingBtn.setImage(tintedImage, for: .normal)
            cancelDrawingBtn.tintColor = UIColor.blue
            cancelDrawingBtn.backgroundColor = UIColor.white
            
        }
    }
    
    @IBAction func cancelDrawingActn(_ sender: AnyObject?) {
        
        isDrawingModeEnabled = false
        let _ =  userDrawablePolygons.map{ $0.map = nil }
        let _ = polygonDeleteMarkers.map{ $0.map = nil}
        polygonDeleteMarkers.removeAll()
        userDrawablePolygons.removeAll()
        cancelDrawingBtn.isHidden = true
        
        
    }
    
    @IBOutlet weak var drawBtn: UIButton!{
        didSet{
            
            let origImage = UIImage(named: "pen")
            let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            drawBtn.setImage(tintedImage, for: .normal)
            drawBtn.tintColor = UIColor.blue
            drawBtn.backgroundColor = UIColor.white
            
        }
        
    }
    
    @IBAction func drawActn(_ sender: AnyObject?) {
        
        self.coordinates.removeAll()
        self.view.addSubview(canvasView)
        let origImage = UIImage(named: "pen")
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        drawBtn.setImage(tintedImage, for: .normal)
        drawBtn.tintColor = UIColor.white
        drawBtn.backgroundColor = UIColor.red
        
    }
    
    lazy var canvasView:CanvasView = {
        
        var overlayView = CanvasView(frame: self.googleMapView.frame)
        overlayView.isUserInteractionEnabled = true
        overlayView.delegate = self
        return overlayView
        
    }()
    
    var isDrawingModeEnabled = false
    var coordinates = [CLLocationCoordinate2D]()
    var userDrawablePolygons = [GMSPolygon]()
    var polygonDeleteMarkers = [DeleteMarker]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        googleMapView.delegate = self
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:.sendLocation,object:nil, queue:nil) {  notification in
            // Handle notification
            guard let userInfo = notification.userInfo,let currentLocation = userInfo["location"] as? CLLocation else {
                    
                    return
            }
            
            let cameraPos = GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.googleMapView.animate(to: cameraPos)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.removeObserver(self, name: .sendLocation, object: nil)
        
    }
    
    func createPolygonFromTheDrawablePoints(){
        
        let numberOfPoints = self.coordinates.count
        //do not draw in mapview a single point
        if numberOfPoints > 2 { addPolyGonInMapView(drawableLoc: coordinates) }//neglects a single touch
        coordinates = []
        self.canvasView.image = nil
        self.canvasView.removeFromSuperview()
        
        let origImage = UIImage(named: "pen")
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        drawBtn.setImage(tintedImage, for: .normal)
        drawBtn.tintColor = UIColor.red
        drawBtn.backgroundColor = UIColor.white
        
    }
    
    func  addPolyGonInMapView( drawableLoc:[CLLocationCoordinate2D]){
        
        isDrawingModeEnabled = true
        let path = GMSMutablePath()
        for loc in drawableLoc{
            
            path.add(loc)
            
        }
        let newpolygon = GMSPolygon(path: path)
        newpolygon.strokeWidth = 3
        newpolygon.strokeColor = UIColor.black
        newpolygon.fillColor = UIColor.black.withAlphaComponent(0.5)
        newpolygon.map = googleMapView
        if cancelDrawingBtn.isHidden == true{ cancelDrawingBtn.isHidden = false }
        userDrawablePolygons.append(newpolygon)
        addPolygonDeleteAnnotation(endCoordinate: drawableLoc.last!,polygon: newpolygon)
    }
    
    func addPolygonDeleteAnnotation(endCoordinate location:CLLocationCoordinate2D,polygon:GMSPolygon){
        
        let marker = DeleteMarker(location: location,polygon: polygon)
        let deletePolygonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deletePolygonView.layer.cornerRadius = 15
        deletePolygonView.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.center = deletePolygonView.center
        imageView.image = UIImage(named: "delete")
        deletePolygonView.addSubview(imageView)
        marker.iconView = deletePolygonView
        marker.map = googleMapView
        polygonDeleteMarkers.append(marker)
    }
    
}

//MARK: MAPVIEW DELEGATE METHODS
extension ViewController:GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        //do not accept touch of current location marker
        if let deletemarker = marker as? DeleteMarker{
            
            if let index = userDrawablePolygons.index(of: deletemarker.drawPolygon){
                
                userDrawablePolygons.remove(at: index)
                
            }
            if let  indexToRemove =  polygonDeleteMarkers.index(of: deletemarker){
                
                polygonDeleteMarkers.remove(at: indexToRemove)
                
            }
            
            deletemarker.drawPolygon.map = nil
            deletemarker.map = nil
            if userDrawablePolygons.count == 0{ cancelDrawingActn(nil) }
            return true
        }
        return false
    }
}

//MARK: GET DRAWABLE COORDINATES
extension ViewController:NotifyTouchEvents{
    
    func touchBegan(touch:UITouch){
        
        let location = touch.location(in: self.googleMapView)
        let coordinate = self.googleMapView.projection.coordinate(for: location)
        self.coordinates.append(coordinate)
        
    }
    
    func touchMoved(touch:UITouch){
        
        let location = touch.location(in: self.googleMapView)
        let coordinate = self.googleMapView.projection.coordinate(for: location)
        self.coordinates.append(coordinate)
        
    }
    
    func touchEnded(touch:UITouch){
        
        let location = touch.location(in: self.googleMapView)
        let coordinate = self.googleMapView.projection.coordinate(for: location)
        self.coordinates.append(coordinate)
        createPolygonFromTheDrawablePoints()
    }
}

