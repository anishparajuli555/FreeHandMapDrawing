//
//  DeleteMarker.swift
//  Relly
//
//  Created by Anish on 7/7/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit
import GoogleMaps

class DeleteMarker: GMSMarker {
    
    var drawPolygon:GMSPolygon
    var markers:[GMSMarker]?
    
    init(location:CLLocationCoordinate2D,polygon:GMSPolygon) {
        
        
        self.drawPolygon = polygon
        super.init()
        super.position = location
        
    }
    
}
