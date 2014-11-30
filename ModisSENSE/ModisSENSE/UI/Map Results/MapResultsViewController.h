//
//  MapResultsViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/4/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMapView.h"
#import "EditPOIViewController.h"

@interface MapResultsViewController : UIViewController <GMapViewDelegate,EditPOIViewControllerDelegate>

//Array of POI objects
@property (strong,nonatomic) NSArray* pointsOfInterest;

//Zoom area region
@property (assign,nonatomic) MKCoordinateRegion region;

@property (assign,nonatomic) BOOL showTrajectory;

@property (weak, nonatomic) IBOutlet GMapView *gMapView;

@end
